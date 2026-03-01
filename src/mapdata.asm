; 0x80 | warp lookup id
; 0x40 | script lookup id
; with the per pixel walking, actions have to be on tile boundaries
; until i figure out a more robust way

BEDROOM_NAME .text "Juno and Leif's bedroom", 255
BEDROOM_COLLISION_MAP .binary "../gfx/bedroom/walkmap.cwm"
BEDROOM_SCRIPT_TRIGGERS .binary "../gfx/bedroom/triggers.bin"

LIVING_ROOM_NAME .text "Juno and Leif's living room", 255
LIVING_ROOM_COLLISION_MAP .binary "../gfx/livingrm/walkmap.cwm"
LIVING_ROOM_SCRIPT_TRIGGERS .binary "../gfx/livingrm/triggers.bin"

HUB_NAME .text "Hub - Central", 255
; can walk anywhere
TEST_COLLISION_MAP .binary "../gfx/testbg/walkmap.cwm"
HUB_SCRIPT_TRIGGERS .binary "../gfx/hub/triggers.bin"

TKS_TAPESTRIES .text "TK's Tapestries", 255
TKS_SCRIPT_TRIGGERS .binary "../gfx/tk/triggers.bin"
INDUSTRIAL_CORRIDOR .text "", 255
INDUSTRIAL_CORRIDOR_SCRIPT_TRIGGERS .binary "../gfx/indust1/triggers.bin"
CITY_SERVICES .text "City Services", 255
CITY_SERVICES_SCRIPT_TRIGGERS .binary "../gfx/services/triggers.bin"
EMBERS_CLOTHING .text "Ember's Clothing", 255
EMBERS_CLOTHING_SCRIPT_TRIGGERS .binary "../gfx/embers/triggers.bin"
SEASHORE_SALON .text "Seashore Salon", 255
SEASHORE_SALON_SCRIPT_TRIGGERS .binary "../gfx/seashore/triggers.bin"

; --- begin per-warp tables ---

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
; $8b: TK's -> hub
; $8c: industrial zone -> hub
; $8d: city services -> hub
; $8e: ember's -> hub
; $8f: seashore -> hub

WARP_TARGET_MAPS
    ; J+L's house, <-> hub
    .word 1, 2, 1, 3, 2
    ; hub -> stores
    .word 4, 5, 6, 7, 8
    ; stores -> hub
    .word 3, 3, 3, 3, 3

WARP_TARGET_X
;c0, 160
    .word $c0, $50, $190, $3e0, $170
    .word 224, $e0, $100, $b0, $110
    .word 704, 880, 144, 320, 432

WARP_TARGET_Y
    .word $15f, $120, $110, $150, $190
    .word 352, $160, $140, $160, $160
    .word 320, 320, 352, 352, 352

; --- begin per-map tables ---

ALL_MAP_BANKS 
    .word `BEDROOM_TILESET
    .word `LIVING_ROOM_TILESET
    .word `TEST_MAP_TILESET
    .word `TKS_TAPESTRIES_TILESET
    .word `INDUSTRIAL_CORRIDOR_TILESET
    .word `CITY_SERVICES_TILESET
    .word `EMBERS_CLOTHING_TILESET
    .word `SEASHORE_SALON_TILESET

ALL_MAP_PALETTES 
    .word <>BEDROOM_PALETTE
    .word <>LIVING_ROOM_PALETTE
    .word <>TEST_MAP_PALETTE
    .word <>TKS_TAPESTRIES_PALETTE
    .word <>INDUSTRIAL_CORRIDOR_PALETTE
    .word <>CITY_SERVICES_PALETTE
    .word <>EMBERS_CLOTHING_PALETTE
    .word <>SEASHORE_SALON_PALETTE

ALL_TILESETS
    .word <>BEDROOM_TILESET
    .word <>LIVING_ROOM_TILESET
    .word <>TEST_MAP_TILESET
    .word <>TKS_TAPESTRIES_TILESET
    .word <>INDUSTRIAL_CORRIDOR_TILESET
    .word <>CITY_SERVICES_TILESET
    .word <>EMBERS_CLOTHING_TILESET
    .word <>SEASHORE_SALON_TILESET

