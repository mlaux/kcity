
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

    clc
    lda current_map_id
    adc player_x
    adc player_y
    adc game_progress
    adc play_time_hms
    adc play_time_hms + 2
    adc play_time_hms + 4
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
    eor #$5555
    cmp sram_checksum
    beq +
    ldx #<>SCRIPT_MESSAGE_SAVE_CORRUPTED
    ldy #3
    jsr set_script
    plp
    rts

+   lda sram_map_id
    sta target_warp_map

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

    plp
    rts

; builds save slot description strings for display in menu
; formats: "1 - 12:34:56" or "1 - empty"
build_save_slot_strings
.al
.xl
    ; build slot 1 string
    ldx #<>sram_slot0_map_id
    ldy #<>save_slot_string1
    lda #'A'
    jsr build_one_slot_string

    ; build slot 2 string
    ldx #<>sram_slot1_map_id
    ldy #<>save_slot_string2
    lda #'B'
    jsr build_one_slot_string

    ; build slot 3 string
    ldx #<>sram_slot2_map_id
    ldy #<>save_slot_string3
    lda #'C'
    jmp build_one_slot_string

static_save_string_char .macro
    lda #\1
    sta $800000,y
    iny
.endmacro

; helper function to build one slot string
; X = SRAM slot base address
; Y = destination string address (in RAM)
; A = slot number character ('1', '2', or '3')
build_one_slot_string
.xl
    php
    phx

    sep #$20
    pha
    ; decision marker
    #static_save_string_char $80
    pla
    ; store slot number
    ;sta $800000,y
    ;iny

    ;#static_save_string_char ' '
    ;#static_save_string_char '-'
    ;#static_save_string_char ' '

    ; check if slot is valid by computing checksum
    rep #$20
    plx

    clc
    lda $700000,x       ; map_id
    adc $700002,x       ; player_x
    adc $700004,x       ; player_y
    adc $700006,x       ; game_progress
    adc $700008,x       ; play_time_hms + 0
    adc $70000a,x       ; play_time_hms + 2
    adc $70000c,x       ; play_time_hms + 4
    eor #$5555
    cmp $70000e,x       ; checksum
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
    lda $700008,x
    clc
    adc #'0'
    sta $800000,y
    iny

    ; hours ones
    lda $700009,x
    clc
    adc #'0'
    sta $800000,y
    iny

    ; colon
    #static_save_string_char ':'

    ; minutes tens
    lda $70000a,x
    clc
    adc #'0'
    sta $800000,y
    iny

    ; minutes ones
    lda $70000b,x
    clc
    adc #'0'
    sta $800000,y
    iny

    #static_save_string_char ' '

    ; get map_id and look up location name
    lda $700000,x
    and #$00ff
    asl
    tax

    ; get pointer to location name string
    lda LOCATION_NAMES - 2,x
    tax

    sep #$20

    ; copy location name string
-   lda $800000,x       ; read character from location name
    cmp #$ff
    beq +
    sta $800000,y       ; write to destination
    iny
    inx
    bra -

    ; terminator
+   #static_save_string_char $ff

    plp
    rts