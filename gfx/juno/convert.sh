#!/bin/sh
set -ex

convert right.png -crop 1x2@ +repage right-split.png
convert front.png -crop 1x2@ +repage front-split.png
convert left.png -crop 1x2@ +repage left-split.png
convert back.png -crop 1x2@ +repage back-split.png

montage right-split-0.png right-split-1.png \
  front-split-0.png front-split-1.png \
  left-split-0.png left-split-1.png \
  back-split-0.png back-split-1.png \
  -background none \
  -tile x1 \
  -geometry +0+0 \
  png8:juno-idle.png

../../../SuperFamiconv/build/release/superfamiconv \
  --verbose \
  --in-image juno-idle.png \
  --out-palette juno-idle.palette \
  --out-tiles juno-idle.tiles \
  --sprite-mode

cat juno-idle.tiles \
      juno-idle.tiles \
      juno-idle.tiles \
      juno-idle.tiles \
      juno-idle.tiles \
      juno-idle.tiles \
      juno-idle.tiles \
      juno-idle.tiles \
  > juno.tiles

rm *split*.png