//Based on code written by Limor "Ladyada" for Adafruit Industries
import processing.io.*;
import ddf.minim.*;
Minim minim;
AudioPlayer player;
// script uses Board numbers (IE Physical pin numbers)
// processing defaults to GPIO number, RPI to use physical pin numbers
// may need to convert pins to their RPI.PIN# versions here. 
int SPICLK = 18;
int SPIMISO = 23;
int SPIMOSI = 24;
int SPICS = 25;
//set up variables to keep track of base value
//everything has to be set up before running the program
int FSR1_base = readadc(0, SPICLK, SPIMOSI, SPIMISO, SPICS)+1;
int FSR2_base = readadc(1, SPICLK, SPIMOSI, SPIMISO, SPICS)+1;
int FSR3_base = readadc(2, SPICLK, SPIMOSI, SPIMISO, SPICS)+1;
int FSR4_base = readadc(3, SPICLK, SPIMOSI, SPIMISO, SPICS)+1;
int FSR1, FSR2, FSR3, FSR4;
//waves variables
PImage madison;
float a, b, r=10, th;
int numPoint = 200;
int blur = 30;
int endRadius = 50; //radius to dissipate
float[][] pointsFromCircle = new float[numPoint][numPoint];
float[][] pointsFromInnerCircle = new float[numPoint][numPoint];
float[][] pointsFromOuterCircle = new float[numPoint][numPoint];
boolean waves = false;
boolean sampleColors = true;
int x, y, loc, xInner, yInner, locInner, xOuter, yOuter, locOuter;
float red, redPlus, redMinus, green, greenPlus, greenMinus, blue, bluePlus, blueMinus;


boolean debug = true;

void setup() {
  minim = new Minim(this);
  player = minim.loadFile("BLMProtestInMadison.mp3");
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
  
  frameRate(30);
}

void draw(){
  //reset the background on each run through
  image(madison, -280, 0);
  
  //read the FSRs if there isn't a current wave
  if(!waves){
     //player.pause(); 
     
     FSR1 = readadc(0, SPICLK, SPIMOSI, SPIMISO, SPICS);
     FSR2 = readadc(1, SPICLK, SPIMOSI, SPIMISO, SPICS);
     FSR3 = readadc(2, SPICLK, SPIMOSI, SPIMISO, SPICS);
     FSR4 = readadc(3, SPICLK, SPIMOSI, SPIMISO, SPICS);
    if(debug){
      println("pressure 1:" + FSR1_base + " : " + FSR1);
      println("pressure 2:" + FSR2_base + " : " + FSR2);
      println("pressure 3:" + FSR3_base + " : " + FSR3);
      println("pressure 4:" + FSR4_base + " : " + FSR4);
    }
    //if threshold for tolerence is met, fire main program
    if(FSR1 > FSR1_base || FSR2 > FSR2_base || FSR3 > FSR3_base || FSR4 > FSR4_base ){
      println("make waves");
      player.play();
      sampleColors = true;
      waves = true;
      a = random(width);
      b = random(height);
      r=1;
    }
  }
  
  if(waves){
     player.play();
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
      x = int(round(pointsFromCircle[i][0]));
      y = int(round(pointsFromCircle[i][1]));
      loc = x + y*madison.width;
      xInner = int(round(pointsFromInnerCircle[i][0]));
      yInner = int(round(pointsFromInnerCircle[i][1]));
      locInner = xInner + yInner*madison.width;
      xOuter = int(round(pointsFromOuterCircle[i][0]));
      yOuter = int(round(pointsFromOuterCircle[i][1]));
      locOuter = xOuter + yOuter*madison.width;
  
      //skip this point if x or y are out of bounds
      if (x >= width | x <= 0 | y >= height | y <= 0) {
        //check if points are beyond corner boundary
        //if (loc > 3*(width + height*width)) { //too processor intesive to run it all the way to the edge
        if (r > endRadius ) {
          waves = false;
          break;
        } else continue;
      } else ///println("x:"+x + "| y:"+y);
  
      // Look up the RGB color in the source image if its the first time through
      if(sampleColors){
        loadPixels();
        //use bit shifting for faster color loading
        red = (madison.pixels[loc] >> 16) & 0xFF;
        redPlus = (madison.pixels[loc] >> 16) & 0xFF;
        redMinus = (madison.pixels[loc] >> 16) & 0xFF;
        green = (madison.pixels[loc] >> 8) & 0xFF;
        greenPlus = (madison.pixels[loc] >>8) & 0xFF;
        greenMinus = (madison.pixels[loc] >>8) & 0xFF;
        blue = (madison.pixels[loc]) & 0xFF;
        bluePlus = (madison.pixels[loc]) & 0xFF;
        blueMinus = (madison.pixels[loc]) & 0xFF;
    
        //make sure they are in bounds
        if (locInner > 0 && locInner < 921000) {
          redMinus = red(madison.pixels[locInner]);
          greenMinus = green(madison.pixels[locInner]);
          blueMinus = blue(madison.pixels[locInner]);
        } 
        if (locOuter < 921000 && locOuter > 0) {
          redPlus = (madison.pixels[locOuter] >> 16) & 0xFF;
          greenPlus = (madison.pixels[locOuter] >> 8) & 0xFF;
          bluePlus = (madison.pixels[locOuter]) & 0xFF;
        }
        sampleColors = false;
      }
      noStroke();
  
      // Draw an ellipse at that location with that color
      fill(red, green, blue, 100);
      ellipse(x, y, blur, blur);
      //outer circle
      fill(redPlus, greenPlus, bluePlus, 50);
      ellipse(xOuter, yOuter, blur, blur);
      //inner circle
      fill(redMinus, greenMinus, blueMinus, 50);
      ellipse(xInner, yInner, blur, blur);
    }
  
    r += 10; 
  } else {
    player.pause();
  }
  //println(frameRate);
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
    //for some reason there is a problem with this everytime I reboot.
    //to fix: Set the below to 1 == 1 and run.
    //then cmd + z  to revert to the below and it will work.
    if(GPIO.digitalRead(misopin)==GPIO.HIGH){
      adcout |= 0x1;
    }
  }
  
  GPIO.digitalWrite(cspin, GPIO.HIGH);
  
  adcout >>= 1; //first bit is 'null' so drop it
  return adcout;
}