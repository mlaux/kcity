#!/bin/sh
set -ex

montage right.png right.png right.png \
  front.png front.png front.png \
  left.png left.png left.png \
  back.png back.png back.png \
  -background none \
  -tile 8x \
  -geometry +0+0 \
  png8:leif-tiles.png

../../../SuperFamiconv/build/release/superfamiconv \
  --verbose \
  --in-image leif-tiles.png \
  --out-palette leif.palette \
  --out-palette-image leif-palette.png \
  --out-tiles leif.tiles \
  --sprite-mode \
  --no-remap
