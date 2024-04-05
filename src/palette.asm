palette_init
.as
.xl
    ldx #DMAMODE_CGDATA
    stx DMAMODE

    ; font palette (transparent, white, transparent, transparent)
    ldx #<>GENEVA_PALETTE
    stx DMAADDR
    lda #`GENEVA_PALETTE
    sta DMAADDRBANK
    ldx #size(GENEVA_PALETTE)
    stx DMALEN

    ; destination address in palette ram
    stz CGADD

    lda #1
    sta MDMAEN

    ; test tilemap palette
    ldx #<>TEST_PALETTE
    stx DMAADDR
    lda #`TEST_PALETTE
    sta DMAADDRBANK
    ldx #size(TEST_PALETTE)
    stx DMALEN

    lda #1
    sta MDMAEN

    rts