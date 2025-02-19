palette_init
.as
.xl
    ldx #DMAMODE_CGDATA
    stx DMAMODE

    ; destination address in palette ram
    stz CGADD

    #dma_ppu_data GENEVA_PALETTE
    lda #$c0
    sta CGADD
    #dma_ppu_data PLAYER_PALETTE
    #dma_ppu_data NPC_PALETTE
    ;#dma_ppu_data TEST_PALETTE

    rts