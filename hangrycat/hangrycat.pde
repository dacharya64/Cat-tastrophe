import processing.serial.*;
import cc.arduino.*;
import org.firmata.*;

Arduino arduino;
int analogPinA0 = 0;
int a0 = 0;
int Vin = 5; //input voltage
float Vout = 0; //converted analog inpt to Arduino
float R1 = 0; //resistance of the flex/bend sensor
float R2 = 10000; //resistance of the known resistor

int analogPinA1 = 1;
int a1 = 0;
int Vin1 = 5; //input voltage
float Vout1 = 0; //converted analog inpt to Arduino
float R3 = 0; //resistance of the flex/bend sensor
float R4 = 10000; //resistance of the known resistor

int analogPinA2 = 2;
int a2 = 0;
int Vin2 = 5; //input voltage
float Vout2 = 0; //converted analog inpt to Arduino
float R5 = 0; //resistance of the flex/bend sensor
float R6 = 10000; //resistance of the known resistor
int ledPin = 13;

int analogPinA3 = 3;
int a3 = 0;
int Vin3 = 5; //input voltage
float Vout3 = 0; //converted analog inpt to Arduino
float R7 = 0; //resistance of the flex/bend sensor
float R8 = 10000; //resistance of the known resistor

float hunger = 492;
float thirst = 492; 
float bathroom = 492; 

void setup()
{
  println(Arduino.list());
  //grab the first available Arduino board
  //when using the standard Firmata library, the baud rate is set to 57600
  arduino = new Arduino(this, Arduino.list()[0], 57600);
   //declare pin 13 to be the output
  arduino.pinMode(ledPin, Arduino.OUTPUT);
  //turn the LED on
  arduino.digitalWrite(ledPin, Arduino.HIGH);

  size(512, 512);
  background(100);
}

void draw()
{
  background(100);
  //draw the bar
  stroke(255);
  textSize(32);
  text("hunger", 10, 100); 
  rect(10, 120, hunger, 24);
  text("thirst", 10, 260); 
  rect(10, 280, thirst, 24);
  text("bathroom", 10, 400); 
  rect(10, 420, bathroom, 24);
  
  int rateMultiplier = millis() / 5000;
  hunger = hunger - .5 * rateMultiplier * 0.75; // use this to change how much the meter goes down by
  thirst = thirst - .5 * rateMultiplier *0.25;
  bathroom = bathroom - .2 * rateMultiplier;
  
  if (hunger < 1 || thirst < 1 || bathroom < 1 ) { // win condition
    background(0); 
    textSize(48);
    text("YOUR CAT IS DEAD", 10, 100); 
    text("YOUR CAT LIVED FOR \n" + millis() / 1000 + " SECONDS", 10, 140);
    noLoop();
  }
  
  // HUNGER
  a0 = arduino.analogRead(analogPinA0);
  if(a0 != 0) {  
    Vout = AnalogInputToVotage(a0, Vin);
    R1 = AnalogInputToResistance(a0, Vin, R2);
    if (492*Vout/Vin > 30 && hunger < 492) {
      hunger = hunger + 2;
    }
  }
  
  // THIRST
  a1 = arduino.analogRead(analogPinA1);
  if(a1 != 0) {
    Vout1 = AnalogInputToVotage(a1, Vin1);
    R3 = AnalogInputToResistance(a1, Vin1, R4);
    if (492*Vout1/Vin1 > 100 && thirst < 492) {
      thirst = thirst + 2;
    }
  }
  
  // BATHROOM
  a2 = arduino.analogRead(analogPinA2);
  a3 = arduino.analogRead(analogPinA3);
  if(a2 != 0 && a3 !=0) {
    Vout2 = AnalogInputToVotage(a2, Vin2);
    Vout3 = AnalogInputToVotage(a3, Vin3);
    R5 = AnalogInputToResistance(a2, Vin2, R6);
    R7 = AnalogInputToResistance(a3, Vin3, R8);
    if (Vout2 < 3.6 && 492*Vout3/Vin3 > 0 && bathroom < 492) { // If squatting and touching litter box sensor
      bathroom = bathroom + 10;
    }
  }
}

//void checkStat(int pinNum, float stat) {
//  pin = arduino.analogRead(pinNum);
//  if(pin != 0) {
//    Vout = AnalogInputToVotage(pin, Vin);
//    R1 = AnalogInputToResistance(pin, Vin, R2);
//    if (492*Vout/Vin > 30 && stat < 492) {
//      stat = stat + 2;
//      println(stat);
//    }
//  }
//}

float AnalogInputToVotage(int raw, int vin) {
  //the range of analog read is 0 and 1024, so scale it to 0 to Vin
  return raw * vin / 1024.0;
}

//connected like this: Vin -- R1(bend sensor) -- Vout(from analog input to Arduino) -- R2 -- GND
float AnalogInputToResistance(int raw, int vin, float r2) {
  return r2 * ( (vin / AnalogInputToVotage(raw, vin)) - 1);  
}
