#!/bin/sh
python3 make-font.py
../../SuperFamiconv/build/release/superfamiconv -v --in-image geneva.png --out-palette geneva.palette --out-tiles geneva.tiles --out-map geneva.map
