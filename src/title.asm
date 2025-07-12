
state_title_init
.al
.xl
    sep #$20
    jsr enable_force_blank
    jsr background_init
    jsr load_title_tiles
    jsr init_newt_sprite
    lda #$19 ; 0x10 = 16x16 tile mode
    sta BGMODE
    sta my_bgmode
    jsr load_title_background
    jsr disable_force_blank

    rep #$20
    lda #$120
    sta my_bgvofs

    lda #EFFECT_FADE_IN
    sta effect_id
    lda #$f
    sta effect_speed
    stz effect_level

    rts

state_title
.al
.xl
    lda joypad_new
    and #(A_BUTTON | START_BUTTON)
    beq _animate

    lda my_bgvofs
    bne +

    ldy #1
    jsr run_state_init
    jmp longjmp_main

+   lda #$f
    sta effect_level
    sta my_inidisp
    stz effect_id
    stz my_bghofs
    stz my_bgvofs
    jsr hide_newt

_animate
    lda effect_id
    bne +

    lda frame_counter
    and #$3
    bne +

    lda my_bgvofs
    beq +

    dec my_bgvofs
    jsr move_newt

+   rts

state_title_vblank
.al
.xl
    sep #$20

    ; move player and send updated position to OAM
    jsr vblank_oam_dma
    rts

load_title_background
.as
.xl
    ldx #DMAMODE_PPUDATA
    stx DMAMODE

    lda #$80
    sta VMAIN

    ldx #0
    stx VMADD

    #dma_ppu_data TITLE_SCENE_TILEMAP

    ldx #$1000
    stx VMADD

    #dma_ppu_data TITLE_SCENE_TILESET


    ldx #DMAMODE_CGDATA
    stx DMAMODE

    lda #$10
    sta CGADD
    #dma_ppu_data TITLE_SCENE_PALETTE

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