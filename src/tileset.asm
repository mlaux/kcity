tileset_init
.as
.xl
    ldx #DMAMODE_PPUDATA
    stx DMAMODE

    lda #$80
    sta VMAIN

    stz VMADDL
    stz VMADDH

    #dma_ppu_data TEST_TILEMAP

    ; word address, not byte. 0-7fff
    ldx #$1000
    stx VMADD

    #dma_ppu_data TEST_TILESET

    ldx #$2000
    stx VMADD

    #dma_ppu_data GENEVA_CHARS

    ldx #$4000
    stx VMADD

    #dma_ppu_data PLAYER_TILESET

    rts

blank_tile_init
.as
.xl
    ldx #$3008
    stx VMADD
    lda #$80
    sta VMAIN

    ldx #$ff00
    .rept 8
        stx VMDATA
    .endrept

    rts
