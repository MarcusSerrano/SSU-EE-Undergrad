// main.cpp
#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClientSecureBearSSL.h>
#include <ArduinoJson.h>     // v7
#include <DHT.h>

// =======================
// Wi-Fi & Endpoints
// =======================
const char* WIFI_SSID = "DESKTOP-16CTLBL";
const char* WIFI_PASS = "1?8e658Y";

//const char* WIFI_SSID = "marcus"; 
//const char* WIFI_PASS = "wecwecwec";


const char* URL_TIME = "https://timeapi.io/api/Time/current/zone?timeZone=America/Los_Angeles";
const char* URL_DB   = "https://marcusinternetofthings.com/assignment2_insert.php";

// =======================
// Pins / Sensors
// =======================
constexpr uint8_t PIN_BUTTON = 5;  // active-LOW
constexpr uint8_t PIN_TILT   = 4;  // active-LOW
#define DHTPIN 14
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

// =======================
// Prototypes
// =======================
void   connectWiFi();
String getTimeFromAPI(uint8_t retries = 2);
bool   readDHT(float& tC, float& h);   // no retries inside (per request)
void   sendDataToServer(float temperature, float humidity, const String& node, const String& isoTime);
String urlEncode(const String& s);

// =======================
// Setup / Loop
// =======================
void setup() {
  Serial.begin(9600);
  Serial.println();
  Serial.println("=== Setup start ===");

  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(PIN_BUTTON, INPUT_PULLUP);
  pinMode(PIN_TILT,   INPUT_PULLUP);
  dht.begin();
  Serial.println("[DHT] Initialized");

  connectWiFi();

  Serial.println("=== Setup complete ===\n");
}

void loop() {
  // Button → Temperature (no debounce)
  if (digitalRead(PIN_BUTTON) == LOW) {
    Serial.println("[BUTTON] Press detected -> Read temperature & send");
    float t, h;
    if (readDHT(t, h)) {
      String iso = getTimeFromAPI();
      Serial.printf("[TEMP] Reading: %.2f C | Time: %s\n", t, iso.c_str());
      sendDataToServer(t, NAN, "node_1", iso);
    } else {
      Serial.println("[TEMP] DHT read failed");
    }
  }

  // Tilt → Humidity
  if (digitalRead(PIN_TILT) == LOW) {
    Serial.println("[TILT] Closed detected -> Read humidity & send");
    float t, h;
    if (readDHT(t, h)) {
      String iso = getTimeFromAPI();
      Serial.printf("[HUM] Reading: %.2f %% | Time: %s\n", h, iso.c_str());
      sendDataToServer(NAN, h, "node_2", iso);
    } else {
      Serial.println("[HUM] DHT read failed");
    }
  }

  // heartbeat blink
  digitalWrite(LED_BUILTIN, LOW);  delay(200);
  digitalWrite(LED_BUILTIN, HIGH); delay(800);
}

// =======================
// Wi-Fi
// =======================
void connectWiFi() {
  if (WiFi.status() == WL_CONNECTED) {
    Serial.printf("[WiFi] Already connected. IP: %s\n", WiFi.localIP().toString().c_str());
    return;
  }
  Serial.printf("[WiFi] Connecting to SSID: %s\n", WIFI_SSID);
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASS);

  uint32_t start = millis();
  while (WiFi.status() != WL_CONNECTED) {
    delay(300);
    Serial.print('.');
    if (millis() - start > 20000) {  // 20s guard
      Serial.println("\n[WiFi] Connection timeout.");
      break;
    }
  }
  if (WiFi.status() == WL_CONNECTED) {
    Serial.printf("\n[WiFi] Connected. IP: %s\n", WiFi.localIP().toString().c_str());
  } else {
    Serial.println("[WiFi] Not connected.");
  }
}

