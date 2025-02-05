TEST_MAP_NAME .text "Industrial zone - south", 255

; 1 is walkable, 0 is blocked
; 0x80 | warp lookup id
; 0x40 | script lookup id

; TODO migrate this map to the image
TEST_SCRIPT_TRIGGERS .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $42, 0, 0, 0, 0, 0
                    .byte 0, 0, $41, 0, 0, $82, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, $41, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  ; filler for final two rows just in case? idk, can probably remove
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

BEDROOM_NAME .text "Juno and Leif's living room", 255

BEDROOM_COLLISION_MAP .binary "../gfx/livingrm/walkmap.cwm"
; TODO: reimplement all of this with the per pixel walking
BEDROOM_SCRIPT_TRIGGERS .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                                ; Hey, don't look in there
                                                ; book titles
                                                ; 1     2    3
                        .byte 0, $43, $43, 0, 0, $44, 0, $45, $46, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $81, $81, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $81, $81, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

START_X .word $50, $60
START_Y .word $40, $90

ALL_MAP_PALETTES .word <>TEST_PALETTE, <>BEDROOM_PALETTE
ALL_TILESETS .word <>TEST_TILESET, <>BEDROOM_TILESET
ALL_TILEMAPS .word <>TEST_TILEMAP, <>BEDROOM_TILEMAP
ALL_TILESET_LENGTHS .word size(TEST_TILESET), size(BEDROOM_TILESET)
; TODO generate test map collision as a .png
COLLISION_MAPS .word BEDROOM_COLLISION_MAP, BEDROOM_COLLISION_MAP
COLLISION_MAP_LENGTHS .word size(BEDROOM_COLLISION_MAP), size(BEDROOM_COLLISION_MAP)
SCRIPT_TRIGGER_MAPS .word TEST_SCRIPT_TRIGGERS, BEDROOM_SCRIPT_TRIGGERS
LOCATION_NAMES .word TEST_MAP_NAME, BEDROOM_NAME
