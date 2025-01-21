#!/bin/sh
set -ex
python3 generate.py

cp ../juno/l*.png .
for k in $(seq 1 6)
do
  magick convert l$k.png -crop 1x2@ +repage l$k.png
  mv l$k-0.png l$k-top.png
  mv l$k-1.png l$k-bottom.png
done

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
    --out-palette animtest.pal \
    --out-tiles frame$k.4bp \
    --sprite-mode

done

cp ../juno/idle.4bp frame0.4bp

cat frame0.4bp \
      frame1.4bp \
      frame2.4bp \
      frame3.4bp \
      frame4.4bp \
      frame5.4bp \
      frame6.4bp \
      frame7.4bp \
  > animtest.4bp

rm *.png