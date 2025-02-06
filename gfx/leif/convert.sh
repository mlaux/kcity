#!/bin/sh
set -ex

# currently we have only frame 0 for all directions (standing)

# generate placeholder images 1-7 for all directions
# these are already split into 16x16 top and bottom tiles
python3 generate.py

# split standing into 16x16
magick r0.png -crop 1x2@ +repage r0.png
magick f0.png -crop 1x2@ +repage f0.png
magick l0.png -crop 1x2@ +repage l0.png
magick b0.png -crop 1x2@ +repage b0.png

# make grid of all the parts
montage \
    r0-0.png r0-1.png f0-0.png f0-1.png l0-0.png l0-1.png b0-0.png b0-1.png \
    r1-0.png r1-1.png f1-0.png f1-1.png l1-0.png l1-1.png b1-0.png b1-1.png \
    r2-0.png r2-1.png f2-0.png f2-1.png l2-0.png l2-1.png b2-0.png b2-1.png \
    r3-0.png r3-1.png f3-0.png f3-1.png l3-0.png l3-1.png b3-0.png b3-1.png \
    r4-0.png r4-1.png f4-0.png f4-1.png l4-0.png l4-1.png b4-0.png b4-1.png \
    r5-0.png r5-1.png f5-0.png f5-1.png l5-0.png l5-1.png b5-0.png b5-1.png \
    r6-0.png r6-1.png f6-0.png f6-1.png l6-0.png l6-1.png b6-0.png b6-1.png \
    r7-0.png r7-1.png f7-0.png f7-1.png l7-0.png l7-1.png b7-0.png b7-1.png \
  -background none \
  -tile 8x \
  -geometry +0+0 \
  png8:leif.png

# convert to snes format
../../../SuperFamiconv/build/release/superfamiconv \
  --verbose \
  -W 16 \
  -H 16 \
  --no-remap \
  --in-image leif.png \
  --out-palette leif.pal \
  --out-palette-image leif-pal.png \
  --out-tiles leif.4bp \
  --sprite-mode

# clean up
rm *-0.png
rm *-1.png