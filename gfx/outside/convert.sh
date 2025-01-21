#!/bin/sh

../../../SuperFamiconv/build/release/superfamiconv \
 --verbose \
 --in-image small32.png \
 --out-palette maptest.pal \
 --out-tiles maptest.4bp \
 --out-map maptest.map \
 --out-tiles-image tiles.png \
 --bpp 4 \
 --tile-width 8 \
 --tile-height 8 \
 --palette-base-offset 1 \
 --color-zero 000000