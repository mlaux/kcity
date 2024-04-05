#!/bin/sh
../../SuperFamiconv/build/release/superfamiconv \
  --verbose \
  --in-image "test32.png" \
  --tile-width 16 \
  --tile-height 16 \
  --bpp 4 \
  --out-palette maptest.palette \
  --out-tiles maptest.tiles \
  --out-map maptest.map \
  --out-tiles-image maptest.png
