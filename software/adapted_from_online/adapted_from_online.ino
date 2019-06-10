/**
 *  
 *  Version 2 - cleaned code a little and added limit switch functionality
 *  
 *  NOTE: This is specific to my setup, but you can modify it to match yours.
 *        Change the function "oneStep" to move your steppers/servos.
 *        You will certainly have to change the parameters below, labeled as
 *        "Set these variables to match your setup".
 *  
 *  This complements the SVG image reader.
 *  Recieves coordinate data via hc06.
 *  Controls motors for x and y axes as well as raising and lowering a pen.
 *  The exact details of the motor control will have to be changed
 *  to match your setup.
 *  
 *  Copyright 2014 Eric Heisler
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License version 3 as published by
 *  the Free Software Foundation.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *  
 *  The SVG vector graphics file type is specified by and belongs to W3C
 */
#include <NeoSWSerial.h>

////////////////////////////////////////////////////////////////////////////////
// Set these variables to match your setup                                  ////
////////////////////////////////////////////////////////////////////////////////
// step parameters                                                          ////
const float stepSize[2] = {.003, 0.003}; // mm per step [x, y]              ////
const long fastDelay[2] = {50, 50}; // determines movement speed by            ////
//const long slowDelay[2] = {100, 200}; // delaying milliseconds after each step   ////
// enable and phase pins for each motor                                     ////

// enable for motors
#define EN        8  
//Direction pins
#define X_DIR     5 
#define Y_DIR     6
#define Z_DIR     7
//#define W_DIR   -1

//Step pins
#define X_STP     2
#define Y_STP     3 
#define Z_STP     4 
//#define W_STP   -1     

// z axis control pins                                                      ////
const long uppin = 4;                                                        ////
const long downpin = 5;                                                      ////
// for breadboard version
//const long uppin = 7;                                                        ////
//const long downpin = 8;                                                      ////
// limit pins                                                               ////
const boolean hasLimits = false;                                            ////
const long xlimitPin = 2; // If you have enough pins and want limit switches ////
const long ylimitPin = 3;                                                    ////
// the hc06 rate
#define SRATE 9600


NeoSWSerial hc06(0,1);


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// the current position
float posmm[2];
long poss[2];
// the current motor states
long mstate[2]; // 0=+off 1=+- 2=off- 3=-- 4=-off 5=-+ 6=off+ 7=++
// motor speed delay
long useDelay[2];
// if it is touching the limits
volatile boolean xlimit, ylimit;

// used by the drawing function
long xSteps, ySteps;
long xdir, ydir;
float slope;
long dx, dy;

// used for hc06 communication
char inputchars[10];
long charcount;
float newx, newy;
long sign;
boolean started;
boolean zdown;

void setup(){
  //Serial.begin(9600);
  //Serial.println("Top of setup, new\n");
  
  pinMode(X_DIR, OUTPUT); pinMode(X_STP, OUTPUT);
  pinMode(Y_DIR, OUTPUT); pinMode(Y_STP, OUTPUT);
  pinMode(Z_DIR, OUTPUT); pinMode(Z_STP, OUTPUT);
  // TODO W motor?

  pinMode(EN, OUTPUT);
  digitalWrite(EN, LOW);
  
  pinMode(uppin, OUTPUT);
  pinMode(downpin, OUTPUT);

  // LED
  pinMode(13, OUTPUT);
  
  if(hasLimits){
    pinMode(xlimitPin, OUTPUT);
    pinMode(ylimitPin, OUTPUT);
  }
  
  // put both motors in state 0 = +off
  digitalWrite(X_STP, LOW);
  digitalWrite(Y_STP, LOW);
  digitalWrite(Z_STP, LOW);
  
  
  digitalWrite(uppin, LOW);
  digitalWrite(downpin, LOW);
  delay(500);
  
  useDelay[0] = fastDelay[0];
  useDelay[1] = fastDelay[1];
  
  // initialize the numbers
  posmm[0] = 1200.0;
  posmm[1] = 1200.0;
  poss[0] = 0;
  poss[1] = 0;
  xlimit = false;
  ylimit = false;
  
  // for limit switches
  if(hasLimits){
    attachInterrupt(0, hitXLimit, CHANGE);
    attachInterrupt(1, hitYLimit, CHANGE);
  }

  // set up the hc06 stuff
  hc06.begin(SRATE);
  started = false;
  zdown = true;
  
  //if you have limit switches
  if(hasLimits){
    goHome();
  }
  
  posmm[0] = 0.0;
  posmm[1] = 0.0;
  poss[0] = 0;
  poss[1] = 0;
  
  //if you have limit switches
  if(hasLimits){
    findCenter();
  }
  
  // wait for processing to connect
  while(!hc06.available()){
    if((millis()/1000)%2){
      digitalWrite(13, HIGH);
    }else{
      digitalWrite(13, LOW);
    }
  }
  if(hc06.read() == '#'){
    hc06.write('@');
    ////Serial.println("Did the response\n");
  } else {
    ////Serial.println("Got unexpected char in setup ");
  }
  ////Serial.println("Bottom of setup\n");
}


