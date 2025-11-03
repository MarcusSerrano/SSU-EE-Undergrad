#pragma once
#include <Arduino.h>

class RgbLedController {
 public:
  RgbLedController(uint8_t rPin, uint8_t gPin, uint8_t bPin, bool activeLow = true)
  : _r(rPin), _g(gPin), _b(bPin), _activeLow(activeLow) {}

  void begin() {
    pinMode(_r, OUTPUT);
    pinMode(_g, OUTPUT);
    pinMode(_b, OUTPUT);
    // Match your web sliders (0–255)
    analogWriteRange(255);
    set(0, 0, 0);
  }

  void set(uint8_t r, uint8_t g, uint8_t b) {
    // If your LEDs are active-low, invert the duty
    auto drive = [&](uint8_t pin, uint8_t v) {
      analogWrite(pin, _activeLow ? (255 - v) : v);
    };
    drive(_r, r);
    drive(_g, g);
    drive(_b, b);
  }

 private:
  uint8_t _r, _g, _b;
  bool _activeLow;
};
