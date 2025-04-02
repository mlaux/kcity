
TITLE_SCENE_TILESET .binary "../gfx/title/title.4bp"
TITLE_SCENE_TILEMAP .binary "../gfx/title/title.map"

state_title_init
.al
.xl
    sep #$20
    jsr background_init
    lda #$19 ; 0x10 = 16x16 tile mode
    sta BGMODE
    jsr load_title_background
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
    beq +

    stz effect_id
    lda #$f
    sta my_inidisp
    stz my_bghofs
    stz my_bgvofs

+   lda effect_id
    bne +

    lda frame_counter
    and #$3
    bne +

    lda my_bgvofs
    beq +

    dec my_bgvofs

+   lda #1
    sta main_loop_done
-   wai
    lda main_loop_done
    bne -
    rts

state_title_vblank
.al
.xl
    sep #$20
    lda my_bghofs
    sta BG1HOFS
    lda my_bghofs + 1
    sta BG1HOFS
    lda my_bgvofs
    sta BG1VOFS
    lda my_bgvofs + 1
    sta BG1VOFS

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