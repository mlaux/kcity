.as
.xl
.autsiz
.databank $80
.dpage $0000

; define an ascii encoding
.enc "ascii"
; identity mapping for printable
.cdef " ~", 0

.include "ppu.asm"
.include "cpu.asm"
.include "dma.asm"

sln .macro
    .rept \1
    asl
    .endrept
.endmacro

srn .macro
    .rept \1
    lsr
    .endrept
.endmacro

; Zero page
* = $0
.dsection zeropage
.section zeropage

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
vwf_dst_bottom .word ?
vwf_next_bottom .word ?
; font byte currently being shifted/copied
vwf_font_ptr .word ?

script_ptr .word ?
script_element_ptr .word ?
text_box_lines .word ?
script_trigger_map_ptr .word ?
facing_object_script .word ?

; --- start from snesmod ---
spc_ptr .fill 3
spc_v .fill 1
spc_bank .fill 1

spc1 .fill 2
spc2 .fill 2

spc_fread .fill 1
spc_fwrite .fill 1

; port record [for interruption]
spc_pr .fill 4

digi_src .fill 3
digi_src2 .fill 3

SoundTable .fill 3
; --- end from snesmod ---

.endsection

.warn "zero page end: ", *

; Work RAM variables
; some of these are definitely redundant but made the algorithms easier
.virtual $800000
RAM_BASE = *
.dsection work_ram
.section work_ram
* = $800100

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

vwf_font_base .word ?

; current tile pointer for currently rendered string
vwf_tilemap_dst .word ?
; current tile id
; ($20 << 8) | (how many tiles have been written to the tilemap so far)
vwf_tilemap_id .word ?
vwf_tilemap_id_high_byte .word ?

; font type for current text rendering (0=8x8, 1=8x16)
vwf_font_type .word ?

game_state .word ?
state_transitioning .word ?

; main vs. nmi flag, nmi is skipped if this is 0
update_ppu .word ?
; nmi re-entrancy guard, set to 1 when inside NMI handler
in_nmi .word ?
frame_counter .word ?
frame_counter_mod_60 .word ?
rng_state .fill 4
play_time_hms .fill 6

joypad_current .word ?
joypad_last .word ?
joypad_new .word ?

; fadein/fadeout/mosaic
effect_id .word ?
; only need to set this if the effect isn't the opposite of the previous one
effect_level .word ?
; 1, 3, 7, 15, ...
effect_speed .word ?

script_step .word ?
script_length .word ?
script_step_time_remaining .word ?
script_step_result .word ?

script_storage .fill $20
script_storage_result = script_storage

current_script_slot .word ?
NUM_SCRIPT_SLOTS = 8
script_slot_ptr .fill 2 * NUM_SCRIPT_SLOTS
script_slot_element_ptr .fill 2 * NUM_SCRIPT_SLOTS
script_slot_step .fill 2 * NUM_SCRIPT_SLOTS
script_slot_length .fill 2 * NUM_SCRIPT_SLOTS
script_slot_time_remaining .fill 2 * NUM_SCRIPT_SLOTS
script_slot_result .fill 2 * NUM_SCRIPT_SLOTS

my_inidisp .word ?
my_bgmode .word ?
my_mosaic .word ?
my_bghofs .word ?
my_bgvofs .word ?
my_bg2hofs .word ?
my_bg2vofs .word ?
my_bg3hofs .word ?
my_bg3vofs .word ?
my_tm .word ?

my_m7sel .word ?
my_m7a .word ?
my_m7b .word ?
my_m7c .word ?
my_m7d .word ?
my_m7x .word ?
my_m7y .word ?

title_snail_frame .word ?
title_dragonfly_frame .word ?
title_dragonfly_y_base .word ?
title_dragonfly_y_lookup .word ?

; todo use same memory as other stuff for these, only used on title screen
title_animation_step .word ?
title_animation_frame .word ?
opening_timer = title_animation_frame
title_appear_delay .word ?
title_solid_palette .word ?
title_state_palette .word ?
title_palette_fade_frame .word ?
title_tile_anim_frame .word ?
title_tile_anim_step .word ?
title_tile_anim_delay .word ?

game_progress .word ?

