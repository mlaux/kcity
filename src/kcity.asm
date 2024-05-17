; define an ascii encoding
.enc "ascii"
; identity mapping for printable
.cdef " ~", 0

.include "ppu.asm"
.include "cpu.asm"
.include "dma.asm"

SCREEN_WIDTH = 256
SCREEN_HEIGHT = 224

; Zero page
* = $0

zp0 .word ?
zp1 .word ?
; used from both "main thread" and vblank, todo push if needed to avoid
; "NES tetris crash bug"
zp2 .word ?
zp3 .word ?

; text source pointer for VWF routine
vwf_src .word ?
; base address of current tile
vwf_dst .word ?
; base address of next tile
vwf_next .word ?
; font byte currently being shifted/copied
vwf_font_ptr .word ?

script_ptr .word ?
script_element_ptr .word ?
text_box_lines .word ?
collision_map_ptr .word ?
facing_object_script .word ?

; Work RAM variables
; some of these are definitely redundant but made the algorithms easier
* = $100

; $700 bytes is enough for 4 full lines of 24 'M's lol
NUM_TILE_BYTES = $700
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

joypad_current .word ?
joypad_last .word ?
joypad_new .word ?

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
script_step .word ?
script_length .word ?
script_step_start_frame .word ?

; for OAM
player_x .word ?
player_y .word ?
player_sprite_id .word ?

; for calculating animation
player_direction .word ?
player_previous_direction .word ?
player_animation_index .word ?
player_locked .word ?

text_box_enabled .word ?
text_box_hdma_table .fill $9

text_box_x .word ?
text_box_y .word ?
text_box_width .word ?
text_box_num_lines .word ?

target_warp_map .word ?
location_name_script .fill DISPLAY_LOCATION_NAME_LENGTH

* = $0

; place first 32k
.logical $008000
.dsection bank00
.cerror * > $10000, "bank00 too long"
.here

.section bank00
.include "bank00.asm"
.endsection bank00

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