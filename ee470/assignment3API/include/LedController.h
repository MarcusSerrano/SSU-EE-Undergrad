#pragma once
#include <Arduino.h>

class LedController {
 public:
  LedController(uint8_t pin, bool activeLow = true)
  : _pin(pin), _activeLow(activeLow) {}

  void begin() {
    pinMode(_pin, OUTPUT);
    set(false);  // start OFF
  }

  void set(bool on) {
    digitalWrite(_pin, on ? (_activeLow ? LOW : HIGH)
                          : (_activeLow ? HIGH : LOW));
  }

 private:
  uint8_t _pin;
  bool _activeLow;
};
