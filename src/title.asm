TITLE_ANIMATION_FRAMES .word $40, $4, $10, $4, $50, $4
TITLE_ANIMATION_LENGTH = 6

TITLE_HDMA_TABLE .byte 95, 253, 1, 6, 0, 0, 10, 2, 0, 18, 253, 1, 10, 2, 0, 1, 0, 0, 0
TITLE_HDMA_SCROLL_1 = 7
TITLE_HDMA_SCROLL_2 = 10
TITLE_HDMA_SCROLL_3 = 13
TITLE_HDMA_SCROLL_4 = 16

state_title_init
.al
.xl
    sep #$20
    jsr enable_force_blank
    jsr background_init
    jsr load_title_tiles
    jsr init_newt_sprite
    lda #$39 ; 0x30 = 16x16 tile mode for BGs 1 and 2
    sta BGMODE
    sta my_bgmode
    lda #(BG2_ON | OBJ_ON)
    sta TM
    sta my_tm
    jsr load_title_background
    jsr disable_force_blank

    ldx	#0
	jsr	spcLoad
    ldx #0
    jsr spcPlay
    jsr spcFlush
-   jsr spcReadStatus
    bit #SPC_P
    beq -

    rep #$20
    lda #$120
    sta my_bg2vofs
    ; experimentally determined to match the music ending
    lda #107
    sta title_appear_delay

    lda #EFFECT_FADE_IN
    sta effect_id
    lda #$f
    sta effect_speed
    stz effect_level


    rts

state_title
.al
.xl
    lda title_animation_step
    asl
    tax
    inc title_animation_frame
    lda title_animation_frame
    cmp TITLE_ANIMATION_FRAMES, x
    bne +
    stz title_animation_frame
    inc title_animation_step
    lda title_animation_step
    cmp #TITLE_ANIMATION_LENGTH
    bne +
    stz title_animation_step

+   lda joypad_new
    and #(A_BUTTON | START_BUTTON)
    beq _animate

    lda my_bg2vofs
    bne +

    sep #$20
    jsr spcStop
    rep #$20
    ldy #1
    jsr run_state_init
    jmp longjmp_main

+   lda #$f
    sta effect_level
    sta my_inidisp
    stz effect_id
    stz my_bg2hofs
    stz my_bg2vofs
    lda #(BG1_ON | BG2_ON | OBJ_ON)
    sta my_tm
    jmp hide_newt

_animate
    lda effect_id
    bne _nothing

    lda frame_counter
    and #$3
    bne _nothing

    lda my_bg2vofs
    beq _done_scrolling

    dec my_bg2vofs
    jmp move_newt

_done_scrolling
    lda title_appear_delay
    beq _show_title_text
    dec title_appear_delay
    bra _nothing

_show_title_text
    lda #(BG1_ON | BG2_ON | OBJ_ON)
    sta my_tm

_nothing
    rts

state_title_vblank
.al
.xl
    sep #$20
    ldx #DMAMODE_CGDATA
    stx DMAMODE
    lda #$60
    sta CGADD
    lda title_animation_step
    and #1
    bne _glitch

    ldx #<>(TITLE_SCENE_TEXT_PALETTE + $40)
    stx DMAADDR
    lda #`(TITLE_SCENE_TEXT_PALETTE + $40)
    sta DMAADDRBANK
    stz title_glitch_hdma_table + TITLE_HDMA_SCROLL_1
    stz title_glitch_hdma_table + TITLE_HDMA_SCROLL_2
    stz title_glitch_hdma_table + TITLE_HDMA_SCROLL_2 + 1
    stz title_glitch_hdma_table + TITLE_HDMA_SCROLL_3
    stz title_glitch_hdma_table + TITLE_HDMA_SCROLL_4
    bra _send

_glitch
    ldx #<>(TITLE_SCENE_TEXT_PALETTE + $20)
    stx DMAADDR
    lda #`(TITLE_SCENE_TEXT_PALETTE + $20)
    sta DMAADDRBANK
    lda #2
    sta title_glitch_hdma_table + TITLE_HDMA_SCROLL_1
    lda #253
    sta title_glitch_hdma_table + TITLE_HDMA_SCROLL_2
    lda #1
    sta title_glitch_hdma_table + TITLE_HDMA_SCROLL_2 + 1
    lda #2
    sta title_glitch_hdma_table + TITLE_HDMA_SCROLL_3
    lda #4
    sta title_glitch_hdma_table + TITLE_HDMA_SCROLL_4

