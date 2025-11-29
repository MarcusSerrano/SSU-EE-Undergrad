#!/usr/bin/env python3
import time
import requests
import RPi.GPIO as GPIO

# === CONFIGURATION ===
LED_PIN = 18  # BCM pin number
CHANNEL_WRITE_API_KEY = "YOUR_CHANNEL_WRITE_API_KEY"  # from your ThingSpeak channel
TALKBACK_KEY = "YOUR_TALKBACK_API_KEY"                # from your TalkBack

GPIO.setmode(GPIO.BCM)
GPIO.setup(LED_PIN, GPIO.OUT, initial=GPIO.LOW)

try:
    while True:
        # This URL executes and pops the next command from the TalkBack queue
        url = (
            f"https://api.thingspeak.com/update?"
            f"api_key={CHANNEL_WRITE_API_KEY}&talkback_key={TALKBACK_KEY}"
        )

        response = requests.get(url)
        command = response.text.strip()
        print("Raw response:", repr(command))

        if command == "ON":
            GPIO.output(LED_PIN, GPIO.HIGH)
            print("LED1 ON")
        elif command == "OFF":
            GPIO.output(LED_PIN, GPIO.LOW)
            print("LED1 OFF")
        else:
            print("No valid command (queue empty or something else).")

        time.sleep(10)  # check every 10 seconds; lab example uses 30 s

except KeyboardInterrupt:
    print("Exiting...")

finally:
    GPIO.cleanup()
