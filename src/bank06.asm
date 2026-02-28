.dsection map_graphics
.section map_graphics

EMBERS_CLOTHING_TILESET .binary "../gfx/embers/embers.4bp"
EMBERS_CLOTHING_TILEMAP .binary "../gfx/embers/embers.map"

SEASHORE_SALON_TILESET .binary "../gfx/seashore/seashore.4bp"
SEASHORE_SALON_TILEMAP .binary "../gfx/seashore/seashore.map"

.endsection

.dsection opening_graphics
.section opening_graphics

MODE7_PALETTE
    .word $7fff     ; 0: white
    .word $4210     ; 1: gray
    .fill 254*2, 0  ; 2-255: unused
MODE7_PALETTE_LENGTH = * - MODE7_PALETTE

MODE7_TILE0
    ; concentric square (8x8, 8bpp, 1 byte per pixel)
    .byte 1,1,1,1,1,1,1,1
    .byte 1,0,0,0,0,0,0,1
    .byte 1,0,0,0,0,0,0,1
    .byte 1,0,0,0,0,0,0,1
    .byte 1,0,0,0,0,0,0,1
    .byte 1,0,0,0,0,0,0,1
    .byte 1,0,0,0,0,0,0,1
    .byte 1,1,1,1,1,1,1,1
MODE7_TILE0_LENGTH = * - MODE7_TILE0

MODE7_TILEMAP
    .fill 128*128
MODE7_TILEMAP_LENGTH = * - MODE7_TILEMAP

.endsection