.dsection player_graphics
.section player_graphics
PLAYER_GRAPHICS_BANK = `*

PLAYER_TILESET .binary "../gfx/animtest/animtest.tiles"
NPC_TILESET .binary "../gfx/animtest/animtest.tiles"

.endsection

.dsection palettes
.section palettes
PALETTE_BANK = `*

; background palettes
TEST_PALETTE .binary "../experimental_gfx/maptest.palette"
BEDROOM_PALETTE .binary "../experimental_gfx/bedroom.palette"

; text palettes
GENEVA_PALETTE .binary "../font/geneva.palette"

; sprite palettes
PLAYER_PALETTE .binary "../gfx/animtest/animtest.palette"
NPC_PALETTE .binary "../gfx/animtest/animtest.palette"

; 256 reserved bytes
FILLER_PALETTES .fill 256

.endsection