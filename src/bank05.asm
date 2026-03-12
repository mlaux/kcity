.dsection sound_bank
.section sound_bank
.binary "../music/build/kcity.smbank", $8000
.endsection

.dsection map_graphics
.section map_graphics

INDUSTRIAL_CORRIDOR_TILESET .binary "../gfx/indust1/indust1.4bp"
INDUSTRIAL_CORRIDOR_TILEMAP .binary "../gfx/indust1/indust1.map"

TITLE_SCENE_TILEMAP_BG1 .binary "../gfx/title/titletext.map"
TITLE_SCENE_TILEMAP_BG2 .binary "../gfx/title/title.map"
.endsection