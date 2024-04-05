#!/bin/sh

../../SuperFamiconv/build/release/superfamiconv \
  --verbose \
  --in-image small32.png \
  --out-palette maptest.palette \
  --out-tiles maptest.tiles \
  --out-map maptest.map \
  --out-tiles-image maptest-tiles.png \
  --bpp 4 \
  --tile-width 8 \
  --tile-height 8 \
  --palette-base-offset 1 \
  --no-remap
