#!/bin/sh
find . -name .DS_Store | xargs rm -r
rm -f kcity.zip
zip --DOS-names -r kcity.zip src gfx font