NUM_OAM_ENTRIES = 16
OAM_MAIN_LENGTH = NUM_OAM_ENTRIES * 4
OAM_AUX_LENGTH = NUM_OAM_ENTRIES / 4
oam_data_main .fill OAM_MAIN_LENGTH
oam_data_aux .fill OAM_AUX_LENGTH

oam_data_x = oam_data_main + 0
oam_data_y = oam_data_main + 1
oam_data_id = oam_data_main + 2
oam_data_flag = oam_data_main + 3

; player is the first two entries in the above tables
player_x_sprite = oam_data_x
player_x_head_sprite = oam_data_x + 4
player_y_sprite = oam_data_y
player_y_head_sprite = oam_data_y + 4
player_sprite_id = oam_data_id
player_sprite_id_head = oam_data_id + 4
player_visibility_flags = oam_data_flag
player_visibility_flags_head = oam_data_flag + 4

; for calculating animation
; one entry no matter the sprite size
sprites_anim_direction .fill 2 * NUM_OAM_ENTRIES
sprites_anim_previous_direction .fill 2 * NUM_OAM_ENTRIES
sprites_anim_offset .fill 2 * NUM_OAM_ENTRIES
sprites_anim_timer .fill 2 * NUM_OAM_ENTRIES

player_anim_direction = sprites_anim_direction
player_anim_previous_direction = sprites_anim_previous_direction
player_anim_offset = sprites_anim_offset
player_anim_timer = sprites_anim_timer

; x/y position of bottom middle in half pixels
; SNES top left sprite X = (player_x - 16) >> 1
; SNES top left sprite Y = (player_y - 32) >> 1
player_x .word ?
player_y .word ?
; last known direction for persistence purposes. not related to animation
; direction, which returns to 0 when player is not moving
; PLAYER_DIRECTION_* - 1
player_direction .word ?
player_locked .word ?

; per-sprite ROM tile data address (32-bit: 16-bit addr, 8-bit bank, 8-bit pad)
; 8 entries for all sprite slots (0 = player, 1-7 = objects)
; indexed by sprite_id * 4
NUM_SPRITE_SLOTS = 8
object_sprite_data .fill 4 * NUM_SPRITE_SLOTS

; object system - slots 1-7 (slot 0 is the player)
; indexed by (sprite_slot - 1) * 2
MAX_OBJECTS = 7
num_active_objects .word ?
object_x .fill 2 * MAX_OBJECTS
object_y .fill 2 * MAX_OBJECTS
object_flags .fill 2 * MAX_OBJECTS
object_interaction_script .fill 2 * MAX_OBJECTS
object_bg_script .fill 2 * MAX_OBJECTS
object_num_anim_frames .fill 2 * MAX_OBJECTS

text_box_enabled .word ?
; index of string (0-3) currently being drawn
text_index .word ?
text_box_init_requested .word ?
text_box_clear_requested .word ?
text_box_hide_requested .word ?
; should be using a different dma channel for this
text_box_hdma_table .fill $9
title_glitch_hdma_table .fill $13

text_box_x .word ?
text_box_y .word ?
text_box_width .word ?
text_box_num_lines .word ?

MAX_TEXT_BOX_OPTIONS = 4
; 0-3, nonzero means decision is active
text_box_num_options .word ?
; also 0-3
text_box_active_option .word ?
; address in tilemap of each option
text_box_option_positions .fill 2 * MAX_TEXT_BOX_OPTIONS

target_warp_id .word ?
target_map_id .word ?
target_player_x .word ?
target_player_y .word ?
current_map_id .word ?
current_map_size .word ?
current_map_scroll_flags .word ?
; might not need these, can depend on the collision data
current_map_max_player_x .word ?
current_map_max_player_y .word ?
; current_map_max_scroll_y .word ?
map_transition_wait .word ?
location_name_script .fill DISPLAY_LOCATION_NAME_LENGTH

; "1 - Location - 12:34:56"
SAVE_SLOT_STRING_SIZE = 64
save_slot_string1 .fill SAVE_SLOT_STRING_SIZE
save_slot_string2 .fill SAVE_SLOT_STRING_SIZE
save_slot_string3 .fill SAVE_SLOT_STRING_SIZE

