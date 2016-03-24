//import processing.io.*;

//Based on code written by Limor "Ladyada" for Adafruit Industries


int debug = 1;

void setup() {
  
}

void draw(){
  // may need to convert pins to their RPI.PIN# versions here. 
  int test = 0x18;
  println(binary(test));
}


int readadc(int adcnum, int clockpin, int mosipin, int misopin, int cspin){
  if((adcnum > 7) || (adcnum < 0)){
    return -1;
  }
  GPIO.digitalWrite(cspin, true);
  
  GPIO.digitalWrite(clockpin, false); //start clock low
  GPIO.digitalWrite(cspin, false);    //bring CS low
  
  int commandout = adcnum;
  commandout |= 0x18; //start bit + single-ended bit
}