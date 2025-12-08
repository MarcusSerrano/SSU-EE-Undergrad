#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESP8266HTTPClient.h>
#include <WiFiClientSecure.h>
#include <DHT.h>
#include <time.h>

// ---------- USER SETTINGS ----------

// WiFi credentials
const char* WIFI_SSID     = "";
const char* WIFI_PASSWORD = "";

// Your PHP endpoint (HTTPS)
const char* SERVER_URL = "https://marcusinternetofthings.com/assignment8/insert_sensor_data.php";

// Must match the nodeId you registered in your MySQL 'nodes' table
// and what your PHP expects as nodeId
const char* NODE_ID = "node_1";

// Timezone (system context is -0800)
const long GMT_OFFSET_SEC      = -8L * 3600;  // UTC-8
const int  DAYLIGHT_OFFSET_SEC = 0;          // adjust for DST if desired

// DHT settings
#define DHTPIN  D2      // DHT data pin
#define DHTTYPE DHT11   // DHT11 sensor
DHT dht(DHTPIN, DHTTYPE);

// Button (active-low)
#define BUTTON_PIN D5   // Active-low button input

// Debounce / state tracking
bool lastButtonState = HIGH;
unsigned long lastDebounceTime = 0;
const unsigned long debounceDelay = 50; // ms

WiFiClientSecure client;

// ---------- Helper: connect to WiFi ----------
void connectToWiFi() {
  Serial.print("Connecting to WiFi: ");
  Serial.println(WIFI_SSID);

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int retries = 0;
  while (WiFi.status() != WL_CONNECTED && retries < 40) {
    delay(500);
    Serial.print(".");
    retries++;
  }
  Serial.println();

  if (WiFi.status() == WL_CONNECTED) {
    Serial.print("WiFi connected, IP: ");
    Serial.println(WiFi.localIP());
  } else {
    Serial.println("Failed to connect to WiFi. Check credentials or signal.");
  }
}

// ---------- Helper: setup NTP time ----------
void setupTime() {
  Serial.println("Configuring NTP time...");
  configTime(GMT_OFFSET_SEC, DAYLIGHT_OFFSET_SEC,
             "pool.ntp.org", "time.nist.gov", "time.google.com");

  time_t now = time(nullptr);
  int retries = 0;

  // wait until time is reasonably valid
  while (now < 8 * 3600 * 2 && retries < 30) {
    delay(500);
    Serial.print(".");
    now = time(nullptr);
    retries++;
  }
  Serial.println();

  if (now < 8 * 3600 * 2) {
    Serial.println("Time sync FAILED.");
  } else {
    Serial.println("Time sync OK.");
  }
}

// ---------- Helper: format current time as "YYYY-MM-DD HH:MM:SS" ----------
String getTimestamp() {
  time_t now = time(nullptr);
  struct tm* timeinfo = localtime(&now);

  char buffer[20]; // "YYYY-MM-DD HH:MM:SS" = 19 + null
  if (timeinfo != nullptr) {
    strftime(buffer, sizeof(buffer), "%Y-%m-%d %H:%M:%S", timeinfo);
    return String(buffer);
  } else {
    // fallback in case time not available
    return String("1970-01-01 00:00:00");
  }
}

// ---------- Helper: send reading to PHP ----------
void sendReading(float temperature, float humidity) {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi not connected, reconnecting...");
    connectToWiFi();
    if (WiFi.status() != WL_CONNECTED) {
      Serial.println("Still not connected. Aborting send.");
      return;
    }
  }

  String arrivalTime = getTimestamp();
  Serial.print("Timestamp: ");
  Serial.println(arrivalTime);

  // Encode the space in arrivalTime as %20
  String arrivalTimeEncoded = arrivalTime;
  arrivalTimeEncoded.replace(" ", "%20");

  // Build full URL with query parameters
  // nodeId, arrivalTime, Temp, Hum  (matches PHP: $_GET['nodeId'], ['arrivalTime'], ['Temp'], ['Hum'])
  String url = String(SERVER_URL) +
               "?nodeId=" + NODE_ID +
               "&arrivalTime=" + arrivalTimeEncoded +
               "&Temp=" + String(temperature, 1) +
               "&Hum=" + String(humidity, 1);

  Serial.print("Request URL: ");
  Serial.println(url);

  HTTPClient http;

  // follow 301/302 redirects automatically
  http.setFollowRedirects(HTTPC_STRICT_FOLLOW_REDIRECTS);

  http.begin(client, url);

  int httpCode = http.GET();
  if (httpCode > 0) {
    Serial.printf("HTTP response code: %d\n", httpCode);
    String payload = http.getString();
    Serial.print("Response: ");
    Serial.println(payload);
  } else {
    Serial.printf("HTTP request failed, error: %s\n", http.errorToString(httpCode).c_str());
  }
  http.end();
}

// ---------- Setup ----------
void setup() {
  Serial.begin(9600);
  delay(1000);
  Serial.println();
  Serial.println("ESP8266 DHT11 button uploader starting...");

  pinMode(BUTTON_PIN, INPUT_PULLUP); // active-low
  dht.begin();

  connectToWiFi();

  // Accept any TLS certificate for HTTPS (simpler for class projects)
  client.setInsecure();

  setupTime();
}

// ---------- Main loop ----------
void loop() {
  // Read the button
  bool reading = digitalRead(BUTTON_PIN);

  // Simple debounce
  if (reading != lastButtonState) {
    lastDebounceTime = millis();
  }

  if ((millis() - lastDebounceTime) > debounceDelay) {
    // Button stable; detect press (HIGH -> LOW for active-low)
    static bool lastStableState = HIGH;
    if (reading != lastStableState) {
      lastStableState = reading;

      if (reading == LOW) {
        Serial.println("Button pressed! Reading sensor and sending data...");

        // Read DHT11
        float h = dht.readHumidity();
        float t = dht.readTemperature(); // Celsius

        if (isnan(h) || isnan(t)) {
          Serial.println("Failed to read from DHT11 sensor!");
        } else {
          Serial.print("Temp: ");
          Serial.print(t);
          Serial.print(" °C, Humidity: ");
          Serial.print(h);
          Serial.println(" %");
          sendReading(t, h);
        }
        // Give a moment so you don't accidentally trigger twice
        delay(500);
      }
    }
  }

  lastButtonState = reading;

  // Small delay to reduce CPU usage
  delay(10);
}

