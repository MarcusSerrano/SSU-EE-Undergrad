#!/usr/bin/env python3
"""
Barebones LCD service for Raspberry Pi:
- Shows IP address on boot (top line of a 16x2 I2C 1602 LCD).
- While a push-button on GPIO17 is held, shows MAC address instead.
- Rewrites the LCD only when the text changes (reduced flicker).

Deps:
  pip install RPLCD smbus2
  sudo apt install python3-rpi.gpio

Wiring:
  LCD with PCF8574 I2C "backpack" at 0x27 (commonly 0x27 or 0x3F).
  Button between GPIO17 (pin 11) and GND (uses internal pull-up).
"""

import time
import subprocess
import signal
import RPi.GPIO as GPIO
from RPLCD.i2c import CharLCD

# ==== USER CONFIG (adjust these to your hardware) ============================
I2C_ADDRESS = 0x27          # change to 0x3F if your module uses that
I2C_PORT = 1                # /dev/i2c-1 on Pi 4
LCD_COLS, LCD_ROWS = 16, 2  # 1602 display
BUTTON_PIN = 17             # BCM numbering (GPIO17 = physical pin 11)
DEBOUNCE_MS = 50            # button debounce
PREFER_IFACES = ("wlan0", "eth0")  # try Wi-Fi first, then Ethernet
# ============================================================================

# --- Global state (kept tiny on purpose) ------------------------------------
running = True          # main loop flag
show_mac = False        # when True, display MAC; when False, display IP
active_iface = None     # currently selected interface to display (wlan0/eth0)
last_text = ""          # last text actually shown on LCD line 1
# ----------------------------------------------------------------------------

# Create LCD object (backlight on by default)
lcd = CharLCD(
    i2c_expander="PCF8574",
    address=I2C_ADDRESS,
    port=I2C_PORT,
    cols=LCD_COLS,
    rows=LCD_ROWS,
    charmap="A00",
    auto_linebreaks=True,
    backlight_enabled=True,
)

def stop(_sig, _frm):
    """SIGINT/SIGTERM handler: stop main loop cleanly."""
    global running
    running = False

signal.signal(signal.SIGINT, stop)
signal.signal(signal.SIGTERM, stop)

# ---- Network helpers (no extra packages, use `ip` and sysfs) ---------------

def ip_of(interface: str) -> str | None:
    """
    Return IPv4 (e.g., '192.168.1.23') for interface, or None if not assigned.
    Uses 'ip -4 -o addr show dev <iface> scope global'.
    """
    try:
        out = subprocess.check_output(
            ["ip", "-4", "-o", "addr", "show", "dev", interface, "scope", "global"],
            text=True
        ).strip()
        if not out:
            return None
        # Example tokens include 'inet 192.168.1.23/24'
        for tok in out.split():
            if "/" in tok and tok.count(".") == 3:
                return tok.split("/")[0]
    except subprocess.CalledProcessError:
        pass
    return None

def pick_iface_with_ip() -> tuple[str | None, str | None]:
    """Return (iface, ip) for the first interface with an IP, else (None, None)."""
    for iface in PREFER_IFACES:
        ip = ip_of(iface)
        if ip:
            return iface, ip
    return None, None

def mac_of(interface: str) -> str | None:
    """Return MAC address (uppercase) for interface, or None."""
    try:
        with open(f"/sys/class/net/{interface}/address") as f:
            return f.read().strip().upper()
    except Exception:
        return None

# ---- LCD helpers ------------------------------------------------------------

def write_line1(text: str):
    """
    Write text to line 1 only if it changed.
    Pads/truncates to LCD_COLS to erase leftovers.
    """
    global last_text
    text = (text or "")[:LCD_COLS].ljust(LCD_COLS)
    if text != last_text:
        lcd.cursor_pos = (0, 0)
        lcd.write_string(text)
        last_text = text

def refresh_display(force: bool = False):
    """
    Decide what to show (IP or MAC) and update LCD.
    If 'force' is True, guarantee a rewrite on this call.
    """
    global active_iface

    # Ensure we have a valid iface; pick one if unknown or if IP vanished.
    iface, ip = pick_iface_with_ip()
    if iface:
        active_iface = iface

    if show_mac and active_iface:
        text = mac_of(active_iface) or "MAC N/A"
    else:
        # Prefer live IP; if none yet, say "No network"
        ip = ip_of(active_iface) if active_iface else None
        text = ip or "No network"

    if force:
        # Force a mismatch so write_line1 definitely updates once
        write_line1(text + " ")
    write_line1(text)

# ---- Button handling --------------------------------------------------------

def on_button_edge(_channel):
    """
    Called on BOTH edges. With pull-up: LOW=pressed, HIGH=released.
    While pressed: show MAC. When released: show IP.
    """
    global show_mac
    pressed = GPIO.input(BUTTON_PIN) == GPIO.LOW
    show_mac = pressed
    refresh_display(force=True)

# ---- Main -------------------------------------------------------------------

def main():
    global active_iface

    # GPIO setup for the button (internal pull-up)
    GPIO.setmode(GPIO.BCM)
    GPIO.setup(BUTTON_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)
    GPIO.add_event_detect(BUTTON_PIN, GPIO.BOTH, callback=on_button_edge, bouncetime=DEBOUNCE_MS)

    # Wait at boot until we actually have an IP (don’t touch LCD until then)
    while running:
        active_iface, ip = pick_iface_with_ip()
        if ip:
            break
        time.sleep(0.5)

    # Show initial IP
    refresh_display(force=True)

    # Main loop: if showing IP, poll for changes; if showing MAC, callback handles updates
    prev_ip = None
    while running:
        if not show_mac:
            current_ip = ip_of(active_iface) if active_iface else None
            if current_ip != prev_ip:
                refresh_display()
                prev_ip = current_ip
        time.sleep(0.5)

if __name__ == "__main__":
    try:
        main()
    finally:
        # Clean up nicely on exit or service stop
        try:
            GPIO.remove_event_detect(BUTTON_PIN)
            GPIO.cleanup()
        except Exception:
            pass
        try:
            lcd.clear()
            lcd.backlight_enabled = False
            lcd.close(clear=True)
        except Exception:
            pass
