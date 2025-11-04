#!/usr/bin/env python3
"""
Minimal LCD service:
- Shows IP on a 16x2 I2C LCD (PCF8574 backpack).
- While a button (GPIO17->GND) is held, shows MAC instead.
- No edge detection, no debounce: simple polling loop.

Deps: pip install RPLCD smbus2 ; sudo apt install python3-rpi.gpio
"""

import time, signal, subprocess
import RPi.GPIO as GPIO
from RPLCD.i2c import CharLCD

# --- Config: change address if i2cdetect shows 0x3F, etc. ---
I2C_ADDRESS = 0x27
I2C_PORT = 1
LCD_COLS, LCD_ROWS = 16, 2
BUTTON_PIN = 21                 # BCM numbering (pin 40)
PREFER_IFACES = ("wlan0", "eth0")
# ------------------------------------------------------------

running = True
def stop(_sig, _frm):  # clean exit on service stop
    global running
    running = False
signal.signal(signal.SIGINT, stop)
signal.signal(signal.SIGTERM, stop)

# --- Small helpers (no extra packages) ----------------------
def ip_of(iface: str) -> str | None:
    """IPv4 of iface or None."""
    try:
        out = subprocess.check_output(
            ["ip", "-4", "-o", "addr", "show", "dev", iface, "scope", "global"],
            text=True
        ).strip()
        for tok in out.split():
            if "/" in tok and tok.count(".") == 3:
                return tok.split("/")[0]
    except subprocess.CalledProcessError:
        pass
    return None

def pick_iface_with_ip():
    """Return (iface, ip) for first iface that has an IP, else (None, None)."""
    for iface in PREFER_IFACES:
        ip = ip_of(iface)
        if ip:
            return iface, ip
    return None, None

def mac_of(iface: str) -> str | None:
    try:
        with open(f"/sys/class/net/{iface}/address") as f:
            return f.read().strip().upper()
    except Exception:
        return None

# --- LCD + GPIO setup ---------------------------------------
lcd = CharLCD('PCF8574', address=I2C_ADDRESS, port=I2C_PORT,
              cols=LCD_COLS, rows=LCD_ROWS, charmap='A00',
              auto_linebreaks=True, backlight_enabled=True)

GPIO.setmode(GPIO.BCM)
GPIO.setup(BUTTON_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)  # pull-up: LOW when pressed

def write_line1(text: str, last: str) -> str:
    """Write only if text changed; return new last."""
    text = (text or "")[:LCD_COLS].ljust(LCD_COLS)
    if text != last:
        lcd.cursor_pos = (0, 0)
        lcd.write_string(text)
        return text
    return last

# --- Main ---------------------------------------------------
def main():
    # Wait until we actually have an IP on some iface
    iface, ip = None, None
    while running and not ip:
        iface, ip = pick_iface_with_ip()
        time.sleep(0.3)

    last = ""          # last text shown on LCD
    last_ip = ip       # remember last IP we displayed

    # Main polling loop: check button + refresh IP occasionally
    while running:
        pressed = (GPIO.input(BUTTON_PIN) == GPIO.LOW)

        # Refresh IP (lightweight) when not showing MAC
        if not pressed:
            cur_ip = ip_of(iface) if iface else None
            if not cur_ip:          # iface lost IP? try the other one
                iface, cur_ip = pick_iface_with_ip()
            if cur_ip != last_ip:
                last_ip = cur_ip

        text = (mac_of(iface) if pressed else (last_ip or "No network"))
        last = write_line1(text, last)

        time.sleep(0.2)  # simple, steady poll rate

if __name__ == "__main__":
    try:
        main()
    finally:
        try: GPIO.cleanup()
        except Exception: pass
        try:
            lcd.clear()
            lcd.backlight_enabled = False
            lcd.close(clear=True)
        except Exception:
            pass
