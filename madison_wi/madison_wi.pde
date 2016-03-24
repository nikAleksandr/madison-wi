//import processing.io.*;

//Based on code written by Limor "Ladyada" for Adafruit Industries


int debug = 1;

void setup() {
  
}

void draw(){
  // may need to convert pins to their RPI.PIN# versions here. 
  
}


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