    
    ; copy test string
    for only writing low bytes. do this because all the text tiles are <256 and don't want to interpolate a bunch of
    0s. 
    "when Address increment mode is 0, the internal VRAM word address increments after writing to VMDATAL or reading
    from VMDATALREAD."
    stz VMAIN

    stz VMADDL
    stz VMADDH

    ldx #DMAMODE_PPULODATA
    stx DMAMODE

    ldx #<>TEST_CHAR
    stx DMAADDR
    lda #`TEST_CHAR
    sta DMAADDRBANK

    ldx #TEST_CHAR_LENGTH
    stx DMALEN

    lda #1
    sta MDMAEN

    
    ; for only writing high bytes
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