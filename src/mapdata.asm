TEST_MAP_NAME .text "Industrial zone - south", 255
TEST_PALETTE .binary "../experimental_gfx/maptest.palette"
TEST_TILESET .binary "../experimental_gfx/maptest.tiles"
TEST_TILEMAP .binary "../experimental_gfx/maptest.map"

; 1 is walkable, 0 is blocked
; 0x80 | warp lookup id
; 0x40 | script lookup id
TEST_COLLISION_MAP .byte 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1
                   .byte 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, $42, 0, 1, 1, 1, 1
                   .byte 1, 1, $41, 0, 0, $82, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1
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
                   .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                   .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

BEDROOM_NAME .text "Juno and Leif's room", 255
BEDROOM_PALETTE .binary "../experimental_gfx/bedroom.palette"
BEDROOM_TILESET .binary "../experimental_gfx/bedroom.tiles"
BEDROOM_TILEMAP .binary "../experimental_gfx/bedroom.map"

BEDROOM_COLLISION_MAP .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                      .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                      .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                      .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                      .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                      .byte 0, 0, 0, 0, 0, 0, $43, 1, 1, 1, 1, 1, 0, 0, 0, 0
                      .byte 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0
                      .byte 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0
                      .byte 0, 0, 0, 1, 0, 0, $44, 1, 1, 1, 1, 1, 1, 0, 0, 0
                      .byte 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0
                      .byte 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
                      .byte 0, 0, 0, 0, 0, 0, $81, 0, 0, 0, 0, 0, 0, 0, 0, 0
                      .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                      .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                      .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                      .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

ALL_PALETTES .word TEST_PALETTE, BEDROOM_PALETTE
ALL_TILESETS .word TEST_TILESET, BEDROOM_TILESET
ALL_TILEMAPS .word TEST_TILEMAP, BEDROOM_TILEMAP
ALL_TILESET_LENGTHS .word size(TEST_TILESET), size(BEDROOM_TILESET)
COLLISION_MAPS .word TEST_COLLISION_MAP, BEDROOM_COLLISION_MAP
LOCATION_NAMES .word TEST_MAP_NAME, BEDROOM_NAME

START_X .word $50, $60
START_Y .word $30, $90
