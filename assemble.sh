#!/bin/sh

AS="../64tass-1.59.3120-src/64tass"
"$AS" --ascii \
    --m65816 \
    --long-address \
    --nostart \
    -o out.sfc \
    --map out.map \
    --mesen-labels --labels-section=bank00.code --labels-add-prefix=SnesPrgRom \
    --labels out.mlb \
    --list out.list \
    --verbose-list \
    src/kcity.asm
# python3 generate-sym.py out.vice