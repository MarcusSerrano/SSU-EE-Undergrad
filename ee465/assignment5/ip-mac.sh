#! /bin/bash

sleep 45

myIPAddress=$(hostname -I | awk '{print $1}')
myMACAddress=$(ip link show wlan0 | awk '/ether/ {print $2}')

echo "IP: $myIPAddress"
echo "MAC: $myMACAddress"

curl -X POST https://faridfarahmand.net/EE465/checkipaddress.php -d "IpAddress=$myIPAddress" -d "MACAddress=$myMACAddress"
