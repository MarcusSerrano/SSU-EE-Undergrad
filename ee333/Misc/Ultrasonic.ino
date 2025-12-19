#include <Wire.h>
#define echoPin 13  // CHANGE PIN NUMBER HERE IF YOU WANT TO USE A DIFFERENT PIN
#define trigPin 15  // CHANGE PIN NUMBER HERE IF YOU WANT TO USE A DIFFERENT PIN
short duration, distance, median;
short durationarray[3];
int x;
void setup() {
  Serial.begin(9600);
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
}
void loop() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

for (x = 0; x < 3; x++) {
  durationarray[x] = pulseIn(echoPin, HIGH);
  delay(500);  // half second delay
}

  median = durationarray[1];

  //duration = pulseIn(echoPin, HIGH);

  distance = durationarray[1] / 58.2;

  String disp = String(distance);

  Serial.print("Distance: ");
  Serial.print(disp);
  Serial.println(" cm");
  delay(1000);
}