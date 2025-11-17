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
LIVING_ROOM_SCRIPT_TRIGGERS 
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, $83, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, $84, $84, $84, 0, 0, 0
                    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

TEST_MAP_NAME .text "Hub - Central", 255
; can walk anywhere
TEST_COLLISION_MAP .binary "../gfx/testbg/walkmap.cwm"
; no scripts for test map. 1024 zeroes
TEST_SCRIPT_TRIGGERS .binary "../gfx/hub/triggers.bin"

TKS_TAPESTRIES .text "TK's Tapestries", 255
SEASHORE_SALON .text "Seashore Salon", 255
EMBERS_CLOTHING .text "Ember's Clothing", 255
CITY_SERVICES .text "City Services", 255
INDUSTRIAL_CORRIDOR .text "", 255

; $81: start of game -> bedroom
; $82: bedroom -> living room
; $83: living room -> bedroom
; $84: living room -> hub
; $85: hub -> living room
; $86: hub -> TK's
; $87: hub -> industrial zone
; $88: hub -> city services
; $89: hub -> ember's
; $8a: hub -> seashore

WARP_TARGET_MAPS .word 1, 2, 1, 3, 2, 4, 5, 6, 7, 8
WARP_TARGET_X .word $60, $50, $190, $3e0, $170, 0, 0, 0, 0, 0
WARP_TARGET_Y .word $120, $120, $110, $150, $190, 0, 0, 0, 0, 0

START_BGMODE .word $39, $39, $39, $39, $39, $39, $39, $39
START_HOFS .word $0, $0, $0, $0, $0, $0, $0, $0
START_VOFS .word $120, $120, $0, $0, $0, $0, $0, $0
; usually ((map_width - 8) << 1) - 1
MAP_MAX_PLAYER_X .word $1ef, $1ef, $3ef, $1ef, $1ef, $1ef, $1ef, $1ef
; usually (map_height << 1) - 1
MAP_MAX_PLAYER_Y .word $1bf, $1df, $3ff, $1bf, $1bf, $1bf, $1bf, $1bf

ALL_MAP_BANKS .word `BEDROOM_TILESET, `LIVING_ROOM_TILESET, `TEST_MAP_TILESET, `TKS_TAPESTRIES_TILESET, `INDUSTRIAL_CORRIDOR_TILESET, `CITY_SERVICES_TILESET, `EMBERS_CLOTHING_TILESET, `SEASHORE_SALON_TILESET
ALL_MAP_PALETTES .word <>BEDROOM_PALETTE, <>LIVING_ROOM_PALETTE, <>TEST_MAP_PALETTE, <>TKS_TAPESTRIES_PALETTE, <>INDUSTRIAL_CORRIDOR_PALETTE, <>CITY_SERVICES_PALETTE, <>EMBERS_CLOTHING_PALETTE, <>SEASHORE_SALON_PALETTE
ALL_TILESETS .word <>BEDROOM_TILESET, <>LIVING_ROOM_TILESET, <>TEST_MAP_TILESET, <>TKS_TAPESTRIES_TILESET, <>INDUSTRIAL_CORRIDOR_TILESET, <>CITY_SERVICES_TILESET, <>EMBERS_CLOTHING_TILESET, <>SEASHORE_SALON_TILESET
ALL_TILEMAPS .word <>BEDROOM_TILEMAP, <>LIVING_ROOM_TILEMAP, <>TEST_MAP_TILEMAP, <>TKS_TAPESTRIES_TILEMAP, <>INDUSTRIAL_CORRIDOR_TILEMAP, <>CITY_SERVICES_TILEMAP, <>EMBERS_CLOTHING_TILEMAP, <>SEASHORE_SALON_TILEMAP
ALL_TILESET_LENGTHS .word size(BEDROOM_TILESET), size(LIVING_ROOM_TILESET), size(TEST_MAP_TILESET), size(TKS_TAPESTRIES_TILESET), size(INDUSTRIAL_CORRIDOR_TILESET), size(CITY_SERVICES_TILESET), size(EMBERS_CLOTHING_TILESET), size(SEASHORE_SALON_TILESET)
COLLISION_MAPS .addr BEDROOM_COLLISION_MAP, LIVING_ROOM_COLLISION_MAP, TEST_COLLISION_MAP, TEST_COLLISION_MAP, TEST_COLLISION_MAP, TEST_COLLISION_MAP, TEST_COLLISION_MAP, TEST_COLLISION_MAP
COLLISION_MAP_LENGTHS .word size(BEDROOM_COLLISION_MAP), size(LIVING_ROOM_COLLISION_MAP), size(TEST_COLLISION_MAP), size(TEST_COLLISION_MAP), size(TEST_COLLISION_MAP), size(TEST_COLLISION_MAP), size(TEST_COLLISION_MAP), size(TEST_COLLISION_MAP)
SCRIPT_TRIGGER_MAPS .addr BEDROOM_SCRIPT_TRIGGERS, LIVING_ROOM_SCRIPT_TRIGGERS, TEST_SCRIPT_TRIGGERS, TEST_SCRIPT_TRIGGERS, TEST_SCRIPT_TRIGGERS, TEST_SCRIPT_TRIGGERS, TEST_SCRIPT_TRIGGERS, TEST_SCRIPT_TRIGGERS
LOCATION_NAMES .addr BEDROOM_NAME, LIVING_ROOM_NAME, TEST_MAP_NAME, TKS_TAPESTRIES, INDUSTRIAL_CORRIDOR, CITY_SERVICES, EMBERS_CLOTHING, SEASHORE_SALON
; bit 0 = horizontal scroll, bit 1 = vertical scroll, bit 2 = "hub" special vertical scroll
MAP_SCROLL_FLAGS .word 0, 0, %101, 0, 0, 0, 0, 0
; 0 = 256x256, 1 = 512x512
MAP_SIZES .word 0, 0, 1, 0, 0, 0, 0, 0