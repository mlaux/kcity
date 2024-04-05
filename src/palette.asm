palette_init
.as
.xl
    ; font palette (transparent, white, transparent, transparent)
    ldx #DMAMODE_CGDATA
    stx DMAMODE
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

    rts