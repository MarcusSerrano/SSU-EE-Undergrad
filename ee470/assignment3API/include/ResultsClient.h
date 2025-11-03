#pragma once
#include <ESP8266HTTPClient.h>
#include <WiFiClientSecure.h>

class ResultsClient {
 public:
  explicit ResultsClient(const char* url) : _url(url) {}

  bool fetchDesiredState(bool &wantOn) {
    if (WiFi.status() != WL_CONNECTED) {
      Serial.println("WiFi not connected.");
      return false;
    }

    WiFiClientSecure client;
    client.setInsecure();
    HTTPClient http;

    Serial.println("Fetching results.txt...");
    http.begin(client, _url);
    int code = http.GET();
    if (code != HTTP_CODE_OK) {
      Serial.print("HTTP error: ");
      Serial.println(code);
      http.end();
      return false;
    }

    String payload = http.getString();
    http.end();

    payload.trim();
    Serial.print("Response: ");
    Serial.println(payload);

    wantOn = (payload == "on");
    return true;
  }

 private:
  const char* _url;
};
