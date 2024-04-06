#!/bin/sh
# python3 make-font.py
../../SuperFamiconv/build/release/superfamiconv \
  --verbose \
  --in-image geneva.png \
  --bpp 2 \
  --no-discard \
  --no-flip \
  --color-zero ff00ff \
  --out-tiles geneva.tiles \
  --out-map geneva.map \
  --out-tiles-image out.png
