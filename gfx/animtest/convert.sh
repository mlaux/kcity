#!/bin/sh
set -ex
python3 generate.py

for k in $(seq 0 7)
do

  montage r$k-top.png r$k-bottom.png \
     f$k-top.png f$k-bottom.png \
     l$k-top.png l$k-bottom.png \
     b$k-top.png b$k-bottom.png \
    -background none \
    -tile x1 \
    -geometry +0+0 \
    png8:frame$k.png

  ../../../SuperFamiconv/build/release/superfamiconv \
    --verbose \
    --in-image frame$k.png \
    --out-palette animtest.palette \
    --out-tiles frame$k.tiles \
    --sprite-mode

done

cat frame0.tiles \
      frame1.tiles \
      frame2.tiles \
      frame3.tiles \
      frame4.tiles \
      frame5.tiles \
      frame6.tiles \
      frame7.tiles \
  > animtest.tiles

rm *.png
rm frame*.tiles