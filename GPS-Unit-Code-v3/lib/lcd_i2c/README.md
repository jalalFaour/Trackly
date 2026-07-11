# micropython-lcd-i2c

Robust I2C LCD driver for HD44780 + PCF8574, optimized for clone Raspberry Pi Pico boards.

## Features
- ✅ Clone-friendly bit masks & timing
- ✅ Support for 16x2, 20x4, and custom sizes
- ✅ Preset configurations for common backpacks
- ✅ Clean, documented, importable API

## Quick Start
```python
from machine import I2C, Pin
from lcd_i2c import LCD_I2C

i2c = I2C(0, sda=Pin(4), scl=Pin(5), freq=100000)
lcd = LCD_I2C(i2c, cols=20, rows=4)
lcd.print("Hello!", row=0)