#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <ArduinoJson.h>   // v7 API
#include <DHT.h>

// =======================
// Wi-Fi & API
// =======================
const char* SSID      = "marcus";
const char* PASSWORD  = "wecwecwec";
const char* URL_TIME  = "https://timeapi.io/api/Time/current/zone?timeZone=America/Los_Angeles";
const char* URL_DB    = "https://marcusinternetofthings.com/assignment2_insert.php";
JsonDocument doc;  // v7: dynamic JsonDocument (replaces DynamicJsonDocument)

// =======================
// Pins / Sensors
// =======================
constexpr uint8_t PIN_BUTTON = 5;  // button: idle HIGH, pressed LOW
constexpr uint8_t PIN_TILT   = 4;  // tilt:   idle HIGH, closed LOW
#define DHTPIN 14
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

// =======================
// State machine
// =======================
enum class MeasureMode { Idle, Temp, Humid, Halt };
MeasureMode mode = MeasureMode::Idle;

// =======================
// Declarations
// =======================
void connectWiFi();
void getTimeFromAPI();
void updateMode();
void readAndSendMeasurement();
void sendDataToServer(float temperature, float humidity, MeasureMode mode, const String& isoTime);
String urlEncode(const String& s);

// =======================
// Setup / Loop
// =======================
void setup() {
  Serial.begin(9600);
  pinMode(LED_BUILTIN, OUTPUT);

  pinMode(PIN_BUTTON, INPUT_PULLUP);
  pinMode(PIN_TILT,   INPUT_PULLUP);
  dht.begin();

  connectWiFi();
  //getTimeFromAPI();  // initial fetch
}

void loop() {
  updateMode();
  getTimeFromAPI();          // fetch each loop
  readAndSendMeasurement();

  digitalWrite(LED_BUILTIN, LOW);
  delay(10000);              // 10 s loop
  digitalWrite(LED_BUILTIN, HIGH);

}

// =======================
// Logic
// =======================
void updateMode() {
  const bool buttonPressed = (digitalRead(PIN_BUTTON) == LOW);
  const bool tiltClosed    = (digitalRead(PIN_TILT)   == LOW);

  if (buttonPressed && tiltClosed) { mode = MeasureMode::Halt; return; }

  switch (mode) {
    case MeasureMode::Idle:
      if (buttonPressed)   mode = MeasureMode::Temp;
      else if (tiltClosed) mode = MeasureMode::Humid;
      break;
    case MeasureMode::Temp:
      if (tiltClosed)      mode = MeasureMode::Humid;
      break;
    case MeasureMode::Humid:
      if (buttonPressed)   mode = MeasureMode::Temp;
      break;
    case MeasureMode::Halt:
      if (!buttonPressed && !tiltClosed) mode = MeasureMode::Idle;
      break;
  }
}

void readAndSendMeasurement() {
  if (mode == MeasureMode::Idle || mode == MeasureMode::Halt) return;

  const float h = dht.readHumidity();
  const float t = dht.readTemperature();
  if (isnan(h) || isnan(t)) {
    Serial.println("DHT read failed");
    return;
  }

  // v7: prefer is<T>() instead of containsKey()
  const String isoTime = doc["dateTime"].is<const char*>()
                         ? String(doc["dateTime"].as<const char*>())
                         : "";

  if (mode == MeasureMode::Temp) {
    Serial.printf("Temperature: %.2f °C\n", t);
    sendDataToServer(t, NAN, MeasureMode::Temp, isoTime);
  } else { // MeasureMode::Humid
    Serial.printf("Humidity: %.2f %%\n", h);
    sendDataToServer(NAN, h, MeasureMode::Humid, isoTime);
  }
}

// =======================
// Networking
// =======================
void connectWiFi() {
  if (WiFi.status() == WL_CONNECTED) return;

  WiFi.mode(WIFI_STA);
  WiFi.begin(SSID, PASSWORD);
  Serial.print("Connecting");
  uint32_t start = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - start < 15000) {
    delay(250); Serial.print('.');
  }
  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi connected.");
    Serial.print("IP: "); Serial.println(WiFi.localIP());
  } else {
    Serial.println("\nWiFi connection failed.");
  }
}

void getTimeFromAPI() {
  if (WiFi.status() != WL_CONNECTED) return;

  WiFiClientSecure client; client.setInsecure();
  HTTPClient http;

  if (!http.begin(client, URL_TIME)) return;

  int code = http.GET();
  if (code == 200) {
    String payload = http.getString();
    // v7: same deserializeJson() API; doc is JsonDocument
    if (deserializeJson(doc, payload) == DeserializationError::Ok &&
        doc["dateTime"].is<const char*>()) {
      Serial.println("Time: " + String(doc["dateTime"].as<const char*>()));
    }
  } else {
    Serial.printf("[TIME] HTTP error: %d\n", code);
  }
  http.end();
}

void sendDataToServer(float temperature, float humidity, MeasureMode currentMode, const String& isoTime) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("[SEND] WiFi not connected");
    return;
  }

  const String node = (currentMode == MeasureMode::Temp) ? "node_1" : "node_2";
  const String tStr = (!isnan(temperature) && currentMode == MeasureMode::Temp)  ? String(temperature, 2) : "";
  const String hStr = (!isnan(humidity)    && currentMode == MeasureMode::Humid) ? String(humidity, 2)    : "";

  String url = String(URL_DB) +
               "?node_id="     + node +
               "&time="        + urlEncode(isoTime) +
               "&temperature=" + tStr +
               "&humidity="    + hStr;

  WiFiClientSecure client; client.setInsecure();
  HTTPClient http;

  Serial.println("[SEND] " + url);

  if (http.begin(client, url)) {
    int code = http.GET();
    if (code > 0) {
      Serial.printf("[SEND] Response: %d\n", code);
      Serial.println(http.getString());
    } else {
      Serial.printf("[SEND] GET failed: %s\n", http.errorToString(code).c_str());
    }
    http.end();
  } else {
    Serial.println("[SEND] Unable to connect to server");
  }
}

// URL encoder
String urlEncode(const String& s) {
  String out; out.reserve(s.length() * 3);
  for (size_t i = 0; i < s.length(); ++i) {
    char c = s[i];
    bool safe = (isalnum(c) || c == '-' || c == '_' || c == '.' || c == '~');
    if (safe) out += c;
    else { char buf[4]; snprintf(buf, sizeof(buf), "%%%02X", (unsigned char)c); out += buf; }
  }
  return out;
}
