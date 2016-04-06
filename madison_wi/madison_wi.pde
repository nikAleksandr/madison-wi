//Based on code written by Limor "Ladyada" for Adafruit Industries
import processing.io.*;
// script uses Board numbers (IE Physical pin numbers)
// processing defaults to GPIO number, RPI to use physical pin numbers
// may need to convert pins to their RPI.PIN# versions here. 
int SPICLK = 18;
int SPIMISO = 23;
int SPIMOSI = 24;
int SPICS = 25;
//set up variables to keep track of base value
//everything has to be set up before running the program
int FSR1_base = readadc(0, SPICLK, SPIMOSI, SPIMISO, SPICS);
int FSR2_base = readadc(1, SPICLK, SPIMOSI, SPIMISO, SPICS);
//int FSR3_base = readadc(2, SPICLK, SPIMOSI, SPIMISO, SPICS);
//int FSR4_base = readadc(3, SPICLK, SPIMOSI, SPIMISO, SPICS);
int FSR1, FSR2, FSR3, FSR4;
//waves variables
PImage madison;
float x, y, a, b, r=1, th;
int numPoint = 100;
int blur = 30;
int time_to_dis = 5; //a time to dissipation
float[][] pointsFromCircle = new float[numPoint][numPoint];
float[][] pointsFromInnerCircle = new float[numPoint][numPoint];
float[][] pointsFromOuterCircle = new float[numPoint][numPoint];
boolean waves = false;

boolean debug = true;

void setup() {
  //set up the SPI interface
  GPIO.pinMode(SPIMOSI, GPIO.OUTPUT);
  GPIO.pinMode(SPIMISO, GPIO.INPUT);
  GPIO.pinMode(SPICLK, GPIO.OUTPUT);
  GPIO.pinMode(SPICS, GPIO.OUTPUT);
  
  //may want to introduce a tolerance variable to only fire 
  //when a certain difference is met 
  //to prevent it from being too jittery
  size(720, 720);
  background(0);
  madison = loadImage("madison.jpg");
  smooth();
  noStroke();
  noFill();
  
  frameRate(15);
}

