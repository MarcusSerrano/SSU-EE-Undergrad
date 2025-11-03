#pragma once
#include <ESP8266WiFi.h>

class WiFiHelper {
 public:
  static void connect(const char* ssid, const char* password) {
    WiFi.mode(WIFI_STA);
    WiFi.begin(ssid, password);

    Serial.println("Attempting WiFi connection");
    while (WiFi.status() != WL_CONNECTED) {
      delay(250);
      Serial.print(".");
    }
    Serial.println();
    Serial.println("WiFi connected!");
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());
  }
};
