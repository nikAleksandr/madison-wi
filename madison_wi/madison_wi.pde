//Based on code written by Limor "Ladyada" for Adafruit Industries
import processing.io.*;
// script uses Board numbers (IE Physical pin numbers)
// processing defaults to GPIO number, RPI to use physical pin numbers
// may need to convert pins to their RPI.PIN# versions here. 
int SPICLK = 18;
int SPIMISO = 23;
int SPIMOSI = 24;
int SPICS = 25;

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
  
  frameRate(0.5);
}

void draw(){
  //read the FSRs
  int FSR1 = readadc(0, SPICLK, SPIMOSI, SPIMISO, SPICS);
  //int FSR2 = readadc(1, SPICLK, SPIMOSI, SPIMISO, SPICS);
  //int FSR3 = readadc(1, SPICLK, SPIMOSI, SPIMISO, SPICS);
  //int FSR4 = readadc(1, SPICLK, SPIMOSI, SPIMISO, SPICS);
  
  
  if(debug){
    println("pressure 1:" + FSR1);
    //println("pressure 2:" + FSR2);
  }
  
  //if threshold for tolerence is met, fire main program
  
  
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