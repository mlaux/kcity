.as               ; Assume A8
.xs               ; Assume X8
.autsiz           ; Auto size detect
.databank $00     ; databank is 00
.dpage $0000      ; direct page is 0000

RESET
    clc
    xce ; enter 65816 mode
    rep #$30 ; AXY 16
    ldx #$1FFF
    txs
    phk
    plb
    lda #0000
    tcd

    lda #$008f
    sta $2100 ; turn the screen off

    lda #$8008     ; A -> B, FIXED SOURCE, WRITE BYTE | WRAM
    sta $4300
    lda #<>ZERO ; 64Tass | get low word
    sta $4302
    lda #`ZERO  ; 64Tass | get bank
    sta $4304
    stz $2181
    stz $2182      ; START AT 7E:0000
    stz $4305      ; DO 64K
    lda #$0001
    sta $420B      ; FIRE DMA
    sta $420B      ; FIRE IT AGAIN, FOR NEXT 64k

    rep #$20    ; A16
    lda #$008F  ; FORCE BLANK, SET OBSEL TO 0
    sta $2100
    stz $2105 ;6
    stz $2107 ;8
    stz $2109 ;A
    stz $210B ;C
    stz $210D ;E
    stz $210D ;E
    stz $210F ;10
    stz $210F ;10
    stz $2111 ;12
    stz $2111 ;12
    stz $2113 ;14
    stz $2113 ;14
    stz $2119 ;1A to get Mode7
    stz $211B ;1C these are write twice
    stz $211B ;1C regs
    stz $211D ;1E
    stz $211D ;1E
    stz $211F ;20
    stz $211F ;20
    stz $2123 ;24
    stz $2125 ;26
    stz $2126 ;27 YES IT DOUBLES OH WELL
    stz $2128 ;29
    stz $212A ;2B
    stz $212C ;2D
    stz $212E ;2F
    stz $2130 ;31
    lda #$00E0
    sta $2132

    ;ONTO THE CPU I/O REGS
    lda #$FF00
    sta $4200
    stz $4202 ;3
    stz $4204 ;5
    stz $4206 ;7
    stz $4208 ;9
    stz $420A ;B
    stz $420C ;D

    ; CLEAR VRAM
    rep #$20        ; A16
    lda #$1809      ; A -> B, fixed source, write word | vram
    sta $4300
    lda #<>ZERO  ; this get the low word, you will need to change if not using 64tass
    sta $4302
    lda #`ZERO   ; this gets the bank, you will need to change if not using 64tass
    sta $4304       ; and the upper byte will be 0
    stz $4305       ; do 64k
    lda #$80        ; inc on hi write
    sta $2115
    stz $2116       ; start at $$0000
    lda #$01
    sta $420B       ; fire dma
    ; CLEAR CG-RAM
    lda #$2208      ; a -> b, fixed source, write byte | cg-ram
    sta $4300
    lda #$200       ; 512 bytes
    sta $4305
    sep #$20        ; A8
    stz $2121       ; start at 0
    lda #$01
    sta $420B       ; fire dma

    ; DMA geneva mac font
    rep #$30                 ; AXY 16
    lda #<>GENEVA_CHARS
    sta $4302
    sep #$20                 ; A8
    lda #`GENEVA_CHARS
    sta $4304
    ldx #size(GENEVA_CHARS)
    stx $4305
    ldx #%00000001 | $1800   ; A->B, Inc, Write WORD, $2118
    stx $4300
    ldx #$1000
    stx $2116
    lda #$80
    sta $2115                ; inc VRAM port address
    lda #1
    sta $420B

    ; DMA Palette
    ldx #<>GENEVA_PALETTE
    stx $4302
    lda #`GENEVA_PALETTE
    sta $4304
    ldx #size(GENEVA_PALETTE)
    stx $4305
    ldx #%00000010 | $2200  ; A->B, Inc, Write 2 Bytes, $2122
    stx $4300
    stz $2121               ; start of Palette
    lda #1
    sta $420B

    ; copy test string
    ; for only writing low bytes. do this because all the text tiles are <256 and don't want to interpolate a bunch of 0s
    ; When Address increment mode is 0, the internal VRAM word address increments after writing to VMDATAL or reading from VMDATALREAD.
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
    ; lda #$80
    ; sta VMAIN
    ; stz VMADDL
    ; stz VMADDH

    ; ldx #DMAMODE_PPUHIDATA
    ; stx DMAMODE
    ; ldx #(<>TEST_CHAR) + 1
    ; stx DMAADDR

    ; ldx #TEST_CHAR_LENGTH
    ; stx DMALEN

    ; lda #1
    ; sta MDMAEN

    ; set up screen addresses
    stz $2107 ; we want the screen at $$0000 and size 32x32
    lda #1
    sta $210b ; we want BG1 tile data to be $$1000 which is the first 4K word step
    stz $2105 ; 8x8 chars and Mode 0
    lda #1
    sta $212c ; BG1 is on the Main Screen
    lda #$ff
    sta $210e ; we also need to scroll up 1 pixel ( so do -1 )
    lda #$03
    sta $210e ; because the first line is not drawn
    lda #$0f
    sta $2100 ; don't blank, so show the screen at full brightness
INF
    bra INF

NMI_ISR
   ; nothing needed yet
EMPTY_ISR
    rti

TEST_CHAR .text 'HELLO hello this is a test of the text, now need to render proportionally. what if the string is really long? '
TEST_CHAR_LENGTH = len(TEST_CHAR)

GENEVA_CHARS .binary "../font/geneva.tiles"
GENEVA_PALETTE .binary "../font/geneva.palette"

; ROM header
* = $ffb0
ZERO
    .fill 16,0
    .text "K****** walled city"
    .fill $ffd5 - *, $20 ; pad title with space
    .byte $20   ; Mapping
    .byte $00   ; Rom
    .byte $07   ; 128K
    .byte $00   ; 0 SRAM
    .byte $00   ; NTSC-J
    .byte $33   ; Version 3
    .byte $00   ; rom version 0
    .word $FFFF ; complement
    .word $0000 ; CRC

; 65816 vectors
* = $ffe4
v16_COP    .word EMPTY_ISR
v16_BRK    .word EMPTY_ISR
v16_ABORT  .word EMPTY_ISR
v16_NMI    .word NMI_ISR
v16_RESET  .word EMPTY_ISR
v16_IRQ    .word EMPTY_ISR

; 6502 vectors
* = $fff4
v02_COP    .word EMPTY_ISR
v02_BRK    .word EMPTY_ISR
v02_ABORT  .word EMPTY_ISR
v02_NMI    .word EMPTY_ISR
v02_RESET  .word RESET
v02_IRQ    .word EMPTY_ISR