void loop() {
  // wait for data to come
  while(!hc06.available()){
    if((millis()/300)%2){
      digitalWrite(13, HIGH);
    }else{
      digitalWrite(13, LOW);
    }
  }

  char c = hc06.read();
  
  // the char '#' is a comm check. reply with '@'
  // start if the char 'S' is sent, finish if 'T' is sent
  if(c == '#'){
    hc06.write('@');
  }else if(c == 'S'){
    // drawing started
    started = true;
    zdown = false;
  }else if(c == 'T'){
    // drawing finished
    started = false;
    raisePen();
    drawLine(0.0, 0.0);
    posmm[0] = 0.0;
    posmm[1] = 0.0;
    poss[0] = 0;
    poss[1] = 0;
  }else if(c == 'A'){
    // raise pen
    if(zdown){
      raisePen();
      zdown = false;
    }
    hc06.write('A');
  }else if(c == 'Z'){
    // lower pen
    if(!zdown){
      lowerPen();
      zdown = true;
    }
    hc06.write('Z');
  }else if(c == 'L'){
    // if there is some hc06 data, read it, parse it, use it
    boolean complete = false;
    char tmpchar;
    while(!hc06.available()){
      ////Serial.println("Waiting for X float");
    }
    if (hc06.available() > 0) {
      charcount = 0;
      complete = false;
      newx = 0;
      sign = 1;
      while(!complete){
        // wait for x data
        while(hc06.available() < 1);
        tmpchar = hc06.read();
        if(tmpchar == '.'){ // signals end of number
          complete = true;
          continue;
        }
        if(tmpchar == '-'){
          sign = -1;
        }else{
          newx = newx*10.0 + tmpchar-'0';
        }
        charcount++;
      }
      newx = newx*sign/10000.0;
      while(hc06.available() > 0){
        char temp = hc06.read(); // clear the port
        ////Serial.print("Just cleared from port ");
        ////Serial.println(temp);
      }
      hc06.write(charcount); // write a verification byte
    }
    // wait for the y data
    while(hc06.available() < 1);
    ////Serial.println("About to take y data");
    if (hc06.available() > 0) {
      charcount = 0;
      complete = false;
      newy = 0;
      sign = 1;
      while(!complete){
        while(!hc06.available());
        tmpchar = hc06.read();
        if(tmpchar == '.'){
          complete = true;
          continue;
        }
        if(tmpchar == '-'){
          sign = -1;
        }else{
          newy = newy*10.0 + tmpchar-'0';
        }
        charcount++;
      }
      newy = newy*sign/10000.0;
      while(hc06.available() > 0){
        hc06.read(); // clear the port
      }
      hc06.write(charcount); // send verification byte
    }
    // now we have newx and newy. 
    //Serial.println("Received data, now gonna move");
    //Serial.print(newx);
    //Serial.print("\t");
    //Serial.print(newy);
    //Serial.print("\n");
    drawLine(newx, newy);
    //Serial.println("Done moving");
    hc06.write('L');

  /*}
  else if (abc){

  boolean complete = false;
    char tmpchar;
    while(!hc06.available()){
      ////Serial.println("Waiting for X float");
    }
    if (hc06.available() > 0) {
      charcount = 0;
      complete = false;
      newx = 0;
      sign = 1;
      while(!complete){
        // wait for x data
        while(hc06.available() < 1);
        tmpchar = hc06.read();
        if(tmpchar == '.'){ // signals end of number
          complete = true;
          continue;
        }
        if(tmpchar == '-'){
          sign = -1;
        }else{
          newx = newx*10.0 + tmpchar-'0';
        }
        charcount++;
      }
    }
    */
  }else{
    // it was some unexpected transmission
    // clear it
    ////Serial.print("Unexpected character ");
    ////Serial.println(c);
  }
  
}


long pen_range = 256*8;
long pen_delay = 300;
/* TODO */
void raisePen(){
  digitalWrite(Z_DIR, HIGH);
  for(int i=0; i<pen_range; i++){
    digitalWrite(uppin, HIGH);
    delayMicroseconds(pen_delay);
    digitalWrite(uppin, LOW);
    delayMicroseconds(pen_delay);
  }
}

void lowerPen(){
  digitalWrite(Z_DIR, LOW);
  for(int i=0; i<pen_range; i++){
    digitalWrite(uppin, HIGH);
    delayMicroseconds(pen_delay);
    digitalWrite(uppin, LOW);
    delayMicroseconds(pen_delay);
  }
}