void draw(){
  //reset the background on each run through
  image(madison, -280, 0);
  
  //read the FSRs if there isn't a current wave
  if(!waves){
    int FSR1 = readadc(0, SPICLK, SPIMOSI, SPIMISO, SPICS);
    int FSR2 = readadc(1, SPICLK, SPIMOSI, SPIMISO, SPICS);
    //int FSR3 = readadc(1, SPICLK, SPIMOSI, SPIMISO, SPICS);
    //int FSR4 = readadc(1, SPICLK, SPIMOSI, SPIMISO, SPICS);
    if(debug){
      println("pressure 1:" + FSR1);
      println("pressure 2:" + FSR2);
    }
    //if threshold for tolerence is met, fire main program
    if(FSR1 > FSR1_base || FSR2 > FSR2_base ){
      println("make waves");
      waves = true;
      a = random(width);
      b = random(height);
      r=1;
    }
  }
  
  if(waves){
   //find points on circle and put them in array
    for (int i = 0; i < numPoint; i++) {
      th = th + 360/numPoint;
      pointsFromCircle[i][0] = a + r*cos(th);
      pointsFromCircle[i][1] = b + r*sin(th);
      pointsFromInnerCircle[i][0] = a + (r-blur/1.5)*cos(th);
      pointsFromInnerCircle[i][1] = b + (r-blur/1.5)*sin(th);
      pointsFromOuterCircle[i][0] = a + (r+blur/1.5)*cos(th);
      pointsFromOuterCircle[i][1] = b + (r+blur/1.5)*sin(th);
    }
    //sample and blur points around circle
    for (int i = 0; i < numPoint; i++) {
      // Pick a point on the circle
      int x = int(round(pointsFromCircle[i][0]));
      int y = int(round(pointsFromCircle[i][1]));
      int loc = x + y*madison.width;
      int xInner = int(round(pointsFromInnerCircle[i][0]));
      int yInner = int(round(pointsFromInnerCircle[i][1]));
      int locInner = xInner + yInner*madison.width;
      int xOuter = int(round(pointsFromOuterCircle[i][0]));
      int yOuter = int(round(pointsFromOuterCircle[i][1]));
      int locOuter = xOuter + yOuter*madison.width;
  
      //skip this point if x or y are out of bounds
      if (x >= width | x <= 0 | y >= height | y <= 0) {
        //check if points are beyond corner boundary
        //if (loc > 3*(width + height*width)) { //too processor intesive to run it all the way to the edge
        if (r > 200) {
          waves = false;
          break;
        } else continue;
      } else ///println("x:"+x + "| y:"+y);
  
      // Look up the RGB color in the source image
      loadPixels();
      float r = red(madison.pixels[loc]);
      float rPlus = red(madison.pixels[loc]);
      float rMinus = red(madison.pixels[locInner]);
      float g = green(madison.pixels[loc]);
      float gPlus = green(madison.pixels[loc]);
      float gMinus = green(madison.pixels[locInner]);
      float b = blue(madison.pixels[loc]);
      float bPlus = blue(madison.pixels[loc]);
      float bMinus = blue(madison.pixels[locInner]);
  
      //make sure they are in bounds
      /*if (locInner > 0 && locInner < 921000) {
        rMinus = red(madison.pixels[locInner]);
        gMinus = green(madison.pixels[locInner]);
        bMinus = blue(madison.pixels[locInner]);
      }*/  //can't think of any times when the inner circle will be out of bounds
      if (locOuter < 921000 && locOuter > 0) {
        rPlus = red(madison.pixels[locOuter]);
        gPlus = green(madison.pixels[locOuter]);
        bPlus = blue(madison.pixels[locOuter]);
      }
      noStroke();
  
      // Draw an ellipse at that location with that color
      fill(r, g, b, 100);
      ellipse(x, y, blur, blur);
      //outer circle
      fill(rPlus, gPlus, bPlus, 50);
      ellipse(xOuter, yOuter, blur, blur);
      //inner circle
      fill(rMinus, gMinus, bMinus, 50);
      ellipse(xInner, yInner, blur, blur);
    }
  
    r += 10; 
  }
  println(frameRate);
}

// read SPI data from MCP3008 chip, 8 possible adc's (0 through 7)
int readadc(int adcnum, int clockpin, int mosipin, int misopin, int cspin){
  if((adcnum > 7) || (adcnum < 0)){
    return -1;
  }
  GPIO.digitalWrite(cspin, GPIO.HIGH);
  
  GPIO.digitalWrite(clockpin, GPIO.LOW); //start clock low
  GPIO.digitalWrite(cspin, GPIO.LOW);    //bring CS low
  
  int commandout = adcnum;
  commandout |= 0x18; //start bit is hex 24 + single-ended bit
  commandout <<= 3; //we only need to send 5 bits here
  for(int i = 0; i<5; i++){
    if((commandout & 0x80) > 0){
      GPIO.digitalWrite(mosipin, GPIO.HIGH);
    } else{
      GPIO.digitalWrite(mosipin, GPIO.LOW);
    }
    commandout <<= 1;
    GPIO.digitalWrite(clockpin, GPIO.HIGH);
    GPIO.digitalWrite(clockpin, GPIO.LOW);
  }
  
  int adcout = 0;
  //read in one empty bit, one null bit and 10 ADC bits
  for(int i = 0; i < 12; i++){
    GPIO.digitalWrite(clockpin, GPIO.HIGH);
    GPIO.digitalWrite(clockpin, GPIO.LOW);
    adcout <<= 1;
    if(GPIO.digitalRead(misopin)==GPIO.HIGH){
      adcout |= 0x1;
    }
  }
  
  GPIO.digitalWrite(cspin, GPIO.HIGH);
  
  adcout >>= 1; //first bit is 'null' so drop it
  return adcout;
}