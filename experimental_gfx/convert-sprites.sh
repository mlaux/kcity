#!/bin/sh

../../SuperFamiconv/build/release/superfamiconv \
  --verbose \
  --in-image npc2.png \
  --out-palette player.palette \
  --out-tiles player.tiles \
  --out-tiles-image player-tiles.png \
  --bpp 4 \
  --tile-width 16 \
  --tile-height 16 \
  --palette-base-offset 8 \
  --color-zero 000000
