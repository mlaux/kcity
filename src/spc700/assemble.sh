#!/bin/sh
set -ex
/Users/mlaux/dev/snes/terrific-audio-driver/target/release/tad-compiler \
    ca65-export \
    --output-asm kcity-audio.s \
    --output-bin kcity-audio.bin \
    --segment BANK2 \
    --lorom ../../music/kcity.terrificaudio
ca65 -DLOROM kcity-audio.s -o kcity-audio.o
ca65 -DLOROM tad-audio.s -o tad-audio.o
ld65 -o kcity-audio.sfc --dbgfile kcity-audio.dbg -m kcity-audio-map.txt -C kcity-lorom.cfg *.o
split -d -b 32768 kcity-audio.sfc audio-bank
mv audio-bank01 audio-bank02.bin
mv audio-bank00 audio-bank01.bin