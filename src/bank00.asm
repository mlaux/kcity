.as
.xl
.autsiz
.databank $00
.dpage $0000

.include "text.asm"
.include "tileset.asm"
.include "palette.asm"
.include "effect.asm"
TEXT_COUNT = 1

RESET
    ; enter 65816 mode
    sei
    clc
    xce

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

    ; clear all SNES-specific CPU and PPU registers
    jsr clear_registers

    sep #$20

    ; clear WRAM, can't be a procedure because it's gonna erase the stack lol
    ldx #DMAMODE_RAMFILL
    stx DMAMODE

    ldx #<>ZERO
    stx DMAADDR
    lda #`ZERO
    sta DMAADDRBANK

    stz WMADDL
    stz WMADDM
    stz WMADDH

    ; 0 length actually means 64k
    stz DMALEN
    stz DMALENHI

    ; channel 0, 2x 64k
    lda #1
    sta MDMAEN
    sta MDMAEN

    jsr clear_ppu_ram

    ; DMA geneva mac font and palette
    jsr font_init
    jsr blank_tile_init
    jsr palette_init
    jsr test_map_init

    ; set up screen addresses
    stz BG1SC ; we want the screen at $0000 and size 32x32
    lda #%00001000 ; layer 3 at $0800.w and size 32x32
    sta BG3SC
    lda #1
    sta BG12NBA ; we want BG1 tile data to be $1000 which is the first 4K word step
    lda #3
    sta BG34NBA ; BG3 tile data at $3000
    lda #$9
    sta BGMODE ; 8x8 chars mode 1, BG3 priority

    ; enable bg1 on main screen, bg3 on subscreen
    lda #$1
    sta TM
    lda #$4
    sta TS
    lda #$2
    sta CGWSEL

    ; $3ff = -1 vertical scroll, since first line is not drawn
    lda #$ff
    sta BG1VOFS
    lda #$03
    sta BG1VOFS

    lda #$45
    sta CGADSUB

    ldx #$aa1
    lda #$1e
    jsr transparent_horiz_line
    ldx #$ac1
    lda #$1e
    jsr transparent_horiz_line
    ldx #$ae1
    lda #$1e
    jsr transparent_horiz_line
    ldx #$b01
    lda #$1e
    jsr transparent_horiz_line
    ldx #$b21
    lda #$1e
    jsr transparent_horiz_line
    ldx #$b41
    lda #$1e
    jsr transparent_horiz_line

    ; disable force blank, brightness still 0
    lda #$0
    sta INIDISP

    rep #$20

    jsr vwf_reset_tiles

    lda #EFFECT_FADE_IN
    sta effect_id
    lda #$f
    sta effect_speed

    ; initialization done, enable interrupts and auto joypad reading
    sep #$20
    lda #$81
    sta NMITIMEN
    ; fall through to main loop

main
    rep #$20

    lda current_text
    bne +

    lda text_index
    cmp #TEXT_COUNT
    beq +

    asl
    tax
    lda TEXT_LINES, x
    sta current_text
    inc text_index

+   jsr update_text

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

    sep #$20
    bit RDNMI

    ; if main loop is still running, this is a lag frame, leave immediately
    lda main_loop_done
    beq _skip_vblank

    ; DMA generated text tiles if needed
    ldy vwf_dmalen
    beq _no_font_dma

    jsr vwf_dma_tiles
    jsr vwf_transfer_map
    stz vwf_dmalen

_no_font_dma

    jsr run_effect
    inc frame_counter

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

clear_registers
.al
.xl
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
    rts

clear_ppu_ram
.as
.xl
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
    rts

update_text
.al
.xl
    ; string currently being drawn?
    lda vwf_end_of_string
    bne _no

    ; yes, keep going with current string
_yes
    lda #1
    sta vwf_count
    jmp vwf_draw_string

    ; no, anything to draw?
_no
    ldx current_text
    bne _draw_next_string
    rts

    ; yes, start it
_draw_next_string
    ldy #DIALOG_BOX_BASE
    jsr vwf_init_string
    bra _yes

TEST_CHAR .text "Upper Lowercase - bdijgpqy.  [symbols] although,", 255
TEST_CHAR2 .text "line two", 255
TEXT_LINES .word TEST_CHAR

GENEVA_CHARS .binary "../font/geneva.tiles"
GENEVA_PALETTE .binary "../font/geneva.palette"
CHAR_WIDTHS .binary "../font/charwidths.bin"

TEST_PALETTE .binary "../experimental_gfx/maptest.palette"
TEST_TILESET .binary "../experimental_gfx/maptest.tiles"
TEST_TILEMAP .binary "../experimental_gfx/maptest.map"

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