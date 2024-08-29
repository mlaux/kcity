#!/bin/sh
set -ex

montage right.png right.png right.png \
  front.png front.png front.png \
  left.png left.png left.png \
  back.png back.png back.png \
  -background none \
  -tile 8x \
  -geometry +0+0 \
  png8:juno-tiles.png

../../../SuperFamiconv/build/release/superfamiconv \
  --verbose \
  --in-image juno-tiles.png \
  --out-palette juno.palette \
  --out-tiles juno.tiles \
  --sprite-mode