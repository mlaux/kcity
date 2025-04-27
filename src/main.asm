RESET
    ; enter 65816 mode
    sei
    clc
    xce
    cld

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
    jsr clear_oam

    ; init audio
    jsr BootSPC
    jsr SPX_Transfer_LFT

    ; initialization done, enable interrupts and auto joypad reading
    lda #$81
    sta NMITIMEN

    lda #0
    sta game_state
    jsr run_state_init

    ; fall through to main loop
main_loop
    bit SLHV
    lda OPVCT
    bit STAT78
    sta zp0

    jsr SPX_Routine

    rep #$20

    jsr read_input

    lda game_state
    asl
    tax
    jsr (STATES, x)

    ; measure CPU time in scanlines
    sep #$20
    bit SLHV
    lda OPVCT
    bit STAT78
    sec
    sbc zp0
    sta zp0

    ; update CPU high water mark
    cmp zp1
    bcc +
    sta zp1

+   lda #1
    sta main_loop_done
-   wai
    lda main_loop_done
    bne -

    jmp main_loop

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

    rep #$20

    ; if main loop is still running, this is a lag frame, do not update ppu
    lda main_loop_done
    beq _skip_vblank

    ; run any state-specific vblank things
    lda game_state
    asl
    tax
    jsr (VBLANKS, x)

    sep #$20

    ; handle fade or mosaic effect if needed
    jsr run_effect
    sep #$20
    lda my_inidisp
    sta INIDISP
    lda my_mosaic
    sta MOSAIC
    lda my_bgmode
    sta BGMODE
    
    lda my_bghofs
    sta BG1HOFS
    lda my_bghofs + 1
    sta BG1HOFS
    lda my_bgvofs
    sta BG1VOFS
    lda my_bgvofs + 1
    sta BG1VOFS


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

    lda #$e0
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

clear_oam
.as
.xl
    lda #$0
    ldx #$0
    stx OAMADD

    ldx #$7f
-   sta OAMDATA
    lda #224
    sta OAMDATA
    lda #0
    sta OAMDATA
    sta OAMDATA
    dex
    bpl -

    ldx #$100
    stx OAMADD
    ldx #$1f
-   sta OAMDATA
    dex
    bpl -

    lda #224
    ldx #(2 * NUM_OAM_ENTRIES) - 1
-   sta sprites_y, x
    stz sprites_x, x
    stz sprites_id, x
    stz sprites_flag, x
    dex
    bpl -

    rts
