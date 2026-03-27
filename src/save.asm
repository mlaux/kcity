slot_offsets .word 0, SAVE_SLOT_SIZE, 2 * SAVE_SLOT_SIZE

; convert slot number (1-3) in A to byte offset in X
slot_number_to_offset
.al
.xl
    dec a
    asl
    tax
    lda slot_offsets,x
    tax
    rts

; set text_box_active_option to the index of the current save slot
set_active_option_to_current_slot
.al
.xl
    rep #$20
    lda current_save_slot_offset
    beq _set
    cmp #SAVE_SLOT_SIZE
    bne +
    lda #1
    bra _set
+   lda #2
_set
    sta text_box_active_option
    rts

; check if slot in SCRIPT_STORAGE_SAVE_SLOT is valid
; stores 1 (valid) or 0 (empty) into SCRIPT_STORAGE_TEMP_RESULT
check_selected_slot_valid
.al
.xl
    rep #$20
    lda script_storage + (SCRIPT_STORAGE_SAVE_SLOT * 2)
    jsr slot_number_to_offset
    jsr save_exists
    sta script_storage + (SCRIPT_STORAGE_TEMP_RESULT * 2)
    rts

; X = slot byte offset (0, SAVE_SLOT_SIZE, or 2*SAVE_SLOT_SIZE)
save_exists
.al
.xl
    clc
    lda sram_map_id,x
    adc sram_player_x,x
    adc sram_player_y,x
    adc sram_game_progress,x
    adc sram_play_time_hms,x
    adc sram_play_time_hms + 2,x
    adc sram_play_time_hms + 4,x
    eor #$5555
    cmp sram_checksum,x
    beq +
    lda #0
    rts
+   lda #1
    rts

; X = slot byte offset (0, SAVE_SLOT_SIZE, or 2*SAVE_SLOT_SIZE)
save_game
.al
.xl
    php
    rep #$20

    lda current_map_id
    sta sram_map_id,x
    lda player_x
    sta sram_player_x,x
    lda player_y
    sta sram_player_y,x
    lda game_progress
    sta sram_game_progress,x
    lda play_time_hms
    sta sram_play_time_hms,x
    lda play_time_hms + 2
    sta sram_play_time_hms + 2,x
    lda play_time_hms + 4
    sta sram_play_time_hms + 4,x

    stx current_save_slot_offset

    clc
    lda current_map_id
    adc player_x
    adc player_y
    adc game_progress
    adc play_time_hms
    adc play_time_hms + 2
    adc play_time_hms + 4
    eor #$5555
    sta sram_checksum,x

    ; only shows it when saving with select button, menu is its own script
    ; so this one does not run. menu has its own 'Saved' message
    ldx #<>SCRIPT_MESSAGE_SAVED
    ldy #3
    jsr set_script

    plp
    rts

; X = slot byte offset (0, SAVE_SLOT_SIZE, or 2*SAVE_SLOT_SIZE)
load_game
.al
.xl
    php
    rep #$20

    clc
    lda sram_map_id,x
    adc sram_player_x,x
    adc sram_player_y,x
    adc sram_game_progress,x
    adc sram_play_time_hms,x
    adc sram_play_time_hms + 2,x
    adc sram_play_time_hms + 4,x
    eor #$5555
    cmp sram_checksum,x
    beq +
    ldx #<>SCRIPT_MESSAGE_SAVE_CORRUPTED
    ldy #3
    jsr set_script
    plp
    rts

+   stx current_save_slot_offset

    lda sram_map_id,x
    sta target_map_id

    lda sram_player_x,x
    sta target_player_x

    lda sram_player_y,x
    sta target_player_y

    lda sram_game_progress,x
    sta game_progress

    lda sram_play_time_hms,x
    sta play_time_hms
    lda sram_play_time_hms + 2,x
    sta play_time_hms + 2
    lda sram_play_time_hms + 4,x
    sta play_time_hms + 4

    plp
    rts

; builds save slot description strings for display in menu
; formats: "1 - 12:34:56" or "1 - empty"
build_save_slot_strings
.al
.xl
    ldx #<>sram_offset_slot0
    ldy #<>save_slot_string1
    jsr build_one_slot_string

    ldx #<>sram_offset_slot1
    ldy #<>save_slot_string2
    jsr build_one_slot_string

    ldx #<>sram_offset_slot2
    ldy #<>save_slot_string3
    jmp build_one_slot_string

static_save_string_char .macro
    lda #\1
    sta RAM_BASE,y
    iny
.endmacro

; helper function to build one slot string
; X = 16-bit slot base address (0, $10, $20)
; Y = destination string address (in RAM)
build_one_slot_string
.xl
    php

    sep #$20
    ; decision marker
    #static_save_string_char $80
    rep #$20

    ; check if slot is valid by computing checksum
    clc
    lda sram_map_id,x
    adc sram_player_x,x
    adc sram_player_y,x
    adc sram_game_progress,x
    adc sram_play_time_hms,x
    adc sram_play_time_hms + 2,x
    adc sram_play_time_hms + 4,x
    eor #$5555
    cmp sram_checksum,x
    beq _slot_valid

_slot_empty
    sep #$20
    #static_save_string_char 'e'
    #static_save_string_char 'm'
    #static_save_string_char 'p'
    #static_save_string_char 't'
    #static_save_string_char 'y'
    #static_save_string_char $ff
    plp
    rts

_slot_valid
; need to specify .al again because _slot_empty sets to .as and assembler
; doesn't follow control flow
.al
    ; X = SRAM slot base address
    ; Y = destination string pointer
    ; hours tens
    lda sram_play_time_hms,x
    clc
    adc #'0'
    sta RAM_BASE,y
    iny

    ; hours ones
    lda sram_play_time_hms + 1,x
    clc
    adc #'0'
    sta RAM_BASE,y
    iny

    #static_save_string_char ':'

    ; minutes tens
    lda sram_play_time_hms + 2,x
    clc
    adc #'0'
    sta RAM_BASE,y
    iny

    ; minutes ones
    lda sram_play_time_hms + 3,x
    clc
    adc #'0'
    sta RAM_BASE,y
    iny

    #static_save_string_char ' '

    ; get map_id and look up location name
    lda sram_map_id,x
    and #$00ff
    asl
    tax

    ; get pointer to location name string
    lda LOCATION_NAMES - 2,x
    tax

    sep #$20

    ; copy location name string
-   lda RAM_BASE,x
    cmp #$ff
    beq +
    sta RAM_BASE,y
    iny
    inx
    bra -

    ; terminator
+   #static_save_string_char $ff

    plp
    rts