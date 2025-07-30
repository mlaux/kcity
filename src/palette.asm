palette_init
.as
.xl
    ldx #DMAMODE_CGDATA
    stx DMAMODE

    ; destination address in palette ram
    lda #$4
    sta CGADD

    #dma_ppu_data BASIC_TEXT_PALETTE
    lda #$8
    sta CGADD
    #dma_ppu_data INDIE_FLOWER_PALETTE
    lda #$c0
    sta CGADD
    #dma_ppu_data PLAYER_PALETTE
    #dma_ppu_data NPC_PALETTE

    rts