#!/bin/sh

../../../SuperFamiconv/build/release/superfamiconv \
  --verbose \
  --in-image test.png \
  --out-palette livingrm.pal \
  --out-tiles livingrm.4bp \
  --out-map livingrm.map \
  --out-tiles-image tiles.png \
  --bpp 4 \
  --tile-width 8 \
  --tile-height 8 \
  --palette-base-offset 1 \
  --color-zero 00000000