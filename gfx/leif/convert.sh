#!/bin/sh
set -ex

montage right.png right.png right.png \
  front.png front.png front.png \
  left.png left.png left.png \
  back.png back.png back.png \
  -background none \
  -tile 8x \
  -geometry +0+0 \
  png8:tiles.png

../../../SuperFamiconv/build/release/superfamiconv \
  --verbose \
  --in-image tiles.png \
  --out-palette leif.pal \
  --out-palette-image palette.png \
  --out-tiles leif.4bp \
  --sprite-mode \
  --no-remap
