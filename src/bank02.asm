.dsection player_graphics
.section player_graphics
PLAYER_GRAPHICS_BANK = `*

PLAYER_TILESET .binary "../gfx/juno/juno.4bp"
NPC_TILESET .binary "../gfx/leif/leif.4bp"
NEWT_TILESET .binary "../gfx/newt/newtrainbow.4bp"

.endsection

.dsection palettes
.section palettes
PALETTE_BANK = `*

; background palettes
LAB_PALETTE .binary "../gfx/lab/lab.pal"
BEDROOM_PALETTE .binary "../gfx/livingrm/livingrm.pal"
TITLE_SCENE_PALETTE .binary "../gfx/title/title.pal"
JOURNAL_PALETTE .binary "../gfx/journal/notepad.pal"
NEWT_PALETTE .binary "../gfx/newt/newtrainbow.pal"

; text palettes
GENEVA_PALETTE .binary "../font/geneva.pal"

; sprite palettes
PLAYER_PALETTE .binary "../gfx/juno/juno.pal"
NPC_PALETTE .binary "../gfx/leif/leif.pal"

.endsection