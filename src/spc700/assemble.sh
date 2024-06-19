#!/bin/sh
set -ex
/Users/mlaux/dev/snes/terrific-audio-driver/target/release/tad-compiler \
    ca65-export \
    --output-asm kcity-audio.s \
    --output-bin kcity-audio.bin \
    --segment BANK1 \
    --lorom ../../music/kcity.terrificaudio
ca65 -DLOROM kcity-audio.s -o kcity-audio.o
ca65 -DLOROM tad-audio.s -o tad-audio.o
ld65 -o kcity-audio.sfc -m kcity-audio-map.txt -vm -C kcity-lorom.cfg *.o
rm *.o
rm kcity-audio.s
rm kcity-audio.bin