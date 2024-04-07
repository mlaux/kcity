; define an ascii encoding
.enc "ascii"
; identity mapping for printable
.cdef " ~", 0

.include "ppu.asm"
.include "cpu.asm"
.include "dma.asm"

; Zero page
* = $0

; text source pointer for VWF routine
vwf_src .word ?
; base address of current tile
vwf_dst .word ?
; base address of next tile
vwf_next .word ?
; font byte currently being shifted/copied
vwf_font_ptr .word ?

; Work RAM variables
; some of these are definitely redundant but made the algorithms easier
* = $100

; 32 tiles * 16 bytes/tile * 4 lines = 1024 bytes
NUM_TILE_BYTES = $400
vwf_tiles .fill NUM_TILE_BYTES

; how many chars to draw
vwf_count .word ?

; the byte currently being processed
vwf_cur_tile_byte .word ?
; the character currently being processed, could maybe optimize this away
vwf_ch .word ?

; the horizontal pixel offset into the current tile
vwf_offs .word ?
vwf_remainder .word ?

; return values for text rendering
vwf_dmasrc .word ?
vwf_dmasrcbank .word ?
vwf_dmadst .word ?
vwf_dmalen .word ?
vwf_end_of_string .word ?

; current tile pointer for currently rendered string
vwf_tilemap_dst .word ?
; current tile id
; ($20 << 8) | (how many tiles have been written to the tilemap so far)
vwf_tilemap_id .word ?

; main vs. nmi flag, nmi is skipped if this is 0
main_loop_done .word ?
frame_counter .word ?

; fadein/fadeout/mosaic
effect_id .word ?
; only need to set this if the effect isn't the opposite of the previous one
effect_level .word ?
; 1, 3, 7, 15, ...
effect_speed .word ?

; temp index into test text array
text_index .word ?
; pointer to string that's being drawn
current_text .word ?

; unused so far
script_id .word ?
script_step .word ?

player_x .word ?
player_y .word ?
player_direction .word ?
player_sprite_id .word ?
player_animation_index .word ?

; place first 32k
.logical $008000
.include "bank00.asm"
.here

; .logical $010000
; .include "bank01.asm"
; .here

; 128k minus one byte
* = $01ffff
.byte 0

; VRAM MAP
; 0000 - 07FF (0000 - 03FF): BG1 tilemap
; 0800 - 0FFF (0400 - 07FF): BG2 tilemap
; 1000 - 17FF (0800 - 0BFF): BG3 tilemap
; 1800 - 1FFF (0C00 - 0FFF): free
; 2000 - 3FFF (1000 - 1FFF): BG1 tiles
; 4000 - 5FFF (2000 - 2FFF): BG2 tiles (currently free)
; 6000 - 63FF (3000 - 31FF): BG3 tiles (variable width text tiles)
; 6400 - 7FFF (3200 - 3FFF): BG3 tiles (other)