#!/bin/sh
# python3 make-font.py
../../SuperFamiconv/build/release/superfamiconv \
  --verbose \
  --in-image geneva.png \
  --bpp 2 \
  --no-discard \
  --no-flip \
  --no-remap \
  --out-tiles geneva.2bp \
  --out-map geneva.map \
  --out-tiles-image out.png \
  --out-palette geneva.pal
