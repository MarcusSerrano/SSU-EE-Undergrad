#!/usr/bin/env python3

import paho.mqtt.client as mqtt
import mysql.connector
from mysql.connector import Error

# ------------- CONFIG: EDIT THESE ------------- #

# MQTT broker settings
MQTT_BROKER = "broker.hivemq.com"   # or broker.mqttdashboard.com if your assignment says so
MQTT_PORT   = 1883
MQTT_TOPIC  = "testtopic/temp/outTopic/marcus"   # <-- change to the topic your ESP8266 is publishing to

# MySQL settings (from Hostinger)
DB_HOST     = ""   # e.g. "mysql123.hostinger.com" (NOT localhost)
DB_USER     = ""
DB_PASSWORD = ""
DB_NAME     = ""

# ------------- END OF CONFIG ------------------ #

# Global database connection + cursor
db_conn = None
db_cursor = None


def connect_database():
    """Connect to MySQL on Hostinger."""
    global db_conn, db_cursor
    try:
        db_conn = mysql.connector.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME
        )
        db_cursor = db_conn.cursor()
        print("[DB] Connected to MySQL")
    except Error as e:
        print(f"[DB] Error connecting to MySQL: {e}")


def on_connect(client, userdata, flags, rc):
    """Called when the MQTT client connects to the broker."""
    if rc == 0:
        print("[MQTT] Connected OK")
        # Subscribe to your topic(s)
        client.subscribe(MQTT_TOPIC)
        print(f"[MQTT] Subscribed to: {MQTT_TOPIC}")
    else:
        print(f"[MQTT] Bad connection. Returned code={rc}")


def on_message(client, userdata, msg):
    """Called when a message is received on a subscribed topic."""
    global db_conn, db_cursor

    topic = msg.topic
    payload = msg.payload.decode("utf-8", errors="replace")
    print(f"[MQTT] {topic} -> {payload}")

    if db_conn is None or not db_conn.is_connected():
        print("[DB] Not connected, attempting reconnect...")
        connect_database()
        if db_conn is None or not db_conn.is_connected():
            print("[DB] Still not connected. Skipping insert.")
            return

    try:
        sql = "INSERT INTO mqtt_data (topic, payload) VALUES (%s, %s)"
        vals = (topic, payload)
        db_cursor.execute(sql, vals)
        db_conn.commit()
        print("[DB] Inserted row")
    except Error as e:
        print(f"[DB] Error inserting data: {e}")


def main():
    # Connect to DB once at start
    connect_database()

    # Set up MQTT client
    client = mqtt.Client()  # default callback API
    client.on_connect = on_connect
    client.on_message = on_message

    print(f"[MQTT] Connecting to {MQTT_BROKER}:{MQTT_PORT} ...")
    client.connect(MQTT_BROKER, MQTT_PORT, keepalive=60)

    # Loop forever, handling MQTT traffic
    client.loop_forever()


if __name__ == "__main__":
    main()
