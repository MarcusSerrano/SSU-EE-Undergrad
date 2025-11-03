#pragma once

// Wi-Fi settings
// Home PC
//const char* WIFI_SSID     = "DESKTOP-38G0AHI 4388";
//const char* WIFI_PASSWORD = "/13x12L3";
// Laptop
const char* WIFI_SSID     = "DESKTOP-16CTLBL";
const char* WIFI_PASSWORD = "1?8e658Y";

// Remote file URL
const char* URL_RESULTS   = "https://marcusinternetofthings.com/results.txt";

// Hardware settings
const uint8_t LED_PIN = 2;         // GPIO2 (onboard LED)
const bool LED_ACTIVE_LOW = true;  // most ESP8266 boards use active-low
#define BUTTON_PIN 12   // D6

// Update interval
const unsigned long POLL_MS = 120000;

// Serial baud rate
const int BAUD = 9600;         // Serial baud rate

// RGB hardware (choose your pins)
const uint8_t RED_PIN   = 5;  // D1
const uint8_t GREEN_PIN = 4;  // D2
const uint8_t BLUE_PIN  = 14;  // D5
const bool RGB_ACTIVE_LOW = false;  // set false if your strip/LED is active-high

// JSON results file from the webpage sliders
const char* URL_RESULTS_RGB = "https://marcusinternetofthings.com/results2.txt";
