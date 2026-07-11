"""
lcd_i2c.py — Robust I2C LCD driver for HD44780 + PCF8574 (clone-friendly)

Supports 16x2, 20x4, and other HD44780-compatible displays.
Tested with clone Raspberry Pi Pico + generic I2C LCD modules.

Author: Your Name
License: MIT
"""

import utime
from machine import I2C


class LCD_I2C:
    """
    Driver for HD44780 LCD with PCF8574 I2C backpack.

    Args:
        i2c (machine.I2C): Initialized I2C instance
        addr (int): I2C address of PCF8574 (default: 0x27)
        bl_mask (int): Backlight bit mask (default: 0x08)
        rs_mask (int): Register Select bit mask (default: 0x01)
        en_mask (int): Enable bit mask (default: 0x04)
        cols (int): Number of columns (default: 20)
        rows (int): Number of rows (default: 4)
    """

    # Common PCF8574 backpack mappings (for quick presets)
    PRESETS = {
        'default': {'BL': 0x08, 'RS': 0x01, 'EN': 0x04},  # Most clones
        'variant_a': {'BL': 0x08, 'RS': 0x00, 'EN': 0x02},  # Some boards
        'variant_b': {'BL': 0x20, 'RS': 0x01, 'EN': 0x04},  # Others
    }

    # Row address offsets for common LCD sizes
    ROW_OFFSETS = {
        (2, 16): [0x00, 0x40],
        (4, 16): [0x00, 0x40, 0x10, 0x50],
        (4, 20): [0x00, 0x40, 0x14, 0x54],  # Your 20x4 display
        (2, 20): [0x00, 0x40],
    }

    def __init__(self, i2c, addr=0x27, bl_mask=0x08, rs_mask=0x01, 
                 en_mask=0x04, cols=20, rows=4):
        self.i2c = i2c
        self.addr = addr
        self.BL = bl_mask
        self.RS = rs_mask
        self.EN = en_mask
        self.cols = cols
        self.rows = rows
        self._offsets = self.ROW_OFFSETS.get((rows, cols), 
                                             [0x00, 0x40, 0x14, 0x54][:rows])
        self._init_lcd()

    def _pulse(self, data):
        """Generate Enable pulse to latch data/command."""
        self.i2c.writeto(self.addr, bytes([data | self.EN]))
        utime.sleep_us(1)
        self.i2c.writeto(self.addr, bytes([data & ~self.EN]))
        utime.sleep_us(50)

    def _write4(self, nibble, rs=0):
        """Send 4 bits (nibble) to LCD in 4-bit mode."""
        flags = self.BL | (self.RS if rs else 0)
        self._pulse((nibble & 0xF0) | flags)
        self._pulse(((nibble << 4) & 0xF0) | flags)

    def cmd(self, command):
        """Send a command to the LCD."""
        self._write4(command, rs=0)
        # Special timing for clear/home commands
        if command in (0x01, 0x02):
            utime.sleep_ms(5)
        else:
            utime.sleep_ms(2)

    def data(self, char):
        """Send a data byte (character) to the LCD."""
        self._write4(char, rs=1)

    def _init_lcd(self):
        """Initialize LCD using HD44780 4-bit startup sequence."""
        utime.sleep_ms(50)  # Wait for power-up
        
        # Reset sequence: force into 4-bit mode
        for cmd in [0x33, 0x32, 0x28, 0x0C, 0x06, 0x01]:
            self._write4(cmd, rs=0)
            utime.sleep_ms(2 if cmd != 0x01 else 5)
        
        self.clear()

    def clear(self):
        """Clear display and return cursor to home."""
        self.cmd(0x01)

    def home(self):
        """Return cursor to home position (0,0)."""
        self.cmd(0x02)

    def set_cursor(self, col, row):
        """Move cursor to specified column and row (0-indexed)."""
        if 0 <= row < len(self._offsets):
            addr = 0x80 | (col + self._offsets[row])
            self.cmd(addr)

    def print_line(self, row, text, col=0):
        """Print text at specified row (and optional column)."""
        self.set_cursor(col, row)
        for c in text[:self.cols - col]:
            self.data(ord(c))

    def print(self, text, row=0, col=0):
        """Print text at position (convenience wrapper)."""
        self.set_cursor(col, row)
        for c in text:
            self.data(ord(c))

    def backlight_on(self):
        """Turn backlight on."""
        self.BL = 0x08  # Restore default; adjust if needed
        self.cmd(0x0C)  # Display on, cursor off, blink off

    def backlight_off(self):
        """Turn backlight off."""
        self.BL = 0x00
        self.cmd(0x0C)

    def display_on(self, cursor=False, blink=False):
        """Control display visibility and cursor."""
        cmd = 0x08 | (0x04 if True else 0) | (0x02 if cursor else 0) | (0x01 if blink else 0)
        self.cmd(cmd)

    @classmethod
    def from_preset(cls, i2c, preset='default', addr=0x27, cols=20, rows=4):
        """
        Create LCD instance using a known backpack preset.
        
        Example:
            lcd = LCD_I2C.from_preset(i2c, preset='default', cols=20, rows=4)
        """
        if preset not in cls.PRESETS:
            raise ValueError(f"Unknown preset: {preset}. Available: {list(cls.PRESETS.keys())}")
        masks = cls.PRESETS[preset]
        return cls(i2c, addr, 
                   bl_mask=masks['BL'], 
                   rs_mask=masks['RS'], 
                   en_mask=masks['EN'],
                   cols=cols, rows=rows)