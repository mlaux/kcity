
test_map_init
.as
.xl
    ldx #DMAMODE_PPUDATA
    stx DMAMODE

    lda #$80
    sta VMAIN

    stz VMADDL
    stz VMADDH

    ldx #<>TEST_TILEMAP
    stx DMAADDR
    lda #`TEST_TILEMAP
    sta DMAADDRBANK

    ldx #size(TEST_TILEMAP)
    stx DMALEN

    lda #1
    sta MDMAEN

    ldx #<>TEST_TILESET
    stx DMAADDR
    lda #`TEST_TILESET
    sta DMAADDRBANK
    ldx #size(TEST_TILESET)
    stx DMALEN

    ; word address, not byte. 0-7fff
    ldx #$1000
    stx VMADD

    lda #1
    sta MDMAEN

    rts

; transfers 8x8 font tiles to VRAM for use with fixed-width text
; assumes: A8, XY16
font_init
.as
.xl
    ; font tiles (2bpp)
    ldx #DMAMODE_PPUDATA
    stx DMAMODE

    ldx #<>GENEVA_CHARS
    stx DMAADDR
    lda #`GENEVA_CHARS
    sta DMAADDRBANK
    ldx #size(GENEVA_CHARS)
    stx DMALEN

    ldx #$2000
    stx VMADD
    lda #$80
    sta VMAIN

    lda #1
    sta MDMAEN
    rts

blank_tile_init
.as
.xl
    ldx #$3008
    stx VMADD
    lda #$80
    sta VMAIN

    ldx #$ff00
    stx VMDATA
    stx VMDATA
    stx VMDATA
    stx VMDATA
    stx VMDATA
    stx VMDATA
    stx VMDATA
    stx VMDATA

    rts
