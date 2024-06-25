#!/bin/sh
set -ex

../../SuperFamiconv/build/release/superfamiconv \
  --in-image npc2.png \
  --out-tiles-image player-tiles.png \
  -W 16 -H 16 \
  --no-discard \
  --no-flip

../../SuperFamiconv/build/release/superfamiconv \
  --verbose \
  --in-image player-tiles.png \
  --out-palette player.palette \
  --out-tiles player.tiles \
  --out-tiles-image player-tiles-out.png \
  --sprite-mode \
  --bpp 4 \
  --tile-width 8 \
  --tile-height 8 \
  --palette-base-offset 8 \
  --color-zero 000000 \
  --no-flip

../../SuperFamiconv/build/release/superfamiconv \
  --in-image npc4.png \
  --out-tiles-image npc-tiles.png \
  -W 16 -H 16 \
  --no-discard \
  --no-flip

../../SuperFamiconv/build/release/superfamiconv \
  --verbose \
  --in-image npc-tiles.png \
  --out-palette npc.palette \
  --out-tiles npc.tiles \
  --out-tiles-image npc-tiles-out.png \
  --sprite-mode \
  --bpp 4 \
  --tile-width 8 \
  --tile-height 8 \
  --palette-base-offset 9 \
  --color-zero 000000 \
  --no-flip
