TEST .namespace  
MAP_NAME .text "Industrial zone - south", 255

; 1 is walkable, 0 is blocked
; 0x80 | warp lookup id
; 0x40 | script lookup id
COLLISION_MAP .byte 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1
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
.endnamespace
BEDROOM .namespace  
MAP_NAME .text "Juno and Leif's room", 255

COLLISION_MAP .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
              .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
              .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
              .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
              .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
              .byte 0, 0, 0, 0, 0, 0, $43, 1, $44, $45, $46, 1, 0, 0, 0, 0
              .byte 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0
              .byte 0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0
              .byte 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0
              .byte 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0
              .byte 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
              .byte 0, 0, 0, 0, 0, 0, $81, 0, 0, 0, 0, 0, 0, 0, 0, 0
              .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
              .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
              .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
              .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.endnamespace

START_X .word $50, $60
START_Y .word $30, $90

ALL_MAP_DATA := [TEST,BEDROOM] ; now you can add a new namespace name here and the tables bellow will auto fill out

ALL_PALETTES .word <>(ALL_MAP_DATA).PALETTE
ALL_TILESETS .word <>(ALL_MAP_DATA).TILESET
ALL_TILEMAPS .word <>(ALL_MAP_DATA).TILEMAP
ALL_TILESET_LENGTHS .word size((ALL_MAP_DATA).TILESET)
COLLISION_MAPS .word (ALL_MAP_DATA).COLLISION_MAP
LOCATION_NAMES .word (ALL_MAP_DATA).MAP_NAME
