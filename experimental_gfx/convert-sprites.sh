#!/bin/sh

../../SuperFamiconv/build/release/superfamiconv \
  --verbose \
  --in-image player-tiles.png \
  --out-palette player.palette \
  --out-tiles player.tiles \
  --out-tiles-image player-tiles2.png \
  --sprite-mode \
  --bpp 4 \
  --tile-width 8 \
  --tile-height 8 \
  --palette-base-offset 8 \
  --color-zero 000000 \
  --no-flip
