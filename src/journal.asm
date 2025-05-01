open_journal
.al
.xl
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

    ; swap backgrounds
    jsr enable_force_blank
    jsr load_journal_background
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

+   lda joypad_new
    and #(X_BUTTON | B_BUTTON)
    beq +
    jmp close_journal
+   rts

state_journal_vblank
.al
.xl
    sep #$20
    jmp text_box_vblank
    ;rts

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