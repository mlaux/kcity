dma_palette .macro
    ldx #<>\1
    stx DMAADDR
    lda #`\1
    sta DMAADDRBANK
    ldx #size(\1)
    stx DMALEN

    lda #1
    sta MDMAEN
.endmacro

FILLER_PALETTES .fill 128

palette_init
.as
.xl
    ldx #DMAMODE_CGDATA
    stx DMAMODE

    ; destination address in palette ram
    stz CGADD

    #dma_palette GENEVA_PALETTE
    #dma_palette TEST_PALETTE
    #dma_palette FILLER_PALETTES
    #dma_palette PLAYER_PALETTE

    rts