_send
    ldx #$20
    stx DMALEN
    lda #1
    sta MDMAEN

    lda #$2
    sta DMAP7
    lda #BG1HOFS & $ff
    sta BBAD7
    ldx #title_glitch_hdma_table
    stx A1T7L
    stz A1B7
    lda #$80
    sta HDMAEN

    jmp vblank_oam_dma

load_title_background
.as
.xl
    ldx #DMAMODE_PPUDATA
    stx DMAMODE

    lda #$80
    sta VMAIN

    ldx #0
    stx VMADD

    #dma_ppu_data TITLE_SCENE_TILEMAP_BG1
    #dma_ppu_data TITLE_SCENE_TILEMAP_BG2 ; $400

    ldx #$1000
    stx VMADD

    #dma_ppu_data TITLE_SCENE_TILESET_BG1

    ldx #$2000
    stx VMADD

    #dma_ppu_data TITLE_SCENE_TILESET_BG2

    ldx #DMAMODE_CGDATA
    stx DMAMODE

    lda #$0
    sta CGADD
    #dma_ppu_data TITLE_SCENE_PALETTE
    #dma_ppu_data TITLE_SCENE_TEXT_PALETTE

    lda #$f
    sta my_inidisp
    rts

load_title_tiles
.as
.xl
    lda #$80
    sta VMAIN

    ldx #DMAMODE_PPUDATA
    stx DMAMODE

    ldx #$4000
    stx VMADD

    #dma_ppu_data NEWT_TILESET

    ldx #DMAMODE_CGDATA
    stx DMAMODE
    lda #$c0
    sta CGADD
    #dma_ppu_data NEWT_PALETTE
    rts

NEWT_TILE_COUNT = 9
NEWT_BASE_X = 80
NEWT_BASE_Y = 176
NEWT_TILES .byte 12, 0, 2, 10, 4, 6, 8, 32, 14
NEWT_X_COORDS .byte $0, $10, $20, $30, $10, $20, $30, $10, $20
NEWT_Y_COORDS .byte $0, $0, $0, $0, $10, $10, $10, $20, $20

; TODO ~METASPRITES~ as all the cool devs say
init_newt_sprite
.as
.xl
    ; 8x8 and 16x16, base address $4000
    lda #$62
    sta OBJSEL

    lda #$20
    sta oam_data_y
    sta oam_data_x

    ldx #0
    ldy #0
-
    lda NEWT_X_COORDS, y
    clc
    adc #NEWT_BASE_X
    sta oam_data_x, x
    lda NEWT_Y_COORDS, y
    clc
    adc #NEWT_BASE_Y
    sta oam_data_y, x
    lda NEWT_TILES, y
    sta oam_data_id, x
    lda #$38
    sta oam_data_flag, x
    inx
    inx
    inx
    inx
    iny
    cpy #NEWT_TILE_COUNT
    bne -
    rts

move_newt
.al
.xl
    php
    sep #$20

    ldy #NEWT_TILE_COUNT
    ldx #0
-   lda oam_data_y, x
    cmp #$e0
    beq +
    inc oam_data_y, x
+   inx
    inx
    inx
    inx
    dey
    bne -
    plp
    rts

hide_newt
.al
.xl
    php
    sep #$20

    lda #$e0
    ldx #0
    ldy #NEWT_TILE_COUNT
-   sta oam_data_y, x
    inx
    inx
    inx
    inx
    dey
    bne -

    plp
    rts

; clears from $3000.w to $3fff.w
clear_bg3_tiles
.as
.xl
    ldx #$2000 ; in bytes
    stx DMALEN
    ldx #$3000 ; in words
    stx VMADDL
    ldx #DMAMODE_PPUFILL
    stx DMAMODE

    lda #$80
    sta VMAIN

    lda #1
    sta MDMAEN

    rts