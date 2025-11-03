#include <Arduino.h>
#include "config.h"
#include "WiFiHelper.h"
#include "LedController.h"
#include "ResultsClient.h"
#include "RgbLedController.h"
#include "ResultsClientJSON.h"

// -----------------------------------------------------------------------------
// Existing single LED system (from results.txt)
LedController led(LED_PIN, LED_ACTIVE_LOW);
ResultsClient client(URL_RESULTS);

// New RGB LED system (from results2.txt)
RgbLedController rgb(RED_PIN, GREEN_PIN, BLUE_PIN, RGB_ACTIVE_LOW);
ResultsClientJSON rgbClient(URL_RESULTS_RGB);

// -----------------------------------------------------------------------------
void setup() {
  Serial.begin(BAUD);
  Serial.println();
  Serial.println("Booting...");

  // Initialize hardware
  led.begin();
  rgb.begin();
  pinMode(BUTTON_PIN, INPUT_PULLUP);   // active low button (press to GND)

  // Connect WiFi
  WiFiHelper::connect(WIFI_SSID, WIFI_PASSWORD);

  Serial.println("Setup complete.");
}

// -----------------------------------------------------------------------------
void loop() {
  static uint8_t r = 0, g = 0, b = 0;
  static bool rgbOn = true;
  static bool wantOn = false;

  // --- Regular periodic fetch ---
  bool fetchNow = (millis() % POLL_MS == 0);

  // --- Immediate fetch if button pressed (active low) ---
  if (digitalRead(BUTTON_PIN) == LOW) {
    Serial.println("Button pressed — refreshing LEDs from webpage!");
    fetchNow = true;
  }

  if (fetchNow) {
    // Fetch simple LED on/off
    if (client.fetchDesiredState(wantOn)) {
      led.set(wantOn);
      Serial.print("Single LED is now: ");
      Serial.println(wantOn ? "ON" : "OFF");
    }

    // Fetch RGB JSON
    if (rgbClient.fetchRGB(r, g, b, rgbOn)) {
      if (rgbOn) {
        rgb.set(r, g, b);
        Serial.printf("RGB ON  -> R:%u  G:%u  B:%u\n", r, g, b);
      } else {
        rgb.set(0, 0, 0);
        Serial.println("RGB OFF");
      }
    }
  }

  delay(10); // small delay for stability
}

