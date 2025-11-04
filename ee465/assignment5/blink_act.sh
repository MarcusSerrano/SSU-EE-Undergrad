#!/bin/bash
set -euo pipefail

LED_DIR="/sys/class/leds/ACT"
TRIGGER="$LED_DIR/trigger"
BRIGHT="$LED_DIR/brightness"

# On exit (stop/restart), hand control back to normal activity
cleanup() {
  if [[ -w "$TRIGGER" ]]; then
    echo mmc0 > "$TRIGGER" || true
  fi
}
trap cleanup EXIT INT TERM

# Take control from the kernel (ignore errors if already set)
echo none > "$TRIGGER" 2>/dev/null || true

# Blink forever (500ms on/off)
while true; do
  echo 1 > "$BRIGHT"
  sleep 0.5
  echo 0 > "$BRIGHT"
  sleep 0.5
done
