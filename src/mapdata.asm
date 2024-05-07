
TEST_PALETTE .binary "../experimental_gfx/maptest.palette"
TEST_TILESET .binary "../experimental_gfx/maptest.tiles"
TEST_TILEMAP .binary "../experimental_gfx/maptest.map"

BEDROOM_PALETTE .binary "../experimental_gfx/bedroom.palette"
BEDROOM_TILESET .binary "../experimental_gfx/bedroom.tiles"
BEDROOM_TILEMAP .binary "../experimental_gfx/bedroom.map"

ALL_PALETTES .word TEST_PALETTE, BEDROOM_PALETTE
ALL_TILESETS .word TEST_TILESET, BEDROOM_TILESET
ALL_TILEMAPS .word TEST_TILEMAP, BEDROOM_TILEMAP
ALL_TILESET_LENGTHS .word size(TEST_TILESET), size(BEDROOM_TILESET)

; 1 is walkable, 0 is blocked, i guess next is to make (0x80 | map id) be a warp or something
TEST_COLLISION_MAP .byte 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1
                   .byte 1, 1, 1, 0, 0, $82, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1
                   .byte 1, 1, 1, 0, 0, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1
                   .byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
                   .byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
                   .byte 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1
                   .byte 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1
                   .byte 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1
                   .byte 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1
                   .byte 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1
                   .byte 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1
                   .byte 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1
                   .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1
                   .byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1

; filler for final two rows just in case? idk, can probably remove
.fill $20

BEDROOM_COLLISION_MAP .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                      .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                      .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                      .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                      .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                      .byte 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0
                      .byte 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0
                      .byte 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0
                      .byte 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0
                      .byte 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0
                      .byte 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
                      .byte 0, 0, 0, 0, 0, 0, $81, 0, 0, 0, 0, 0, 0, 0, 0, 0

.fill $40

COLLISION_MAPS .word TEST_COLLISION_MAP, BEDROOM_COLLISION_MAP

START_X .word $20, $60
START_Y .word $40, $90
