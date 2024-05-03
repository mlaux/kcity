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

check_map_warp
.as
.xl
    lda target_warp_map
    bne +
    rts

+   php
    rep #$30
    stz target_warp_map
    dec a
    asl
    tax
    lda ALL_TILEMAPS, x
    sta zp0
    sta DMAADDR

    sep #$20

    lda #$80
    sta VMAIN
    stz DMAADDRBANK

    stz VMADDL
    stz VMADDH

    ldx #DMAMODE_PPUDATA
    stx DMAMODE

    ldx #$800
    stx DMALEN

    lda #1
    sta MDMAEN

    plp
    rts