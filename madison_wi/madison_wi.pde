import processing.io.*;

//Based on code written by Limor "Ladyada" for Adafruit Industries


void setup() {
  boolean debug = true;
  
  // script uses Board numbers (IE Physical pin numbers)
  // processing defaults to GPIO number, RPI to use physical pin numbers
  // may need to convert pins to their RPI.PIN# versions here. 
  int SPICLK = RPI.PIN18;
  int SPIMISO = RPI.PIN23;
  int SPIMOSI = RPI.PIN24;
  int SPICS = RPI.PIN25;
  
  //set up the SPI interface
  GPIO.pinMode(SPIMOSI, GPIO.OUTPUT);
  GPIO.pinMode(SPIMISO, GPIO.OUTPUT);
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
  int FSR2 = readadc(1, SPICLK, SPIMOSI, SPIMISO, SPICS);
  //int FSR3 = readadc(1, SPICLK, SPIMOSI, SPIMISO, SPICS);
  //int FSR4 = readadc(1, SPICLK, SPIMOSI, SPIMISO, SPICS);
  
  
  if(debug){
    println("pressure 1:" + FSR1);
    println("pressure 2:" + FSR2);
  }
  
  //if threshold for tolerence is met, fire main program
  
  
}

// read SPI data from MCP3008 chip, 8 possible adc's (0 through 7)
int readadc(int adcnum, int clockpin, int mosipin, int misopin, int cspin){
  if((adcnum > 7) || (adcnum < 0)){
    return -1;
  }
  GPIO.digitalWrite(cspin, true);
  
  GPIO.digitalWrite(clockpin, false); //start clock low
  GPIO.digitalWrite(cspin, false);    //bring CS low
  
  int commandout = adcnum;
  commandout |= 0x18; //start bit is hex 24 + single-ended bit
  commandout <<= 3; //we only need to send 5 bits here
  for(int i = 0; i<5; i++){
    if(commandout & 0x80){
      GPIO.digitalWrite(mosipin, true);
    } else{
      GPIO.digitalWrite(mosipin, false);
    }
    commandout <<= 1;
    GPIO.digitalWrite(clockpin, true);
    GPIO.digitalWrite(clockpin, false;
  }
  
  adcout = 0;
  //read in one empty bit, one null bit adn 10 ADC bits
  for(int i = 0; i < 12; i++){
    GPIO.digitalWrite(clockpin, true);
    GPIO.digitalWrite(clockpin, true);
    adcout <<= 1;
    if(GPIO.digitalRead(misopin)){
      adcout |= 0x1;
    }
  }
  
  GPIO.digitalWrite(cspin, true);
  
  adcout >>= 1; //first bit is 'null' so drop it
  return adcout;
}