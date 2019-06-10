#include <NeoSWSerial.h>

#define EN        8  

//Direction pin
#define X_DIR     5 
#define Y_DIR     6
#define Z_DIR     7

//Step pin
#define X_STP     2
#define Y_STP     3 
#define Z_STP     4 

char buff[64];


NeoSWSerial hc06(10,11);
//SoftwareSerial hc06(0,1);


//DRV8825
//int delayTime=100; //Delay between each pause (uS)
//int stps=6400;// Steps to move


void step(boolean dir, byte dirPin, byte stepperPin, long steps, int wait)

{
  digitalWrite(dirPin, dir);
  delay(100);
  for (long i = 0; i < steps; i++) {
    digitalWrite(stepperPin, HIGH);
    delayMicroseconds(wait); 
    digitalWrite(stepperPin, LOW);
    delayMicroseconds(wait); 
  }
}

void single_motor(int num, float dist, float speed){
  byte dirPin;
  int dir;
  byte stepPin;
  long steps;
  int wait;

  switch(num){
    case 1:
      dirPin = X_DIR;
      stepPin = X_STP;
      break;
    case 2:
      dirPin = Y_DIR;
      stepPin = Y_STP;
      break;
    case 3:
      dirPin = Z_DIR;
      stepPin = Z_STP;
      break;
  }

  dir = (dist>0);
  steps = (long)(dist*4096);
  wait = (int)(1e6/(speed*4096));

  step(dir, dirPin, stepPin, steps, wait);
}

void setup(){

  pinMode(X_DIR, OUTPUT); pinMode(X_STP, OUTPUT);
  pinMode(Y_DIR, OUTPUT); pinMode(Y_STP, OUTPUT);
  pinMode(Z_DIR, OUTPUT); pinMode(Z_STP, OUTPUT);
  // TODO W motor?

  pinMode(EN, OUTPUT);
  digitalWrite(EN, LOW);
  hc06.begin(9600);

  Serial.begin(9600);
  

  /*
  step(true, X_DIR, X_STP, 4096, 300);
  step(true, Y_DIR, Y_STP, 4096, 300);
  step(true, X_DIR, Z_STP, 4096, 300);

  delay(1000);

  single_motor(1, 1.0, 1.0);
  single_motor(2, 1.0, 1.0);
  single_motor(3, 1.0, 1.0);
  */
}

// read characters into the buffer until a space
void read_chars() {
  for(int i=0; i<63; i++){
      buff[i] = hc06.read();
      if(buff[i] == ' '){
        buff[i] = '\0';
        break;
      }
  }
}

void get_command(){
  if(hc06.available()){
    delay(100);
    
    // get motor number
    read_chars();
    int motor_num = atoi(buff);
    hc06.print("Received motor num ");
    hc06.println(motor_num);
    
    read_chars();
    float dist = atof(buff);
    hc06.print("Received dist roughly ");
    hc06.println((int)dist);
    
    read_chars();
    float speed = atof(buff);
    hc06.print("Received speed roughly ");
    hc06.println((int)speed);
  
    //single_motor(motor_num, dist, speed);
    hc06.println("Finished");
  }
}

void loop(){
    get_command();
}
