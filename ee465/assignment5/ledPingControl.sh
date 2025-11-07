#!/bin/bash
# ledPingControl.sh - Control Pi onboard LED via ICMP ping patterns or lengths.
# 
# STOP BOOTLED OR THIS WILL NOT WORK
# 
# sudo systemctl stop bootled.service 
# sudo systemctl disable bootled.service
#
# chmod =777 ledPingControl.sh
# sudo ./ledPingControl.sh
# Linux pings
# ping -c 1 -p aaae <pi_ip>   # LED ON
# ping -c 1 -p abae <pi_ip>   # LED OFF
#
# Windows pings:
# nping --icmp --data aaae <pi_ip>   # LED ON
# nping --icmp --data abae <pi_ip>   # LED OFF

# LED sysfs path (ACT LED)
LED="/sys/class/leds/ACT"

# Hex payload patterns (case-insensitive)
PATTERN_ON="aaae"
PATTERN_OFF="abae"

# Ensure tshark is available
if ! command -v tshark >/dev/null; then
  echo "Error: tshark not found. Install it with:"
  echo "  sudo apt install tshark -y"
  exit 1
fi

# Disable automatic kernel trigger (manual LED control)
echo none | sudo tee "$LED/trigger" >/dev/null

# LED control functions
led_on()  { echo 1 | sudo tee "$LED/brightness" >/dev/null; echo "LED ON"; }
led_off() { echo 0 | sudo tee "$LED/brightness" >/dev/null; echo "LED OFF"; }

# Get Pi's IP address (first one found)
IP=$(hostname -I | awk '{print $1}')
echo "Listening for ICMP packets to $IP..."
echo "Patterns: $PATTERN_ON → ON, $PATTERN_OFF → OFF"
echo "Press Ctrl+C to stop."

# Start Tshark capture
sudo tshark -i any -l -Y "icmp.type==8 && ip.dst==$IP" -T fields -e data.data 2>/dev/null |
while read -r data; do
  data=$(echo "$data" | tr 'A-Z' 'a-z')
  [[ -z "$data" ]] && continue

  if [[ "$data" == "$PATTERN_ON" ]]; then
    led_on
  elif [[ "$data" == "$PATTERN_OFF" ]]; then
    led_off
  else
    echo "Ping received: $data"
  fi
done
