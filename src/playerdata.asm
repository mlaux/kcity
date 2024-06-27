PLAYER_PALETTE .binary "../experimental_gfx/player.palette"
PLAYER_TILESET .binary "../experimental_gfx/player.tiles"
NPC_PALETTE .binary "../experimental_gfx/npc.palette"
NPC_TILESET .binary "../experimental_gfx/npc.tiles"

; hardcoding for each slot for now
SPRITE_BASE_IDS .word 0, $40

; OAM sprite ids for each direction
; the first in a group is left foot forward, then idle, then right foot forward, then idle again
;                      |     right     |     down      |     left      |        up       |
WALK_CYCLE_TABLE .byte $c, $e, $20, $e, $0, $2, $4, $2, $6, $8, $a, $8, $22, $24, $26, $24