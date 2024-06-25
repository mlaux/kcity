palette_init
.as
.xl
    ldx #DMAMODE_CGDATA
    stx DMAMODE

    ; destination address in palette ram
    stz CGADD

    #dma_ppu_data GENEVA_PALETTE
    #dma_ppu_data TEST_PALETTE
    #dma_ppu_data FILLER_PALETTES
    #dma_ppu_data PLAYER_PALETTE
    #dma_ppu_data NPC_PALETTE

    rts