.dsection player_graphics
.section player_graphics
PLAYER_GRAPHICS_BANK = `*

PLAYER_TILESET .binary "../gfx/animtest/animtest.4bp"
NPC_TILESET .binary "../gfx/animtest/animtest.4bp"

.endsection

.dsection palettes
.section palettes
PALETTE_BANK = `*

; background palettes
TEST_PALETTE .binary "../gfx/outside/maptest.pal"
BEDROOM_PALETTE .binary "../gfx/livingrm/livingrm.pal"

; text palettes
GENEVA_PALETTE .binary "../font/geneva.pal"

; sprite palettes
PLAYER_PALETTE .binary "../gfx/juno/idle.pal"
NPC_PALETTE .binary "../gfx/animtest/animtest.pal"

; 256 reserved bytes
FILLER_PALETTES .fill 256

.endsection