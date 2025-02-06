.dsection player_graphics
.section player_graphics
PLAYER_GRAPHICS_BANK = `*

PLAYER_TILESET .binary "../gfx/juno/animtest.4bp"
NPC_TILESET .binary "../gfx/leif/leif.4bp"

.endsection

.dsection palettes
.section palettes
PALETTE_BANK = `*

; background palettes
LAB_PALETTE .binary "../gfx/lab/lab.pal"
BEDROOM_PALETTE .binary "../gfx/livingrm/livingrm.pal"

; text palettes
GENEVA_PALETTE .binary "../font/geneva.pal"

; sprite palettes
PLAYER_PALETTE .binary "../gfx/juno/animtest.pal"
NPC_PALETTE .binary "../gfx/leif/leif.pal"

; 256 reserved bytes
FILLER_PALETTES .fill 224

.endsection