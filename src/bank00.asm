.as
.xl
.autsiz
.databank $00
.dpage $0000

.include "vwf.asm"

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
    lda #0
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

    rep #$30
    jsr vwf_reset
    lda #TEST_CHAR
    sta vwf_src

    sep #$20
    lda #$81
    sta NMITIMEN

main
    rep #$20
    lda #2
    sta vwf_count
    jsr vwf_draw_string

    lda #1
    sta main_loop_done
-   wai
    lda main_loop_done
    bne -
    jmp main

NMI_ISR
.al
.xl
    rep #$30
    pha
    phx
    phy
    phb
    phd
    phk
    plb
    lda #0
    tcd

    ; long index, short a
    sep #$20
    bit RDNMI

    ; if main loop is still running, this is a lag frame, leave immediately
    lda main_loop_done
    beq _skip_vblank

    ; DMA generated text tiles if needed
    ldy vwf_dmalen
    beq _no_font_dma

    jsr vwf_dma_tiles

    ; ; and update tilemap
    ; lda #$80
    ; sta VMAIN

    ; ldx #$0080
    ; stx VMADD

    ; ldx #DMAMODE_PPUDATA
    ; stx DMAMODE

    ; w/e need to set up properly
    ; ldx #<>ZERO
    ; stx DMAADDR
    ; lda #`ZERO
    ; sta DMAADDRBANK

    ; ldx #TEST_CHAR_LENGTH
    ; stx DMALEN

    ; lda #1
    ; sta MDMAEN

_no_font_dma
    ; reset flag so main loop can continue
    stz main_loop_done

_skip_vblank
    rep #$30
    pld
    plb
    ply
    plx
    pla

EMPTY_ISR
    rti

TEST_CHAR .text "'Numbers in Science' ... isn't there ANYTHING a little less practical I can read?", 255
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