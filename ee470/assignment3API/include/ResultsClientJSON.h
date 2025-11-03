// ResultsClientJSON.h
#pragma once
#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClientSecure.h>

class ResultsClientJSON {
 public:
  explicit ResultsClientJSON(const char* url) : _url(url) {}

  // NEW: includes 'on' flag
  bool fetchRGB(uint8_t &r, uint8_t &g, uint8_t &b, bool &on) {
    if (WiFi.status() != WL_CONNECTED) {
      Serial.println("WiFi not connected.");
      return false;
    }

    WiFiClientSecure client; client.setInsecure();
    HTTPClient http;
    Serial.println("Fetching results2.txt...");
    if (!http.begin(client, _url)) return false;
    int code = http.GET();
    if (code != HTTP_CODE_OK) {
      Serial.printf("HTTP error: %d\n", code);
      http.end();
      return false;
    }
    String payload = http.getString();
    http.end();

    payload.trim();
    Serial.print("Response: "); Serial.println(payload);

    int rr = parseIntField(payload, "Red");
    int gg = parseIntField(payload, "Green");
    int bb = parseIntField(payload, "Blue");
    int onv = parseBoolField(payload, "On");  // -1 = not found

    if (rr < 0 || gg < 0 || bb < 0) {
      Serial.println("Parse error (RGB).");
      return false;
    }
    r = (uint8_t)constrain(rr, 0, 255);
    g = (uint8_t)constrain(gg, 0, 255);
    b = (uint8_t)constrain(bb, 0, 255);

    // If "On" missing, default to true (backward compatibility)
    on = (onv < 0) ? true : (onv > 0);
    return true;
  }

 private:
  // looks for "key": <number>
  static int parseIntField(const String& s, const char* key) {
    String pat = "\"" + String(key) + "\"";
    int k = s.indexOf(pat); if (k < 0) return -1;
    int colon = s.indexOf(':', k + pat.length()); if (colon < 0) return -1;
    int i = colon + 1;
    while (i < (int)s.length() && isspace(s[i])) i++;
    String num;
    while (i < (int)s.length() && isDigit(s[i])) { num += s[i]; i++; }
    if (num.length() == 0) return -1;
    return num.toInt();
  }

  // accepts true/false OR 1/0; returns 1 for true, 0 for false, -1 if not found
  static int parseBoolField(const String& s, const char* key) {
    String pat = "\"" + String(key) + "\"";
    int k = s.indexOf(pat); if (k < 0) return -1;
    int colon = s.indexOf(':', k + pat.length()); if (colon < 0) return -1;
    int i = colon + 1;
    while (i < (int)s.length() && isspace(s[i])) i++;
    // match true/false
    if (s.startsWith("true", i))  return 1;
    if (s.startsWith("false", i)) return 0;
    // fallback: numeric 1/0
    if (i < (int)s.length() && (s[i] == '0' || s[i] == '1')) return (s[i] == '1') ? 1 : 0;
    return -1;
  }

  const char* _url;
};
