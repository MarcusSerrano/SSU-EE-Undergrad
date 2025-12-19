/*
---------------------------
Title: 8266_myfirstblink
---------------------------
Program Details:
---------------------------
Purpose: Blinks the onboard LED of the ESP8266
Inputs: Serial Monitor (letters A or B)
Outputs: LED blink + serial messages
Date: 9/29/25
Compiler: Simulator Version 6.8
Author: Marcus Serrano
Versions:
         V1 - Initial creation
         V2 - Added serial monitor
         V3 - Added user-controlled blink speed
---------------------------
File Dependencies:
Arduino.h
---------------------------
Main Program
---------------------------
*/
#include <Arduino.h>

int d = 1000;  // blink delay (ms)

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  Serial.begin(9600);
  Serial.println("Send 'a' for faster blink, 'b' for slower blink");
}

void loop() {
  // check if user sent input
  if (Serial.available() > 0) {
    char c = Serial.read();   // read one character
    if (c == 'a') {
      d = 200;       // faster blink
      Serial.println("Blink speed set to FAST (200ms)");
    } else if (c == 'b') {
      d = 1000;      // slower blink
      Serial.println("Blink speed set to SLOW (1000ms)");
    }
  }

  // blink the LED
  digitalWrite(LED_BUILTIN, HIGH);
  Serial.println("LED on");
  delay(d);

  digitalWrite(LED_BUILTIN, LOW);
  Serial.println("LED off");
  delay(d);
}
