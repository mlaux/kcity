#!/usr/bin/env python3
"""
SNES Palette Fade Generator

Generates darkened palettes for fade-in/fade-out effects.
Input: SNES palette (up to 16 colors in little-endian BGR555 format)
Output: N palettes, each progressively darker (R, G, B shifted right by 1 each iteration)
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


def darken_palette(palette_bytes):
    """
    Create a darkened version of a palette by shifting R, G, B right by 1.
    Returns the new palette bytes and whether all colors are black.
    """
    new_palette = bytearray()
    all_black = True

    for k in range(0, len(palette_bytes), 2):
        r, g, b = decode_color(palette_bytes[k], palette_bytes[k + 1])

        # Shift right by 1
        r >>= 1
        g >>= 1
        b >>= 1

        if r != 0 or g != 0 or b != 0:
            all_black = False

        new_palette.extend(encode_color(r, g, b))

    return bytes(new_palette), all_black


def generate_fade_palettes(input_palette):
    """
    Generate all fade palettes from the input palette.
    Returns a list of palette bytes.
    """
    palettes = [input_palette]
    current = input_palette

    while True:
        current, all_black = darken_palette(current)
        palettes.append(current)

        if all_black:
            break

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

    print(f"Generated {len(palettes)} palettes ({num_colors} colors each)")
    print(f"Total output size: {len(palettes) * len(input_palette)} bytes")
    print(f"Written to: {args.output}")


if __name__ == '__main__':
    main()
