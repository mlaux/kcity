#!/bin/sh
python3 make-font.py
../../SuperFamiconv/build/release/superfamiconv \
  --verbose \
  --in-image geneva.png \
  --bpp 1 \
  --no-discard \
  --no-flip \
  --out-palette geneva1.palette \
  --out-tiles geneva1.tiles \
  --out-map geneva1.map \
  --out-tiles-image out1.png
