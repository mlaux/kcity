; 0x80 | warp lookup id
; 0x40 | script lookup id
; with the per pixel walking, actions have to be on tile boundaries
; until i figure out a more robust way

BEDROOM_NAME .text "Juno and Leif's bedroom", 255
BEDROOM_COLLISION_MAP .binary "../gfx/bedroom/walkmap.cwm"
BEDROOM_SCRIPT_TRIGGERS .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, $44, $41, $42, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $43, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $82, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                        .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

LIVING_ROOM_NAME .text "Juno and Leif's living room", 255
LIVING_ROOM_COLLISION_MAP .binary "../gfx/livingrm/walkmap.cwm"
LIVING_ROOM_SCRIPT_TRIGGERS .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
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
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, $81, $81, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

TEST_MAP_NAME .text "Scroll test", 255
; can walk anywhere
TEST_COLLISION_MAP .binary "../gfx/testbg/walkmap.cwm"
; no scripts for test map. 1024 zeroes
TEST_SCRIPT_TRIGGERS .fill $400

START_X .word $60, $40, $60
START_Y .word $120, $e0, $120
START_BGMODE .word $39, $39, $39
START_HOFS .word $0, $0, $0
START_VOFS .word $120, $120, $0
; (map_width - 16) << 1, in half-pixels
MAP_MAX_PLAYER_X .word 480, 480, 992 
; (map_height - 16) << 1, in half-pixels
MAP_MAX_PLAYER_Y .word 416, 416, 992

ALL_MAP_PALETTES .word <>BEDROOM_PALETTE, <>LIVING_ROOM_PALETTE, <>TEST_MAP_PALETTE
ALL_TILESETS .word <>BEDROOM_TILESET, <>LIVING_ROOM_TILESET, <>TEST_MAP_TILESET
ALL_TILEMAPS .word <>BEDROOM_TILEMAP, <>LIVING_ROOM_TILEMAP, <>TEST_MAP_TILEMAP
ALL_TILESET_LENGTHS .word size(BEDROOM_TILESET), size(LIVING_ROOM_TILESET), size(TEST_MAP_TILESET)
COLLISION_MAPS .addr BEDROOM_COLLISION_MAP, LIVING_ROOM_COLLISION_MAP, TEST_COLLISION_MAP
COLLISION_MAP_LENGTHS .word size(BEDROOM_COLLISION_MAP), size(LIVING_ROOM_COLLISION_MAP), size(TEST_COLLISION_MAP)
SCRIPT_TRIGGER_MAPS .addr BEDROOM_SCRIPT_TRIGGERS, LIVING_ROOM_SCRIPT_TRIGGERS, TEST_SCRIPT_TRIGGERS
LOCATION_NAMES .addr BEDROOM_NAME, LIVING_ROOM_NAME, TEST_MAP_NAME
; bit 0 = horizontal scroll, bit 1 = vertical scroll
MAP_SCROLL_FLAGS .word 0, 0, 3
; 0 = 256x256, 1 = 512x512
MAP_SIZES .word 0, 0, 1