#!/bin/sh
set -ex
python3 generate.py

cp ../juno/l*.png .
rm left.png
for k in $(seq 1 6)
do
  magick convert l$k.png -crop 1x2@ +repage l$k.png
done

montage \
    ../juno/right-split-0.png ../juno/right-split-1.png \
    ../juno/front-split-0.png ../juno/front-split-1.png \
    ../juno/left-split-0.png ../juno/left-split-1.png \
    ../juno/back-split-0.png ../juno/back-split-1.png \
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
  png8:animtest.png

../../../SuperFamiconv/build/release/superfamiconv \
  --verbose \
  -W 16 \
  -H 16 \
  --no-remap \
  --in-image animtest.png \
  --out-palette animtest.pal \
  --out-palette-image animtest-palette.png.temp \
  --out-tiles animtest.4bp \
  --sprite-mode

rm *.png
mv animtest-palette.png.temp animtest-palette.png