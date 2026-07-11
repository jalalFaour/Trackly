"""Hardware configuration presets for common Pico + LCD setups."""

# I2C bus configurations
I2C_CONFIGS = {
    'pico_default': {'bus': 0, 'sda': 0, 'scl': 1, 'freq': 400000},
    'pico_alt': {'bus': 0, 'sda': 4, 'scl': 5, 'freq': 100000},  # Your working setup!
    'pico_i2c1': {'bus': 1, 'sda': 6, 'scl': 7, 'freq': 100000},
}

# LCD backpack presets (PCF8574 pin mappings)
LCD_PRESETS = {
    'clone_20x4': {'addr': 0x27, 'masks': {'BL': 0x08, 'RS': 0x01, 'EN': 0x04}, 'size': (20, 4)},
    'clone_16x2': {'addr': 0x27, 'masks': {'BL': 0x08, 'RS': 0x01, 'EN': 0x04}, 'size': (16, 2)},
    'variant_blue': {'addr': 0x3F, 'masks': {'BL': 0x20, 'RS': 0x01, 'EN': 0x04}, 'size': (20, 4)},
}