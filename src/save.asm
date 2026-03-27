save_exists
.al
.xl
    php
    rep #$20

    clc
    lda sram_map_id
    adc sram_player_x
    adc sram_player_y
    adc sram_game_progress
    adc sram_play_time_hms
    adc sram_play_time_hms + 2
    adc sram_play_time_hms + 4
    adc sram_rng_state
    eor #$5555
    cmp sram_checksum
    beq +
    lda #0
    plp
    rts
+   lda #1
    plp
    rts

save_game
.al
.xl
    php
    rep #$20

    lda current_map_id
    sta sram_map_id
    lda player_x
    sta sram_player_x
    lda player_y
    sta sram_player_y
    lda game_progress
    sta sram_game_progress
    lda play_time_hms
    sta sram_play_time_hms
    lda play_time_hms + 2
    sta sram_play_time_hms + 2
    lda play_time_hms + 4
    sta sram_play_time_hms + 4
    lda rng_state
    sta sram_rng_state

    clc
    lda current_map_id
    adc player_x
    adc player_y
    adc game_progress
    adc play_time_hms
    adc play_time_hms + 2
    adc play_time_hms + 4
    adc rng_state
    eor #$5555
    sta sram_checksum

    ; only shows it when saving with select button, menu is its own script
    ; so this one does not run. menu has its own 'Saved' message
    ldx #<>SCRIPT_MESSAGE_SAVED
    ldy #3
    jsr set_script

    plp
    rts

load_game
.al
.xl
    php
    rep #$20

    clc
    lda sram_map_id
    adc sram_player_x
    adc sram_player_y
    adc sram_game_progress
    adc sram_play_time_hms
    adc sram_play_time_hms + 2
    adc sram_play_time_hms + 4
    adc sram_rng_state
    eor #$5555
    cmp sram_checksum
    beq +
    ldx #<>SCRIPT_MESSAGE_SAVE_CORRUPTED
    ldy #3
    jsr set_script
    plp
    rts

+   lda sram_map_id
    sta target_map_id

    lda sram_player_x
    sta target_player_x

    lda sram_player_y
    sta target_player_y

    lda sram_game_progress
    sta game_progress

    lda sram_play_time_hms
    sta play_time_hms
    lda sram_play_time_hms + 2
    sta play_time_hms + 2
    lda sram_play_time_hms + 4
    sta play_time_hms + 4
    
    lda sram_rng_state
    sta rng_state

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
    lda sram_map_id,x       ; map_id
    adc sram_player_x,x       ; player_x
    adc sram_player_y,x       ; player_y
    adc sram_game_progress,x       ; game_progress
    adc sram_play_time_hms,x       ; play_time_hms + 0
    adc sram_play_time_hms + 2,x       ; play_time_hms + 2
    adc sram_play_time_hms + 4,x       ; play_time_hms + 4
    adc sram_rng_state,x
    eor #$5555
    cmp sram_checksum,x       ; checksum
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