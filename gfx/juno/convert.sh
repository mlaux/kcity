#!/bin/sh
set -ex

# currently we have:
#   * frame 0 for all directions (standing)
#   * frames 1-6 for walking left
# need to produce 8 frames for all directions. walking right will just be
# a horizontal flip of walking left for now. frame 7 is unused for all
# directions so far

# generate placeholder images 1-7 for front and back only, 
# and 7 for left and right. (animation is only 6 frames)
# these are already split into 16x16 top and bottom tiles
python3 generate.py

# flip left 1-6 to generate right 1-6. don't flip 0 because she has actual
# distinct graphics for standing still facing left/right
for k in $(seq 1 6)
do
  magick l$k.png -flop r$k.png
done

# split 0th frame of front and back (standing) into 16x16 parts.
# 1-7 already taken care of by generate.py
magick f0.png -crop 1x2@ +repage f0.png
magick b0.png -crop 1x2@ +repage b0.png

# split frames 0-6 of left and right into 16x16 parts.
# don't need to do 7th because generate.py already did
for k in $(seq 0 6)
do
  magick l$k.png -crop 1x2@ +repage l$k.png
  magick r$k.png -crop 1x2@ +repage r$k.png
done

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
  png8:juno.png

# convert to snes format
../../../SuperFamiconv/build/release/superfamiconv \
  --verbose \
  -W 16 \
  -H 16 \
  --no-remap \
  --in-image juno.png \
  --out-palette juno.pal \
  --out-palette-image juno-pal.png \
  --out-tiles juno.4bp \
  --sprite-mode

# clean up
rm *-0.png
rm *-1.png
rm r[1-7].png