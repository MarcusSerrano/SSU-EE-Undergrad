#!/usr/bin/env python3

import requests
from time import sleep

# Replace these with YOUR actual keys
CHANNEL_WRITE_API_KEY = "YOUR_CHANNEL_WRITE_API_KEY"   # from your channel page
TALKBACK_KEY = "YOUR_TALKBACK_API_KEY"                 # from the TalkBack page

while True:
    # This URL returns the next command (and removes it from the queue)
    baseurl = (
        "https://api.thingspeak.com/update?"
        f"api_key={CHANNEL_WRITE_API_KEY}&talkback_key={TALKBACK_KEY}"
    )

    response = requests.get(baseurl)
    command = response.text.strip()

    if command == 'OFF':
        print('LED1 OFF')
        # TODO: turn your GPIO pin OFF here
    elif command == 'ON':
        print('LED1 ON')
        # TODO: turn your GPIO pin ON here
    else:
        print('No valid command (got:', command, ')')

    sleep(30)   # check every 30 seconds
