#!/bin/sh

convert lab.png -colors 24 test.png

../../../SuperFamiconv/build/release/superfamiconv \
  --verbose \
  --in-image test.png \
  --out-palette lab.pal \
  --out-tiles lab.4bp \
  --out-map lab.map \
  --out-tiles-image tiles.png \
  --bpp 4 \
  --tile-width 8 \
  --tile-height 8 \
  --palette-base-offset 1 \
  --color-zero 00000000