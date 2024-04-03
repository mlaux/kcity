    for only writing high bytes
    lda #$80
    sta VMAIN
    stz VMADDL
    stz VMADDH

    ldx #DMAMODE_PPUHIDATA
    stx DMAMODE
    ldx #(<>TEST_CHAR) + 1
    stx DMAADDR

    ldx #TEST_CHAR_LENGTH
    stx DMALEN

    lda #1
    sta MDMAEN