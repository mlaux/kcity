sln .macro
    .rept \1
    asl
    .endrept
.endmacro

srn .macro
    .rept \1
    lsr
    .endrept
.endmacro

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

    jsr palette_init
    jsr tileset_init ; for font and player tiles only
    jsr background_init
    jsr copy_ram_scripts

    ; init audio
    jsl Tad_Init
    lda #$1
    jsr Tad_LoadSong

    rep #$20

    jsr player_init
    jsr vwf_reset_tiles

    ; hardcoded load of initial map. don't call map_set_warp because it'll
    ; initiate a fade-out and lock the player's position, which i don't want
    lda #2
    sta target_warp_map

    ; this will also disable force blank and set up the fade-in effect
    jsr map_run_warp

    ; initialization done, enable interrupts and auto joypad reading
    sep #$20
    lda #$81
    sta NMITIMEN

    ; fall through to main loop
main
    sep #$20
    bit SLHV
    lda OPVCT
    bit STAT78
    sta zp0

    lda #$7e
    pha
    plb
    jsl Tad_Process
    phk
    plb

    rep #$20

    jsr read_input
    jsr move_player
    jsr run_script_v2
    rep #$20
    jsr animate_npcs
    jsr vwf_frame_loop

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
+   rep #$20

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

    ; if main loop is still running, this is a lag frame, do not update ppu
    lda main_loop_done
    beq _skip_vblank

    ; move player and send updated position to OAM
    jsr vblank_oam_dma

    ; send over any new vram tiles
    jsr dma_queue_run_vblank

    ; DMA generated text tiles if needed, or reset tilemap if turning off text box
    ; send HDMA table for text box overlay if needed
    jsr text_box_vblank

    ; handle fade or mosaic effect if needed
    jsr run_effect

    ; this might go into the next frame (but it's ok because it enables force blank)
    ; but this means it needs to run last
    jsr map_run_warp

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

    rts

background_init
.as
.xl
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

    ; $3ff = -1 vertical scroll, since first line is not drawn
    lda #$ff
    sta BG1VOFS
    lda #$03
    sta BG1VOFS

    ; enable bg1+bg3+obj on main screen
    lda #$15
    sta TM

    ; enable window 1 for color
    lda #$20
    sta WOBJSEL

    ; "Sub screen color window transparent region" = "outside color window"
    lda #$10
    sta CGWSEL

    ldx #size(TEXT_HDMA_TABLE) - 1
-   lda TEXT_HDMA_TABLE, x
    sta text_box_hdma_table, x
    dex
    bpl -

    rts