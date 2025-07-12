JOURNAL_ENTRY_1 .text "I should see what's going on outside.", 255
JOURNAL_ENTRY_2 .text "I checked out Nim's Preserves.", 255
JOURNAL_ENTRY_3 .text "I returned the bowls", 255
JOURNAL_ENTRY_4 .text "String four", 255
JOURNAL_ENTRY_5 .text "String five", 255
JOURNAL_ENTRY_6 .text "String six", 255
JOURNAL_ENTRY_7 .text "String seven", 255
JOURNAL_ENTRY_8 .text "String eight", 255

JOURNAL_ENTRY_TABLE .word JOURNAL_ENTRY_1, JOURNAL_ENTRY_2, JOURNAL_ENTRY_3, JOURNAL_ENTRY_4, JOURNAL_ENTRY_5, JOURNAL_ENTRY_6, JOURNAL_ENTRY_7, JOURNAL_ENTRY_8

open_journal
.al
.xl
    lda #8
    sta game_progress
    ldy #2
    jsr run_state_init
    jmp longjmp_main

close_journal
.al
.xl
    ; pixelate transition
    lda #EFFECT_MOSAIC_ON
    sta effect_id
    lda #$1
    sta effect_speed
    lda #0
    sta effect_level

    jsr wait_for_effect

    ldy #1
    jsr run_state_init

    ; background was left turned off by loading the map
    lda #$f
    sta my_inidisp

    lda #EFFECT_MOSAIC_OFF
    sta effect_id
    lda #$1
    sta effect_speed
    lda #$f
    sta effect_level

    ; wait for mosaic to go away
-   ldx #$1
    stx update_ppu
    lda effect_id
    bne -
    stz update_ppu

    ; all the way out
    jmp longjmp_main

state_journal_init
.al
.xl
    ; make sure all of this is off
    jsr clear_script
    stz text_box_enabled

    ; pixelate transition
    lda #EFFECT_MOSAIC_ON
    sta effect_id
    lda #$1
    sta effect_speed
    lda #0
    sta effect_level

    jsr wait_for_effect

    lda #$39 ; 3 = 16x16 for layers 1 and 2. 9 = mode 1, bg3 priority on
    sta my_bgmode
    lda #816
    sta my_bgvofs
    sta my_bg3vofs

    ; swap backgrounds
    jsr enable_force_blank
    jsr load_journal_background
    jsr draw_journal_text
    jsr disable_force_blank

    ; turn screen back on at nearest convenience
    lda #$f
    sta my_inidisp

    lda #EFFECT_MOSAIC_OFF
    sta effect_id
    lda #$1
    sta effect_speed
    lda #$f
    sta effect_level

    ; wait for mosaic to ALMOST go away
-   ldx #$1
    stx update_ppu
    lda effect_level
    cmp #$3
    bne -
    stz update_ppu

    rts

state_journal
.al
.xl
    dec my_bg2hofs
    dec my_bg2vofs

    lda my_bgvofs
    beq +
    clc
    adc #8
    and #$3ff
    sta my_bgvofs
    sta my_bg3vofs

+   lda joypad_new
    and #(X_BUTTON | B_BUTTON)
    beq +
    jmp close_journal
+   rts

state_journal_vblank
.al
.xl
    ;sep #$20
    ;jmp text_box_vblank
    rts

load_journal_background
.as
.xl
    php
    sep #$20

    ; immediately turn off screen so DMA is possible
    lda #$80
    sta INIDISP

    ; turn off sprites
    lda #(BG1_ON | BG2_ON | BG3_ON)
    sta TM

    ldx #DMAMODE_PPUDATA
    stx DMAMODE

    lda #$80
    sta VMAIN

    ldx #0
    stx VMADD

    #dma_ppu_data PAPER_TILEMAP
    ; bg2 tilemap is right after bg1
    #dma_ppu_data JOURNAL_TILEMAP

    ldx #$2000
    stx VMADD

    #dma_ppu_data JOURNAL_TILESET

    ldx #$1000
    stx VMADD

    #dma_ppu_data PAPER_TILESET

    ldx #DMAMODE_CGDATA
    stx DMAMODE

    lda #$10
    sta CGADD
    #dma_ppu_data JOURNAL_PALETTE

    plp
    rts

draw_journal_text
.al
.xl
    jsr vwf_reset_map
    jsr vwf_reset_tiles

    ; end = progress * 2
    lda game_progress
    asl
    sta zp0

    ; initial y coordinate of message
    lda #9
    sta zp1

    ldx #0

    ; set message address and destination coordinates
-   lda JOURNAL_ENTRY_TABLE, x
    phx
    ldx #9
    ldy zp1
    jsr vwf_init_string

    ; draw entire string
    lda #-1
    sta vwf_count
    jsr vwf_draw_string

    ; force blank is on so go ahead and transfer it over
    ldy vwf_dmalen
    jsr vwf_dma_tiles
    jsr vwf_transfer_map

    ; move to next line of notebook paper
    inc zp1
    inc zp1
    ; move to next string
    plx
    inx
    inx

    cpx zp0
    bne -

    rts