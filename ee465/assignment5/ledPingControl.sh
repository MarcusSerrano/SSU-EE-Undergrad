#!/bin/bash
# ledPingControl.sh - Control Pi onboard LED via ICMP ping patterns or lengths.

# How to use this script, you probably have to stop the bootled.service to allow for this to run.
#chmod +x ledPingControl.sh
#sudo ./ledPingControl.sh
#ping -c 1 -p aaae <pi_ip>   # LED ON
#ping -c 1 -p abae <pi_ip>   # LED OFF

LED="/sys/class/leds/led0"
PATTERN_ON="aa:ae"
PATTERN_OFF="ab:ae"
LEN_ON=3
LEN_OFF=2

# Manual LED control
echo none | sudo tee "$LED/trigger" >/dev/null

led_on()  { echo 1 | sudo tee "$LED/brightness" >/dev/null; echo "LED ON"; }
led_off() { echo 0 | sudo tee "$LED/brightness" >/dev/null; echo "LED OFF"; }

# Get Pi IP
IP=$(hostname -I | awk '{print $1}')
echo "Listening for pings to $IP..."
echo "Rules: $PATTERN_ON/$LEN_ON=ON, $PATTERN_OFF/$LEN_OFF=OFF"

# Use tshark if available, else tcpdump
if command -v tshark >/dev/null; then
  sudo tshark -i any -l -Y "icmp.type==8 && ip.dst==$IP" -T fields -e data.data -e data.len 2>/dev/null |
  while IFS=$'\t' read -r data len; do
    data=$(echo "$data" | tr 'A-Z' 'a-z')
    if [[ "$data" == "$PATTERN_ON" ]]; then led_on
    elif [[ "$data" == "$PATTERN_OFF" ]]; then led_off
    elif [[ "$len" -eq "$LEN_ON" ]]; then led_on
    elif [[ "$len" -eq "$LEN_OFF" ]]; then led_off
    else echo "PING received ($len bytes)"; fi
  done
else
  echo "Using tcpdump fallback..."
  sudo tcpdump -l -n -i any -x "icmp[icmptype]==8 and dst host $IP" 2>/dev/null |
  awk '/ICMP echo request/ {next} /^[[:space:]]*[0-9a-f]+:/ {
    line=""; for(i=2;i<=NF;i++){gsub(/[^0-9a-f]/,"",$i); line=line substr($i,1,2) ":" substr($i,3,2) ":"}
    print tolower(line)
  }' |
  while read -r data; do
    data=${data%:}
    len=$(echo "$data" | awk -F: '{print NF}')
    if [[ "$data" == "$PATTERN_ON" ]]; then led_on
    elif [[ "$data" == "$PATTERN_OFF" ]]; then led_off
    elif [[ "$len" -eq "$LEN_ON" ]]; then led_on
    elif [[ "$len" -eq "$LEN_OFF" ]]; then led_off
    else echo "PING received ($len bytes)"; fi
  done
fi