/*
* moves the pen in a straight line from the current position
* to the polong (x2, y2)
*/
void drawLine(float x2, float y2){
  //Serial.print("Current XY \t");
  //Serial.print(posmm[0]);
  //Serial.println(posmm[1]);
  useDelay[0] = fastDelay[0];
  useDelay[1] = fastDelay[1];
  // determine the direction and number of steps
  xdir = 1;
  if(x2-posmm[0] < 0 ) xdir = -1;
  xSteps = long((x2-posmm[0])/stepSize[0] + 0.5*xdir);
  //Serial.print("xSteps is ");
  //Serial.println(xSteps);
  ydir = 1;
  if(y2-posmm[1] < 0) ydir = -1;
  ySteps = long((y2-posmm[1])/stepSize[1] + 0.5*ydir);
  //Serial.print("ySteps is ");
  //Serial.println(ySteps);
  if(xSteps*xdir > 0){
    slope = ySteps*1.0/(1.0*xSteps)*ydir*xdir;
  }else{
    slope = 9999;
  }

  //Serial.print("Slope is ");
  //Serial.println(slope);
  //Serial.print("Xdir is ");
  //Serial.println(xdir);
  //Serial.print("x2 is ");
  //Serial.println(x2);
  //Serial.print("posmm[0] is ");
  //Serial.println(posmm[0]);
  //Serial.print("stepSize[0] is ");
  //Serial.println(stepSize[0]);
  
  dx = 0;
  dy = 0;

  if(xSteps*xdir > ySteps*ydir){
    while(dx < xSteps*xdir){
      if(xlimit || ylimit){
        // we hit a limit. back off the switch, and return
        oneStep(0, -xdir);
        oneStep(0, -xdir);
        oneStep(1, -ydir);
        oneStep(1, -ydir);
        return;
      }
      // move one x step at a time
      dx++;
      oneStep(0, xdir);
      // if needed, move y one step
      if(ySteps*ydir > 0 && slope*dx > dy+0.5){
        dy++;
        oneStep(1, ydir);
      }
    }
  }
  else{
    while(dy < ySteps*ydir){
      if(xlimit || ylimit){
        // we hit a limit. back off the switch, and return
        oneStep(0, -xdir);
        oneStep(0, -xdir);
        oneStep(1, -ydir);
        oneStep(1, -ydir);
        return;
      }
      // move one y step at a time
      dy++;
      oneStep(1, ydir);
      // if needed, move x one step
      if(xSteps*xdir > 0 && dy > slope*(dx+0.5)){
        dx++;
        oneStep(0, xdir);
      }
    }
  }
  // at this polong we have drawn the line
}

void oneStep(long m, long dir){
  // make one step with motor number m in direction dir
  // then delay for useDelay millis
  
  byte dirPin;
  byte stepPin;
  posmm[m] += stepSize[m]*dir;

  switch(m){
    case 0:
      dirPin = X_DIR;
      stepPin = X_STP;
      break;
    case 1:
      dirPin = Y_DIR;
      stepPin = Y_STP;
      break;
    case 2:
      dirPin = Z_DIR;
      stepPin = Z_STP;
      break;
  }
  digitalWrite(dirPin, dir);
  digitalWrite(stepPin, HIGH);
  delayMicroseconds(useDelay[m]/2); 
  digitalWrite(stepPin, LOW);
  delayMicroseconds(useDelay[m]/2); 
}









///////////////////////////////////////////////////////////////////////////
// these functions are for limit switches only. I have not tested them
///////////////////////////////////////////////////////////////////////////
void goHome(){
  // just go in the -x and -y directions until you hit the limit switches
  useDelay[0] = fastDelay[0];
  useDelay[1] = fastDelay[1];
  while(!xlimit && !ylimit){
    oneStep(0, -1);
    oneStep(1, -1);
  }
  while(!xlimit){
    oneStep(0, -1);
  }
  while(!ylimit){
    oneStep(1, -1);
  }
  // back off the switches
  oneStep(0, 1);
  oneStep(1, 1);
  oneStep(0, 1);
  oneStep(1, 1);
}

void findCenter(){
  // travel over the full range then go to the center
  goHome();
  useDelay[0] = fastDelay[0];
  useDelay[1] = fastDelay[1];
  while(!xlimit && !ylimit){
    oneStep(0, 1);
    oneStep(1, 1);
  }
  while(!xlimit){
    oneStep(0, 1);
  }
  while(!ylimit){
    oneStep(1, 1);
  }

  long maxx = poss[0];
  long maxy = poss[1];
  while(poss[0] > maxx/2 && poss[1] > maxy/2){
    oneStep(0, -1);
    oneStep(1, -1);
  }
  while(poss[0] > maxx/2){
    oneStep(0, -1);
  }
  while(poss[1] > maxy/2){
    oneStep(1, -1);
  }
}


void hitXLimit(){
  if(digitalRead(xlimitPin) == HIGH){
    xlimit = true;
  }
  else{
    xlimit = false;
  }
}

void hitYLimit(){
  if(digitalRead(ylimitPin) == HIGH){
    ylimit = true;
  }
  else{
    ylimit = false;
  }
}
////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////
