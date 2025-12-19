#include "DHT.h"

// Hardware
#define DHTPIN 3       // DHT11 data pin
#define DHTTYPE DHT11  // define DHT Type for library
#define HEATERPIN 2    // digital pin for manual PWM

DHT dht(DHTPIN, DHTTYPE);

// PID Constants
float Kp = 300;
float Ki = 3.3;
float Kd = 6750;

// Control Variables
float setPoint = 85;  // °F
float inputTemp = 0;
float error, lastError = 0;
float integralTerm = 0;
float derivative = 0;
float output = 0;

// PWM and Timing variables
float sampleTime = 10000;  // PID update interval (ms)
float pwmPeriod = 1000;   // PWM period (ms)
float lastPidTime = 0;
float dutyCycle = 0;
float ton = 0;
float toff = 0;


void setup() {
  pinMode(HEATERPIN, OUTPUT);
  Serial.begin(9600);
  dht.begin();
}

void loop() {
  // https://docs.arduino.cc/language-reference/en/functions/time/millis/
  // Returns the number of milliseconds passed since the Arduino board began running the current program. This number will overflow (go back to zero), after approximately 50 days.
  float now = millis();

  // PID Update when enough time passes
  if (now - lastPidTime >= sampleTime) {
    lastPidTime = now;

    //  taken From DHT Tester library
    float t = dht.readTemperature(true);  // temperature in °F
    if (isnan(t)) {
      Serial.println(F("DHT read error"));
      return;
    }
    inputTemp = t;

    // PID Calculaions
    error = setPoint - inputTemp;
    integralTerm += Ki * error * (sampleTime / 1000.0);  // equivalent to the expression x = x + y;
    integralTerm = constrain(integralTerm, 0, 255);      // https://docs.arduino.cc/language-reference/en/functions/math/constrain/
    derivative = (error - lastError) / (sampleTime / 1000.0);
    output = Kp * error + integralTerm + Kd * derivative;
    output = constrain(output, 0, 255);  // https://docs.arduino.cc/language-reference/en/functions/math/constrain/

    // convert to [0.0,1.0]
    dutyCycle = output / 255.0;

    // print ALL values
    Serial.print(F("T ="));
    Serial.print(inputTemp);
    Serial.print(F(" SetPoint ="));
    Serial.print(setPoint);
    Serial.print(F(" Error ="));
    Serial.print(error);
    Serial.print(F(" Output ="));
    Serial.print(output);
    Serial.print(F(" Duty Cycle ="));
    Serial.println(dutyCycle, 2);

    // print only temperature
    // Serial.println(inputTemp);

    lastError = error;
  }

  // Calculate on/off times
  ton = pwmPeriod * dutyCycle;
  toff = pwmPeriod - ton;

  digitalWrite(HEATERPIN, HIGH);
  delay(ton);
  digitalWrite(HEATERPIN, LOW);
  delay(toff);

}
