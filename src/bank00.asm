.as
.xl
.autsiz
.databank $00
.dpage $0000

; input: x = address of string
; assumes: AXY 16
draw_string_vwf
.al
.xl
    stx vwf_src
    ldx #vwf_tiles
    stx vwf_dst

    ; vwf_src points to the currently processed char.
    ; vwf_dst points to the first byte of the current tile.
_each_char
    rep #$20

    ldx vwf_src
    lda 0, x
    and #$ff
    cmp #$ff
    beq _exit
    sta vwf_ch

    ; look up tile in font
    ; y = GENEVA_CHARS + (16 * vwf_ch) + 15
    ; sec
    ; sbc #' '
    asl
    asl
    asl
    asl
    clc
    adc #GENEVA_CHARS
    adc #$f
    tax

    ldy #15
_each_byte
    sep #$20
    ; for each byte in the current destination tile
    lda (vwf_dst), y
    sta vwf_row

    ; loads equivalent byte from font for this char
    lda 0, x
    phx
    phy
    sep #$10

    ldy vwf_offs
-   beq _done_shifting
    lsr
    dey
    bra -

_done_shifting
    rep #$10
    ply
    plx

    ora vwf_row
    sta (vwf_dst), y

    dex
    dey
    bpl _each_byte

    ; vwf_offs = (vwf_offs + CHAR_WIDTHS[vwf_ch]) % 8;
    ldx vwf_ch
    lda CHAR_WIDTHS, x
    ;and #$ff
    clc
    adc vwf_offs
    sta vwf_offs
    cmp #8
    bmi _no_tile_increment
    sec
    sbc #8
    sta vwf_offs

    rep #$20
    lda vwf_dst
    clc
    adc #$10
    sta vwf_dst

_no_tile_increment
    ; successfully completed this char without overflowing the tile
    ; onto the next char
    inc vwf_src
    bra _each_char
_exit
    rts

RESET
    ; enter 65816 mode
    sei
    clc
    xce

    ; AXY 16
.al
.xl
    rep #$30

    ; set up stack, set data bank = program bank
    ldx #$1fff
    txs
    phk
    plb

    ; direct page = zero page
    lda #0000
    tcd

    ; turn the screen off
    lda #$008f
    sta INIDISP

    stz OAMADDL
    stz BGMODE ; MOSAIC
    stz BG1SC ; BG2SC
    stz BG3SC ; BG4SC
    stz BG12NBA

    stz BG1HOFS
    stz BG1HOFS

    stz BG2HOFS
    stz BG2HOFS

    stz BG3HOFS
    stz BG3HOFS

    stz BG4HOFS
    stz BG4HOFS

    stz W12SEL
    stz WOBJSEL
    stz WH0
    stz WH2
    stz WBGLOG ;2B
    stz TM ;2D
    stz TMW ;2F
    stz CGWSEL

    lda #$00e0
    sta COLDATA

    ; NMITIMEN = 0, WRIO = $ff
    lda #$ff00
    sta NMITIMEN

    stz WRMPYA ; WRMPYB
    stz WRDIVL ; WRDIVH
    stz WRDIVB ; HTIMEL
    stz HTIMEH ; VTIMEL
    stz VTIMEH ; MDMAEN
    stz HDMAEN ; MEMSEL

    ; a8
    sep #$20

    ; clear WRAM
    ldx #DMAMODE_RAMFILL
    stx DMAMODE

    ldx #<>ZERO
    stx DMAADDR
    lda #`ZERO
    sta DMAADDRBANK

    stz WMADDL
    stz WMADDM
    stz WMADDH
    stz DMALEN ; 0 length = 64k
    stz DMALENHI

    ; 2x 64k
    lda #1
    sta MDMAEN
    sta MDMAEN

    ; clear VRAM
    ldx #DMAMODE_PPUFILL
    stx DMAMODE

    stz DMALEN
    stz DMALENHI

    lda #$80
    sta VMAIN

    stz VMADDL
    stz VMADDH

    lda #1
    sta MDMAEN

    ; clear CGRAM
    ldx #DMAMODE_CGFILL
    stx DMAMODE
    ldx #$200
    stx DMALEN
    stz CGADD       ; start at 0

    lda #1
    sta MDMAEN       ; fire dma

    ; DMA geneva mac font
    ldx #DMAMODE_PPUDATA
    stx DMAMODE

    ldx #<>GENEVA_CHARS
    stx DMAADDR
    lda #`GENEVA_CHARS
    sta DMAADDRBANK
    ldx #size(GENEVA_CHARS)
    stx DMALEN

    ; word address, not byte. 0-7fff
    ldx #$1000
    stx VMADD
    lda #$80
    sta VMAIN

    lda #1
    sta MDMAEN

    ; DMA Palette
    ldx #DMAMODE_CGDATA
    stx DMAMODE
    ldx #<>GENEVA_PALETTE
    stx DMAADDR
    lda #`GENEVA_PALETTE
    sta DMAADDRBANK
    ldx #size(GENEVA_PALETTE)
    stx DMALEN

    ; palette ram dest address
    stz $2121

    lda #1
    sta MDMAEN

    ; copy test string
    ; for only writing low bytes. do this because all the text tiles are <256 and don't want to interpolate a bunch of
    ; 0s. 
    ; "when Address increment mode is 0, the internal VRAM word address increments after writing to VMDATAL or reading
    ; from VMDATALREAD."
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

    rep #$30

    ldx #TEST_CHAR
    ldy #$1800
    jsr draw_string_vwf

    sep #$20

    ; set up screen addresses
    stz BG1SC ; we want the screen at $$0000 and size 32x32
    lda #1
    sta BG12NBA ; we want BG1 tile data to be $$1000 which is the first 4K word step
    stz BGMODE ; 8x8 chars and Mode 0

    ; enable bg1 on main screen
    lda #1
    sta TM

    ; $3ff = -1 vertical scroll
    ; first line is not drawn
    lda #$ff
    sta BG1VOFS
    lda #$03
    sta BG1VOFS

    ; disable force blank, full brightness
    lda #$0f
    sta INIDISP
INF
    bra INF

NMI_ISR
   ; nothing needed yet
EMPTY_ISR
    rti

TEST_CHAR .text 'test of a longer string', 255
TEST_CHAR_LENGTH = len(TEST_CHAR)

GENEVA_CHARS .binary "../font/geneva.tiles"
GENEVA_1BPP .binary "../font/geneva1.tiles"
GENEVA_PALETTE .binary "../font/geneva.palette"
CHAR_WIDTHS .binary "../font/charwidths.bin"

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