#!/usr/bin/env python3
import time
import requests
import psutil

# 1) Set this to your ThingSpeak WRITE API KEY
API_KEY = "YOUR_WRITE_API_KEY_HERE"

# 2) ThingSpeak update URL (leave this alone)
URL = "https://api.thingspeak.com/update"

# 3) Path to the CPU temperature sensor on Raspberry Pi
TEMP_PATH = "/sys/class/thermal/thermal_zone0/temp"


def get_cpu_temp_c():
    """Read CPU temp from TEMP_PATH and return degrees C as float."""
    with open(TEMP_PATH, "r") as f:
        raw = f.read().strip()
    # file returns something like '59000' (i.e., 59.000°C)
    return int(raw) / 1000.0


def get_cpu_percent():
    """Return CPU usage percentage over 1 second."""
    return psutil.cpu_percent(interval=1)  # blocks 1 second


def main():
    print("Starting ThingSpeak upload loop...")
    print("Using API key:", API_KEY)
    while True:
        # Read current CPU temperature and CPU usage
        temp_c = get_cpu_temp_c()
        cpu_pct = get_cpu_percent()

        print(time.ctime(), "Temp:", temp_c, "°C", "CPU:", cpu_pct, "%")

        # Build the payload for ThingSpeak: field1 = temp, field2 = CPU %
        payload = {
            "api_key": API_KEY,
            "field1": temp_c,
            "field2": cpu_pct,
        }

        try:
            # Send data to ThingSpeak
            resp = requests.post(URL, data=payload, timeout=10)
            print("ThingSpeak response:", resp.text)
        except Exception as e:
            print("Error sending to ThingSpeak:", e)

        # ThingSpeak free accounts: MIN 15 seconds between updates
        time.sleep(20)


if __name__ == "__main__":
    main()
