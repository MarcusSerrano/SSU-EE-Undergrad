#!/usr/bin/env python3
import time
import random
import requests

API_KEY = "YOUR_WRITE_API_KEY_HERE"   # <-- put your key here
URL = "https://api.thingspeak.com/update"

def main():
    while True:
        # Two random values, like the lab example
        myRandom1 = random.randint(0, 100)
        myRandom2 = random.random()

        print(time.ctime(), "sending:",
              "field1 =", myRandom1,
              "field2 =", myRandom2)

        payload = {
            "api_key": API_KEY,
            "field1": myRandom1,
            "field2": myRandom2,
            "field3": 20,   # just a constant, like the example
        }

        try:
            resp = requests.post(URL, data=payload, timeout=10)
            print("ThingSpeak response:", resp.text)
        except Exception as e:
            print("Error sending to ThingSpeak:", e)

        # Must be >= 15s between writes (ThingSpeak limit)
        time.sleep(20)

if __name__ == "__main__":
    main()
