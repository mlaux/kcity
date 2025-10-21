#!/usr/bin/env python3
"""
SNES Palette Fade Generator

Generates darkened palettes for fade-in/fade-out effects.
Input: SNES palette (up to 16 colors in little-endian BGR555 format)
Output: 9 palettes with linear brightness interpolation (8/8 to 0/8 in steps of 1/8)
"""

import sys
import argparse


def read_palette(filename):
    """Read a SNES palette file (32 bytes max for 16 colors)."""
    with open(filename, 'rb') as f:
        data = f.read()

    if len(data) % 2 != 0:
        raise ValueError("Palette file must contain an even number of bytes")

    if len(data) > 32:
        raise ValueError("Palette file too large (max 16 colors = 32 bytes)")

    return data


def decode_color(byte0, byte1):
    """Decode a BGR555 color from two bytes (little-endian)."""
    r = byte0 & 0x1f
    g = ((byte0 >> 5) | ((byte1 & 0x03) << 3)) & 0x1f
    b = ((byte1 >> 2) & 0x1f)
    return r, g, b


def encode_color(r, g, b):
    """Encode RGB555 components back to BGR555 little-endian format."""
    byte0 = (r & 0x1f) | ((g & 0x07) << 5)
    byte1 = ((g >> 3) & 0x03) | ((b & 0x1f) << 2)
    return bytes([byte0, byte1])


def scale_palette(palette_bytes, numerator, denominator):
    """
    Scale a palette's brightness by multiplying each RGB component by numerator/denominator.
    """
    new_palette = bytearray()

    for k in range(0, len(palette_bytes), 2):
        r, g, b = decode_color(palette_bytes[k], palette_bytes[k + 1])

        # Scale each component
        r = (r * numerator) // denominator
        g = (g * numerator) // denominator
        b = (b * numerator) // denominator

        new_palette.extend(encode_color(r, g, b))

    return bytes(new_palette)


def generate_fade_palettes(input_palette):
    """
    Generate 9 fade palettes with linear brightness interpolation.
    Uses steps of 1/8 for cleaner math (8/8, 7/8, 6/8, ..., 1/8, 0/8).
    """
    palettes = []

    for k in range(8, -1, -1):
        palette = scale_palette(input_palette, k, 8)
        palettes.append(palette)

    return palettes


def main():
    parser = argparse.ArgumentParser(
        description='Generate darkened SNES palettes for fade effects'
    )
    parser.add_argument(
        'input',
        help='Input palette file (up to 16 colors, BGR555 little-endian)'
    )
    parser.add_argument(
        'output',
        help='Output file containing all fade palettes'
    )

    args = parser.parse_args()

    # Read input palette
    input_palette = read_palette(args.input)
    num_colors = len(input_palette) // 2

    # Generate fade palettes
    palettes = generate_fade_palettes(input_palette)

    # Write output
    with open(args.output, 'wb') as f:
        for palette in palettes:
            f.write(palette)

    print(f"Generated 9 palettes ({num_colors} colors each)")
    print(f"Brightness steps: 8/8, 7/8, 6/8, 5/8, 4/8, 3/8, 2/8, 1/8, 0/8")
    print(f"Total output size: {len(palettes) * len(input_palette)} bytes")
    print(f"Written to: {args.output}")


if __name__ == '__main__':
    main()
