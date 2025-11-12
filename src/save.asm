
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
    php
    rep #$20

    ; build slot 1 string
    ldx #<>save_slot_string1
    ldy #<>sram_slot0_map_id
    lda #'1'
    jsr build_one_slot_string

    ; build slot 2 string
    ldx #<>save_slot_string2
    ldy #<>sram_slot1_map_id
    lda #'2'
    jsr build_one_slot_string

    ; build slot 3 string
    ldx #<>save_slot_string3
    ldy #<>sram_slot2_map_id
    lda #'3'
    jsr build_one_slot_string

    plp
    rts

; helper function to build one slot string
; X = destination string address (in RAM)
; Y = SRAM slot base address
; A = slot number character ('1', '2', or '3')
build_one_slot_string
.al
.xl
    phb
    phx
    phy
    pha

    sep #$20
    pha
    lda #$70
    pha
    plb
.databank $70
    lda #$80
    sta $7e0000,x
    inx
    pla
    ; store slot number
    sta $7e0000,x
    inx

    ; store " - "
    lda #' '
    sta $7e0000,x
    inx
    lda #'-'
    sta $7e0000,x
    inx
    lda #' '
    sta $7e0000,x
    inx

    ; check if slot is valid by computing checksum
    rep #$20
    pla
    ply

    clc
    lda $700000,y       ; map_id
    adc $700002,y       ; player_x
    adc $700004,y       ; player_y
    adc $700006,y       ; game_progress
    adc $700008,y       ; play_time_hms + 0
    adc $70000a,y       ; play_time_hms + 2
    adc $70000c,y       ; play_time_hms + 4
    eor #$5555
    cmp $70000e,y       ; checksum
    beq _slot_valid

_slot_empty
    sep #$20
    lda #'e'
    sta $7e0000,x
    inx
    lda #'m'
    sta $7e0000,x
    inx
    lda #'p'
    sta $7e0000,x
    inx
    lda #'t'
    sta $7e0000,x
    inx
    lda #'y'
    sta $7e0000,x
    inx
    lda #$ff
    sta $7e0000,x
    rep #$20
    plx
    plb
    rts

_slot_valid
    ; format time as HH:MM:SS
    ; play_time_hms is at offset 8 from slot base
    tya
    clc
    adc #8
    tay

    sep #$20

    ; hours tens
    lda $700000,y
    clc
    adc #'0'
    sta $7e0000,x
    inx

    ; hours ones
    lda $700001,y
    clc
    adc #'0'
    sta $7e0000,x
    inx

    ; colon
    lda #':'
    sta $7e0000,x
    inx

    ; minutes tens
    lda $700002,y
    clc
    adc #'0'
    sta $7e0000,x
    inx

    ; minutes ones
    lda $700003,y
    clc
    adc #'0'
    sta $7e0000,x
    inx

    ; colon
    lda #':'
    sta $7e0000,x
    inx

    ; seconds tens
    lda $700004,y
    clc
    adc #'0'
    sta $7e0000,x
    inx

    ; seconds ones
    lda $700005,y
    clc
    adc #'0'
    sta $7e0000,x
    inx

    ; terminator
    lda #$ff
    sta $7e0000,x

    rep #$20
    plx
    plb
.databank $80
    rts