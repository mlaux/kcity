.as
.xl
.autsiz
.databank $00
.dpage $0000

; define an ascii encoding
.enc "ascii"
; identity mapping for printable
.cdef " ~", 0

.include "ppu.asm"
.include "cpu.asm"
.include "dma.asm"
.include "tad-api.asm"

SCREEN_WIDTH = 256
SCREEN_HEIGHT = 224

; Zero page
* = $0
.dsection sZP
.warn "zero page end: ", *

; Work RAM variables
; some of these are definitely redundant but made the algorithms easier
* = $100
.dsection sWorkRAM
.warn "lowram end: ", *

.section sZP
zp0 .word ?
zp1 .word ?
; used from both "main thread" and vblank, todo push if needed to avoid
; "NES tetris crash bug"
zp2 .word ?
zp3 .word ?

script_ptr .word ?
script_element_ptr .word ?
text_box_lines .word ?
collision_map_ptr .word ?
facing_object_script .word ?
.send ;sZP



.section sWorkRAM

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

script_step .word ?
script_length .word ?
script_step_time_remaining .word ?

script_storage .fill $20

; for all sprites including player
sprites_x .fill 2 * NUM_OAM_ENTRIES
sprites_y .fill 2 * NUM_OAM_ENTRIES
sprites_id .fill 2 * NUM_OAM_ENTRIES
sprites_flag .fill 2 * NUM_OAM_ENTRIES
sprites_direction .fill 2 * NUM_OAM_ENTRIES
sprites_previous_direction .fill 2 * NUM_OAM_ENTRIES
sprites_animation_index .fill 2 * NUM_OAM_ENTRIES

; player is the first entry in the above tables
player_x = sprites_x
player_x_head = sprites_x + 2
player_y = sprites_y
player_y_head = sprites_y + 2
player_sprite_id = sprites_id
player_sprite_id_head = sprites_id + 2
player_visibility_flags = sprites_flag
player_visibility_flags_head = sprites_flag + 2

; for calculating animation
player_direction = sprites_direction
player_previous_direction = sprites_previous_direction
player_animation_index = sprites_animation_index

player_locked .word ?

text_box_enabled .word ?
; should be using a different dma channel for this
text_box_hdma_table .fill $9

text_box_x .word ?
text_box_y .word ?
text_box_width .word ?
text_box_num_lines .word ?

target_warp_map .word ?
target_player_x .word ?
target_player_y .word ?
current_map_id .word ?
location_name_script .fill DISPLAY_LOCATION_NAME_LENGTH

NUM_OAM_ENTRIES = 16
OAM_MAIN_LENGTH = NUM_OAM_ENTRIES * 4
OAM_AUX_LENGTH = NUM_OAM_ENTRIES / 4
oam_data_main .fill OAM_MAIN_LENGTH
oam_data_aux .fill OAM_AUX_LENGTH
.send ;sWorkRAM

* = $700000

sram_map_id .word ?
sram_player_x .word ?
sram_player_y .word ?

.warn "sram end: ", *

* = $0

; place first 32k
.logical $8000
.dsection bank00
.section bank00
.include "bank00.asm"
.endsection bank00
.cerror * > $10000, "bank00 too long"
.here

.logical $18000
.dsection bank01
.section bank01
;.binary "spc700/kcity-audio.sfc", $1000, $8000
.endsection bank01
.here

.logical $28000
.dsection bank02
.section bank02
.include "bank02.asm"
.endsection bank02
.cerror * > $30000, "bank02 too long"
.here

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