saved_bghofs .word ?
saved_bgvofs .word ?

MAX_DMA_QUEUE_ENTRIES = 16
dma_queue_length .word ?
dma_queue_entry_mode .fill 2 * MAX_DMA_QUEUE_ENTRIES
dma_queue_entry_addr .fill 2 * MAX_DMA_QUEUE_ENTRIES
dma_queue_entry_addr_bank .fill 2 * MAX_DMA_QUEUE_ENTRIES
dma_queue_entry_length .fill 2 * MAX_DMA_QUEUE_ENTRIES
dma_queue_entry_vmadd .fill 2 * MAX_DMA_QUEUE_ENTRIES
dma_queue_entry_vmain .fill 2 * MAX_DMA_QUEUE_ENTRIES

; $700 bytes is enough for 4 full lines of 24 'M's lol
.align $10
NUM_TILE_BYTES = $c00
vwf_tiles .fill NUM_TILE_BYTES

; --- start from snesmod ---

spc_fifo .fill 256	; 128-byte command fifo
spc_sfx_next .fill 1
spc_q .fill 1

digi_init .fill 1
digi_pitch .fill 1
digi_vp .fill 1
digi_remain .fill 2
digi_active .fill 1
digi_copyrate .fill 1

; --- end from snesmod ---

.endsection
.cerror * > $801400, "ram too long"
.warn "lowram end: ", *
.endvirtual

* = $700000

SAVE_SLOT_SIZE = 16
NUM_SAVE_SLOTS = 3

; save slot 0
sram_map_id .word ?
sram_player_x .word ?
sram_player_y .word ?
sram_game_progress .word ?
sram_play_time_hms .fill 6
sram_checksum .word ?

sram_offset_slot0 = 0
sram_offset_slot1 = SAVE_SLOT_SIZE
sram_offset_slot2 = 2 * SAVE_SLOT_SIZE

.warn "sram end: ", *

* = $7e2000

; need 32k (1/4 of the entire ram) for 1bpp 512x512px...
; might want to reduce collision resolution to 2x2 blocks at some point
; instead of per-pixel, but i'm not short on ram at all
collision_map .fill $8000

.warn "other ram end: ", *

* = $0

; place first 32k
.logical $808000
.dsection bank00
.section bank00
.include "bank00.asm"
.endsection bank00
.cerror * > $810000, "bank00 too long"
.here

* = $8000
.logical $818000
.dsection bank01
.section bank01
.include "bank01.asm"
.endsection bank01
.warn format("bank01 free space: $%04x", $820000 - *)
.cerror * > $820000, format("bank01 too long by $%04x", * - $820000)
.here

* = $10000
.logical $828000
.dsection bank02
.section bank02
.include "bank02.asm"
.endsection bank02
.warn format("bank02 free space: $%04x", $830000 - *)
.cerror * > $830000, "bank02 too long"
.here

* = $18000
.logical $838000
.dsection bank03
.section bank03
.include "bank03.asm"
.endsection bank03
.warn format("bank03 free space: $%04x", $840000 - *)
.cerror * > $840000, "bank03 too long"
.here

* = $20000
.logical $848000
.dsection bank04
.section bank04
.include "bank04.asm"
.endsection bank04
.warn format("bank04 free space: $%04x", $850000 - *)
.cerror * > $850000, "bank04 too long"
.here

* = $28000
.logical $858000
.dsection bank05
.section bank05
.include "bank05.asm"
.endsection bank05
.warn format("bank05 free space: $%04x", $860000 - *)
.cerror * > $860000, "bank05 too long"
.here

* = $30000
.logical $868000
.dsection bank06
.section bank06
.include "bank06.asm"
.endsection bank06
.warn format("bank06 free space: $%04x", $870000 - *)
.cerror * > $870000, format("bank06 too long by $%04x", * - $870000)
.here

* = $38000
.logical $878000
.dsection bank07
.section bank07
.include "bank07.asm"
.endsection bank07
.warn format("bank07 free space: $%04x", $880000 - *)
.cerror * > $880000, format("bank07 too long by $%04x", * - $880000)
.here

; 256k minus one byte
* = $03ffff
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