// =======================
// Time API (HTTPS + JSON v7)
// =======================
String getTimeFromAPI(uint8_t retries) {
  StaticJsonDocument<64> filter;
  filter["dateTime"] = true;

  while (retries--) {
    if (WiFi.status() != WL_CONNECTED) {
      Serial.println("[TIME] WiFi not connected, attempting reconnect...");
      connectWiFi();
      if (WiFi.status() != WL_CONNECTED) {
        Serial.println("[TIME] Reconnect failed.");
        return "";
      }
    }

    Serial.println("[TIME] Preparing HTTPS client");
    std::unique_ptr<BearSSL::WiFiClientSecure> client(new BearSSL::WiFiClientSecure());
    client->setInsecure(); // simplify cert handling for class project

    HTTPClient http;
    http.setTimeout(8000);

    Serial.printf("[TIME] http.begin -> %s\n", URL_TIME);
    if (!http.begin(*client, URL_TIME)) {
      Serial.println("[TIME] http.begin() failed");
      continue;
    }

    Serial.println("[TIME] HTTP GET...");
    int code = http.GET();
    Serial.printf("[TIME] HTTP status: %d\n", code);

    if (code == HTTP_CODE_OK) {
      String payload = http.getString();
      Serial.printf("[TIME] Payload length: %u bytes\n", payload.length());

      DynamicJsonDocument doc(128);
      DeserializationError err =
          deserializeJson(doc, payload, DeserializationOption::Filter(filter));

      if (!err && doc["dateTime"].is<const char*>()) {
        String iso = doc["dateTime"].as<const char*>();
        Serial.printf("[TIME] Parsed dateTime: %s\n", iso.c_str());
        http.end();
        return iso;
      } else {
        Serial.print("[TIME] JSON parse error: ");
        Serial.println(err.c_str());
      }
    } else {
      Serial.printf("[TIME] HTTP error: %s\n", http.errorToString(code).c_str());
    }

    http.end();
    if (retries) {
      Serial.println("[TIME] Retry...");
      delay(300);
    }
  }

  Serial.println("[TIME] Failed to obtain time from API.");
  return "";
}

// =======================
// DHT + Send
// =======================
bool readDHT(float& tC, float& h) {
  // Per request: NO retry logic here—single read attempt.
  Serial.println("[DHT] Reading sensors (single attempt)...");
  h  = dht.readHumidity();
  tC = dht.readTemperature(); // Celsius

  if (isnan(h) || isnan(tC)) {
    Serial.println("[DHT] NaN received from sensor");
    return false;
  }
  Serial.printf("[DHT] Read OK: T=%.2f C, H=%.2f %%\n", tC, h);
  return true;
}

void sendDataToServer(float temperature, float humidity, const String& node, const String& isoTime) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("[SEND] WiFi not connected. Aborting send.");
    return;
  }

  String tStr = isnan(temperature) ? "" : String(temperature, 2);
  String hStr = isnan(humidity)    ? "" : String(humidity, 2);

  String url = String(URL_DB) +
               "?node_id="     + urlEncode(node) +
               "&time="        + urlEncode(isoTime) +
               "&temperature=" + urlEncode(tStr) +
               "&humidity="    + urlEncode(hStr);

  Serial.println(String("[SEND] Constructed URL: ") + url);

  std::unique_ptr<BearSSL::WiFiClientSecure> client(new BearSSL::WiFiClientSecure());
  client->setInsecure();

  HTTPClient http;
  http.setTimeout(8000);

  Serial.println("[SEND] http.begin()");
  if (http.begin(*client, url)) {
    Serial.println("[SEND] HTTP GET...");
    int code = http.GET();
    Serial.printf("[SEND] HTTP status: %d\n", code);

    if (code > 0) {
      // Optional: read response body for debugging
      String resp = http.getString();
      Serial.printf("[SEND] Response length: %u bytes\n", resp.length());
      if (resp.length()) {
        Serial.println("[SEND] Response body (first 200 chars):");
        Serial.println(resp.substring(0, 200));
      }
    } else {
      Serial.printf("[SEND] GET failed: %s\n", http.errorToString(code).c_str());
    }
    http.end();
    Serial.println("[SEND] http.end()");
  } else {
    Serial.println("[SEND] http.begin() failed");
  }
}

// =======================
// Small helpers
// =======================
String urlEncode(const String& s) {
  String out;
  out.reserve(s.length() * 3);
  for (size_t i = 0; i < s.length(); ++i) {
    uint8_t c = static_cast<uint8_t>(s[i]);
    if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') ||
        (c >= '0' && c <= '9') || c == '-' || c == '_' || c == '.' || c == '~') {
      out += char(c);
    } else {
      char buf[4];
      snprintf(buf, sizeof(buf), "%%%02X", c);
      out += buf;
    }
  }
  return out;
}
