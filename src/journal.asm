
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

    ; wait for effect to be done
-   lda effect_id
    ldx #$1
    stx main_loop_done
    lda effect_id
    bne -

    lda #$19 ; 0x10 = 16x16 tile mode
    sta my_bgmode

    ; swap backgrounds
    jsr load_journal_background

    ; turn screen back on at nearest convenience
    lda #$f
    sta my_inidisp

    lda #EFFECT_MOSAIC_OFF
    sta effect_id
    lda #$1
    sta effect_speed
    lda #$f
    sta effect_level

    ; wait for mosaic to go away
-   lda effect_id
    ldx #$1
    stx main_loop_done
    lda effect_id
    bne -

    rts

state_journal
.al
.xl
    dec my_bghofs
    dec my_bgvofs

    rts

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
    lda #(BG1_ON | BG3_ON)
    sta TM

    ldx #DMAMODE_PPUDATA
    stx DMAMODE

    lda #$80
    sta VMAIN

    ldx #0
    stx VMADD

    #dma_ppu_data JOURNAL_TILEMAP

    ldx #$1000
    stx VMADD

    #dma_ppu_data JOURNAL_TILESET

    ldx #DMAMODE_CGDATA
    stx DMAMODE

    lda #$10
    sta CGADD
    #dma_ppu_data JOURNAL_PALETTE

    plp
    rts