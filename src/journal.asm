
state_journal_init
.al
.xl
    lda #EFFECT_MOSAIC_ON
    sta effect_id
    lda #$1
    sta effect_speed
    lda #0
    sta effect_level

-   lda effect_id
    ldx #$1
    stx main_loop_done
    lda effect_id
    bne -

    lda #$19 ; 0x10 = 16x16 tile mode
    sta my_bgmode
    lda #$80
    sta INIDISP

    sep #$20
    jsr load_journal_background

    lda #EFFECT_MOSAIC_OFF
    sta effect_id
    lda #$1
    sta effect_speed
    lda #$f
    sta effect_level

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
    rts

load_journal_background
.as
.xl
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

    lda #$f
    sta my_inidisp
    rts