ALL_TILEMAPS
    .word <>BEDROOM_TILEMAP
    .word <>LIVING_ROOM_TILEMAP
    .word <>TEST_MAP_TILEMAP
    .word <>TKS_TAPESTRIES_TILEMAP
    .word <>INDUSTRIAL_CORRIDOR_TILEMAP
    .word <>CITY_SERVICES_TILEMAP
    .word <>EMBERS_CLOTHING_TILEMAP
    .word <>SEASHORE_SALON_TILEMAP

ALL_TILESET_LENGTHS
    .word size(BEDROOM_TILESET)
    .word size(LIVING_ROOM_TILESET)
    .word size(TEST_MAP_TILESET)
    .word size(TKS_TAPESTRIES_TILESET)
    .word size(INDUSTRIAL_CORRIDOR_TILESET)
    .word size(CITY_SERVICES_TILESET)
    .word size(EMBERS_CLOTHING_TILESET)
    .word size(SEASHORE_SALON_TILESET)

COLLISION_MAPS
    .addr BEDROOM_COLLISION_MAP
    .addr LIVING_ROOM_COLLISION_MAP
    .addr TEST_COLLISION_MAP
    .addr TEST_COLLISION_MAP
    .addr TEST_COLLISION_MAP
    .addr TEST_COLLISION_MAP
    .addr TEST_COLLISION_MAP
    .addr TEST_COLLISION_MAP

COLLISION_MAP_LENGTHS
    .word size(BEDROOM_COLLISION_MAP)
    .word size(LIVING_ROOM_COLLISION_MAP)
    .word size(TEST_COLLISION_MAP)
    .word size(TEST_COLLISION_MAP)
    .word size(TEST_COLLISION_MAP)
    .word size(TEST_COLLISION_MAP)
    .word size(TEST_COLLISION_MAP)
    .word size(TEST_COLLISION_MAP)

SCRIPT_TRIGGER_MAPS
    .addr BEDROOM_SCRIPT_TRIGGERS
    .addr LIVING_ROOM_SCRIPT_TRIGGERS
    .addr HUB_SCRIPT_TRIGGERS
    .addr TKS_SCRIPT_TRIGGERS
    .addr INDUSTRIAL_CORRIDOR_SCRIPT_TRIGGERS
    .addr CITY_SERVICES_SCRIPT_TRIGGERS
    .addr EMBERS_CLOTHING_SCRIPT_TRIGGERS
    .addr SEASHORE_SALON_SCRIPT_TRIGGERS

LOCATION_NAMES
    .addr BEDROOM_NAME
    .addr LIVING_ROOM_NAME
    .addr HUB_NAME
    .addr TKS_TAPESTRIES
    .addr INDUSTRIAL_CORRIDOR
    .addr CITY_SERVICES
    .addr EMBERS_CLOTHING
    .addr SEASHORE_SALON

START_BGMODE
    .word $39, $39, $39, $39
    .word $39, $39, $39, $39

START_HOFS
    .word $0, $0, $0, $0
    .word $0, $0, $0, $0

START_VOFS
    .word $120, $120, $0, $0
    .word $0, $0, $0, $0

; usually ((map_width - 8) << 1) - 1
MAP_MAX_PLAYER_X
    .word $1ef, $1ef, $3ef, $1ef
    .word $1ef, $1ef, $1ef, $1ef

; usually (map_height << 1) - 1
MAP_MAX_PLAYER_Y
    .word $1bf, $1df, $3ff, $1bf
    .word $1bf, $1bf, $1bf, $1bf

; bit 0 = horizontal scroll
; bit 1 = vertical scroll
; bit 2 = "hub" special split 512x256 vertical scroll
MAP_SCROLL_FLAGS
    .word 0, 0, %101, 0
    .word 0, 0, 0, 0

; 0 = 256x256, 1 = 512x512
MAP_SIZES
    .word 0, 0, 1, 0
    .word 0, 0, 0, 0