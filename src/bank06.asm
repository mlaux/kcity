.dsection map_graphics
.section map_graphics

EMBERS_CLOTHING_TILESET .binary "../gfx/embers/embers.4bp"
EMBERS_CLOTHING_TILEMAP .binary "../gfx/embers/embers.map"

SEASHORE_SALON_TILESET .binary "../gfx/seashore/seashore.4bp"
SEASHORE_SALON_TILEMAP .binary "../gfx/seashore/seashore.map"

OPENING_ROOM_PARTS_TILESET .binary "../gfx/opening/roompart.4bp"
OPENING_ROOM_PARTS_TILEMAP .binary "../gfx/opening/roompart.map"
OPENING_DRIP_SCENE_TILESET .binary "../gfx/opening/dripbg.4bp"
OPENING_DRIP_SCENE_TILEMAP .binary "../gfx/opening/dripbg.map"

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
    .fill 128*32, 0
MODE7_TILEMAP_LENGTH = * - MODE7_TILEMAP

.endsection