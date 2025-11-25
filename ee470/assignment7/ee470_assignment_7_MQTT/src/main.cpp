// EE470 MQTT Assignment - Single Sketch for Parts A–F1 (undergrad)
// Board: NodeMCU ESP-12E (ESP8266)

#include <ESP8266WiFi.h>
#include <PubSubClient.h>

// ----------- USER CONFIG -----------

// 1) Your WiFi info
const char* WIFI_SSID     = "DESKTOP-P1IMH40 8840";
const char* WIFI_PASSWORD = "}09L477r";

// 2) MQTT broker (HiveMQ public broker)
const char* MQTT_BROKER = "broker.hivemq.com";
const int   MQTT_PORT   = 1883;  // non-TLS, simple

// 3) Topics for this assignment (Marcus)
const char* TOPIC_OUT = "testtopic/temp/outTopic/marcus"; // ESP -> others
const char* TOPIC_IN  = "testtopic/temp/inTopic";         // others -> ESP

// 4) Pins on NodeMCU ESP-12E
const int PIN_LED    = D1;   // GPIO5
const int PIN_SWITCH = D5;   // GPIO14, to GND, using INPUT_PULLUP
const int PIN_POT    = A0;   // analog input

// 5) Publish interval for potentiometer
const unsigned long POT_PUBLISH_INTERVAL_MS = 15000; // 15 seconds

// -----------------------------------

WiFiClient espClient;
PubSubClient client(espClient);

unsigned long lastPotPublish = 0;

// Switch state tracking for press + release detection
int  lastSwitchState      = HIGH;  // because of INPUT_PULLUP
bool waitingToSendZero    = false;
unsigned long sendZeroAt  = 0;

// Forward declarations
void mqttCallback(char* topic, byte* payload, unsigned int length);
void reconnectMQTT();
void connectWiFi();

void setup() {
  Serial.begin(9600);
  delay(1000);
  Serial.println();
  Serial.println("EE470 MQTT - Marcus");

  pinMode(PIN_LED, OUTPUT);
  digitalWrite(PIN_LED, LOW);

  pinMode(PIN_SWITCH, INPUT_PULLUP); // switch to GND
  // Pot uses A0, no pinMode needed

  connectWiFi();

  client.setServer(MQTT_BROKER, MQTT_PORT);
  client.setCallback(mqttCallback);
}

void loop() {
  // ---------- Part A: Serial control of LED ----------
  if (Serial.available()) {
    char c = Serial.read();
    if (c == '1') {
      digitalWrite(PIN_LED, HIGH);
      Serial.println("LED ON (from Serial)");
    } else if (c == '0') {
      digitalWrite(PIN_LED, LOW);
      Serial.println("LED OFF (from Serial)");
    }
  }

  // ---------- MQTT connection maintenance ----------
  if (!client.connected()) {
    reconnectMQTT();
  }
  client.loop(); // handle incoming messages

  unsigned long now = millis();

  // ---------- Parts A & B: read potentiometer, print & publish ----------
  if (now - lastPotPublish > POT_PUBLISH_INTERVAL_MS) {
    lastPotPublish = now;

    int raw = analogRead(PIN_POT);
    float volts = raw * (3.3f / 1023.0f); // ESP8266 ADC is 0–1V scaled to 0–3.3V on NodeMCU

    Serial.print("Pot raw: ");
    Serial.print(raw);
    Serial.print("  Volts: ");
    Serial.println(volts, 3);

    // Publish the raw value as a string to TOPIC_OUT
    char msg[16];
    snprintf(msg, sizeof(msg), "%d", raw);
    client.publish(TOPIC_OUT, msg);
  }

  // ---------- Parts A & C2: switch press/release handling ----------
  int currentSwitchState = digitalRead(PIN_SWITCH);

  // Input is PULLUP: HIGH = not pressed, LOW = pressed

  // Detect press (High -> Low): Part A wants to see "1" on terminal when pressed
  if (lastSwitchState == HIGH && currentSwitchState == LOW) {
    Serial.println("1"); // switch pressed
  }

  // Detect full click (press then release: Low -> High)
  if (lastSwitchState == LOW && currentSwitchState == HIGH) {
    Serial.println("Switch pressed and released: send 1 now, 0 in 5s");

    // Immediately send "1" on OUT topic
    client.publish(TOPIC_OUT, "1");

    // Schedule a "0" 5 seconds later
    waitingToSendZero = true;
    sendZeroAt = now + 5000;
  }

  lastSwitchState = currentSwitchState;

  // After 5 seconds, send "0" once
  if (waitingToSendZero && now >= sendZeroAt) {
    client.publish(TOPIC_OUT, "0");
    Serial.println("Sent 0 after 5 seconds (switch release).");
    waitingToSendZero = false;
  }
}

// ----------------- WiFi & MQTT helpers -----------------

void connectWiFi() {
  Serial.print("Connecting to WiFi: ");
  Serial.println(WIFI_SSID);

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();
  Serial.print("WiFi connected, IP: ");
  Serial.println(WiFi.localIP());
}

void reconnectMQTT() {
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection... ");

    String clientId = "ESP8266Client-";
    clientId += String(ESP.getChipId(), HEX); // simple unique ID

    // No username/password: public HiveMQ broker
    if (client.connect(clientId.c_str())) {
      Serial.println("connected");

      // Subscribe to LED control topic (Part C1 / D / E / F1)
      client.subscribe(TOPIC_IN);
      Serial.print("Subscribed to: ");
      Serial.println(TOPIC_IN);
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println("  try again in 5 seconds...");
      delay(5000);
    }
  }
}

// ---------- MQTT callback: LED control via MQTT (Part C1, D, E, F1) ----------

void mqttCallback(char* topic, byte* payload, unsigned int length) {
  Serial.print("Message arrived [");
  Serial.print(topic);
  Serial.print("] ");

  // Copy payload into a null-terminated C-string
  char msg[64];
  if (length >= sizeof(msg)) length = sizeof(msg) - 1;
  for (unsigned int i = 0; i < length; i++) {
    msg[i] = (char)payload[i];
  }
  msg[length] = '\0';

  Serial.println(msg);

  // Control LED if the message came on our IN topic
  if (strcmp(topic, TOPIC_IN) == 0) {
    if (strcmp(msg, "1") == 0) {
      digitalWrite(PIN_LED, HIGH);
      Serial.println("LED ON (from MQTT)");
    } else if (strcmp(msg, "0") == 0) {
      digitalWrite(PIN_LED, LOW);
      Serial.println("LED OFF (from MQTT)");
    } else {
      Serial.println("Unknown LED command, expected '1' or '0'");
    }
  }
}
