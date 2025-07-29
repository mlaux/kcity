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

    jsr vwf_reset_tiles

    ; initialize font type to 8x8 (default)
    lda #FONT_TYPE_8X16
    jsr vwf_set_font_type

    ; initialization done, enable interrupts and auto joypad reading
    lda #$81
    sta NMITIMEN

    lda #1
    sta current_map_id

    ldy #0
    jsr run_state_init

    ; fall through to main loop
main_loop
    ; set H/V counter latch to lock in vertical counter
    bit SLHV
    ; load the actual vertical counter
    lda OPVCT
    sta vertical_counter
    lda OPVCT
    and #1
    sta vertical_counter + 1
    ; reading this will reset the counter latch for next time
    bit STAT78

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
    sta vertical_counter_end
    lda OPVCT
    and #1
    sta vertical_counter_end + 1
    bit STAT78

    rep #$20
    lda vertical_counter_end
    sec
    sbc vertical_counter
    sta vertical_counter_this_frame
    sep #$20

    ; update CPU high water mark
    ; cmp zp1
    ; bcc +
    ; sta zp1

    ; signal that the NMI is good to go and busy wait
    lda #1
    sta update_ppu
-   lda update_ppu
    bne -
    ; once update_ppu is cleared it means that the NMI routine has run

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

    ; current conditions where this will be 0:
    ;   - main loop is still running
    ;   - explicitly disabled for things like uploading to VRAM
    lda update_ppu
    beq _skip_vblank

    ; do not run state specific vblank if transitioning between states
    lda state_transitioning
    bne +

    ; run any state-specific vblank things. "api contract" (lol) is that all
    ; registers will be long upon entry and the vblank routine can do whatever
    ; it wants with them
    rep #$30
    php
    lda game_state
    asl
    tax
    jsr (VBLANKS, x)
    plp

    ; handle fade or mosaic effect if needed. this is so during transitions, 
    ; states can just busy wait for the effects to be done
+   jsr run_effect
    ; run_effect can end with either a16 or a8, nice
    sep #$20

    ;transfer over ppu registers

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

    lda my_bg2hofs
    sta BG2HOFS
    lda my_bg2hofs + 1
    sta BG2HOFS
    lda my_bg2vofs
    sta BG2VOFS
    lda my_bg2vofs + 1
    sta BG2VOFS

    lda my_bg3hofs
    sta BG3HOFS
    lda my_bg3hofs + 1
    sta BG3HOFS
    lda my_bg3vofs
    sta BG3VOFS
    lda my_bg3vofs + 1
    sta BG3VOFS

    lda my_tm
    sta TM

    jsr draw_cpu_usage

    inc frame_counter

    ; reset flag so main loop can continue
    stz update_ppu

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
    sta COLDATA ; SETINI
    ;lda #$4
    ;sta SETINI

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
    ldx #OAM_MAIN_LENGTH - 4
-   sta oam_data_y, x
    stz oam_data_x, x
    stz oam_data_id, x
    stz oam_data_flag, x
    dex
    dex
    dex
    dex
    bpl -

    rts
