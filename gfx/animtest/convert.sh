#!/bin/sh
set -ex
python3 generate.py

for k in $(seq 0 7)
do
  magick R$k.png -crop 1x2@ +repage R$k-split.png
  magick F$k.png -crop 1x2@ +repage F$k-split.png
  magick L$k.png -crop 1x2@ +repage L$k-split.png
  magick B$k.png -crop 1x2@ +repage B$k-split.png

  montage R$k-split-0.png R$k-split-1.png \
    F$k-split-0.png F$k-split-1.png \
    L$k-split-0.png L$k-split-1.png \
    B$k-split-0.png B$k-split-1.png \
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