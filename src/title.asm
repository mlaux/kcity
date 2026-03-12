; this is a mess
; 1. load BG1 with SOLID STATE and BG2 with title scene artwork
; 2. set up newt which is a sprite instead of BG so we can easily animate later
; 3. turn on BG2 and sprites, start music, fade in entire screen
; 4. scroll from (0, 288) to (0, -1)
; 5. wait for music to almost end
; 6. turn on BG1 to show SOLID STATE and fade it in
; 7. occasionally palette swap "STATE" and move it with hdma
; press A/start once: skip to 0 scroll and SOLID STATE at full brightness
; press A/start again: start game

TITLE_ANIMATION_FRAMES .word $40, $4, $10, $4, $50, $4
TITLE_ANIMATION_LENGTH = 6

TITLE_HDMA_TABLE .byte 95, 0, 0, 6, 253, 1, 10, 2, 0, 18, 253, 1, 10, 2, 0, 1, 0, 0, 0
TITLE_HDMA_SCROLL_1 = 7
TITLE_HDMA_SCROLL_2 = 10
TITLE_HDMA_SCROLL_3 = 13
TITLE_HDMA_SCROLL_4 = 16

; mode 1, 16x16 tile mode for BGs 1 and 2
TITLE_BGMODE = $31
; 8x8 and 16x16, base address $6000.w
TITLE_OBJSEL = $63
TITLE_INITIAL_SCROLL_Y = $120
; frames to wait before showing STATE text
TITLE_APPEAR_STARTING_DELAY = 107       
; frames per brightness level
TITLE_FADE_FRAMES = $10     
; CGRAM address for palettes, not contiguous bc of how the tiles are in crane
; ($50 is free to be used)
TITLE_SOLID_CGRAM_ADDR = $40
TITLE_STATE_CGRAM_ADDR = $60
; scroll every 4 frames
TITLE_SCROLL_SPEED_MASK = $3 
TITLE_SPRITE_HIDDEN_Y = $e0

PALETTE_SIZE = $20 ; 16 colors * 2 bytes/color

state_title_init
.al
.xl
    sep #$20
    jsr enable_force_blank
    jsr background_init
    jsr load_title_background
    jsr load_newt_tiles
    jsr init_newt_sprite
    lda #TITLE_BGMODE
    sta BGMODE
    sta my_bgmode
    lda #(BG2_ON | OBJ_ON)
    sta TM
    sta my_tm
    jsr disable_force_blank

    ldx	#0
	jsr	spcLoad
    ldx #0
    jsr spcPlay
    jsr spcFlush
    ; wait for music to start.
    ; why is this so delayed sometimes and almost immediate other times?
-   jsr spcReadStatus
    bit #SPC_P
    beq -

    rep #$20
    lda #TITLE_INITIAL_SCROLL_Y
    sta my_bg2vofs
    ; experimentally determined to match the music ending
    lda #TITLE_APPEAR_STARTING_DELAY
    sta title_appear_delay

    ; these files contain 9 palettes, 8/8 -> 0/8 brightness
    ; start at black
    lda #(8 * 2 * 16 + <>TITLE_SCENE_SOLID_PALETTES)
    sta title_solid_palette
    lda #(8 * 2 * 16 + <>TITLE_SCENE_STATE_PALETTES)
    sta title_state_palette
    ; frames per brightness level
    lda #TITLE_FADE_FRAMES
    sta title_palette_fade_frame

    lda #EFFECT_FADE_IN
    sta effect_id
    lda #$f
    sta effect_speed
    stz effect_level
    stz title_tile_anim_frame
    stz title_tile_anim_step
    lda #FISH_ANIMATION_START_DELAY
    sta title_tile_anim_delay

    rts

state_title
.al
.xl
    lda title_animation_step
    asl
    tax
    inc title_animation_frame
    lda title_animation_frame
    cmp TITLE_ANIMATION_FRAMES,x
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

    lda my_tm
    and #BG1_ON
    beq _full_title

    sep #$20
    jsr spcStop
    rep #$20
    jsr save_exists
    cmp #1
    beq _load
    jmp go_to_opening

_load
    ldy #STATE_ID_FILE_SELECT
    jsr run_state_init
    jmp longjmp_main

_full_title
    lda #$f
    sta effect_level
    sta my_inidisp
    stz effect_id
    lda #-1
    sta my_bg2vofs
    ; skip to full brightness
    lda #<>TITLE_SCENE_SOLID_PALETTES
    sta title_solid_palette
    lda #<>TITLE_SCENE_STATE_PALETTES
    sta title_state_palette
    lda #(BG1_ON | BG2_ON | OBJ_ON)
    sta my_tm
    jmp hide_newt

_animate
    lda frame_counter
    and #$f
    bne +
    jsr animate_snail

+   lda effect_id
    bne _nothing

    lda frame_counter
    pha
    and #TITLE_SCROLL_SPEED_MASK
    bne +
    jsr _scroll
+   pla
    and #1
    bne _nothing
    jmp animate_dragonfly

_nothing
    rts

_scroll
    lda my_bg2vofs
    bmi _done_scrolling

    dec my_bg2vofs
    jmp move_creatures

_done_scrolling
    lda title_appear_delay
    beq _show_title_text
    dec title_appear_delay
    rts

_show_title_text
    lda #(BG1_ON | BG2_ON | OBJ_ON)
    sta my_tm
    rts

state_title_vblank
.al
.xl
    jsr animate_fish
    ; if title text isn't showing yet, return
    lda my_tm
    and #BG1_ON
    sep #$20
    bne +
    jmp vblank_oam_dma

+   ldx #DMAMODE_CGDATA
    stx DMAMODE
    lda #TITLE_STATE_CGRAM_ADDR
    sta CGADD
    lda title_animation_step
    ; odd steps in the animation show palette 2 for glitch effect
    and #1
    beq _regular
_check_glitch
    rep #$20
    lda title_state_palette
    cmp #<>TITLE_SCENE_STATE_PALETTES
    sep #$20
    beq _glitch

_regular
    ldx title_state_palette
    stx DMAADDR
    lda #`TITLE_SCENE_STATE_PALETTES
    sta DMAADDRBANK

    ; because STATE is too far to the left in the graphics lol
    lda #253
    sta title_glitch_hdma_table + TITLE_HDMA_SCROLL_1
    sta title_glitch_hdma_table + TITLE_HDMA_SCROLL_2
    sta title_glitch_hdma_table + TITLE_HDMA_SCROLL_3
    sta title_glitch_hdma_table + TITLE_HDMA_SCROLL_4
    lda #$1
    sta title_glitch_hdma_table + TITLE_HDMA_SCROLL_1 + 1
    sta title_glitch_hdma_table + TITLE_HDMA_SCROLL_2 + 1
    sta title_glitch_hdma_table + TITLE_HDMA_SCROLL_3 + 1
    sta title_glitch_hdma_table + TITLE_HDMA_SCROLL_4 + 1
    bra _send

_glitch
    ldx #<>TITLE_SCENE_GLITCH_PALETTE
    stx DMAADDR
    lda #`TITLE_SCENE_GLITCH_PALETTE
    sta DMAADDRBANK

    ; is it unrolled loops or is it just bad coding
    lda #2
    sta title_glitch_hdma_table + TITLE_HDMA_SCROLL_1
    lda #0
    sta title_glitch_hdma_table + TITLE_HDMA_SCROLL_1 + 1
    lda #253
    sta title_glitch_hdma_table + TITLE_HDMA_SCROLL_2
    lda #1
    sta title_glitch_hdma_table + TITLE_HDMA_SCROLL_2 + 1
    lda #2
    sta title_glitch_hdma_table + TITLE_HDMA_SCROLL_3
    lda #0
    sta title_glitch_hdma_table + TITLE_HDMA_SCROLL_3 + 1
    lda #4
    sta title_glitch_hdma_table + TITLE_HDMA_SCROLL_4
    lda #0
    sta title_glitch_hdma_table + TITLE_HDMA_SCROLL_4 + 1

_send
    ldx #PALETTE_SIZE
    stx DMALEN
    lda #1
    sta MDMAEN

    ; SOLID fades in too
    ldx title_solid_palette
    stx DMAADDR
    ldx #PALETTE_SIZE
    stx DMALEN
    lda #TITLE_SOLID_CGRAM_ADDR
    sta CGADD
    lda #1
    sta MDMAEN

    ; twinkles stars all at once... 
;     lda #$0d
;     sta CGADD
;     lda frame_counter
;     and #63
;     cmp #8
;     bcs +
;     lda #$ff
;     sta CGDATA
;     lda #$2a
;     sta CGDATA
;     bra _do_hdma

; +   lda #$bf
;     sta CGDATA
;     lda #$2b
;     sta CGDATA

_do_hdma
    lda #$2
    sta DMAP7
    lda #BG1HOFS & $ff
    sta BBAD7
    ldx #<>title_glitch_hdma_table
    stx A1T7L
    stz A1B7
    lda #$80
    sta HDMAEN

    ; subtract $20 from each palette address to move up one brightness level
    rep #$20
    lda title_solid_palette
    ; if it's the base address it is fully faded in
    cmp #<>TITLE_SCENE_SOLID_PALETTES
    beq _end
    dec title_palette_fade_frame
    lda title_palette_fade_frame
    bne _end
    lda title_solid_palette
    sec
    sbc #PALETTE_SIZE
    sta title_solid_palette
    lda title_state_palette
    sec
    sbc #PALETTE_SIZE
    sta title_state_palette
    lda #TITLE_FADE_FRAMES
    sta title_palette_fade_frame

_end
    sep #$20
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
    #dma_ppu_data CRITTERS_TILESET

    ldx #DMAMODE_CGDATA
    stx DMAMODE

    lda #$0
    sta CGADD
    #dma_ppu_data TITLE_SCENE_PALETTE

    rts

load_newt_tiles
.as
.xl
    lda #$80
    sta VMAIN

    ldx #DMAMODE_PPUDATA
    stx DMAMODE

    ldx #$6000
    stx VMADD

    #dma_ppu_data NEWT_TILESET
    #dma_ppu_data CRITTERS_TILESET

    ldx #DMAMODE_CGDATA
    stx DMAMODE
    lda #$c0
    sta CGADD
    #dma_ppu_data NEWT_PALETTE
    #dma_ppu_data CRITTERS_PALETTE
    rts

NEWT_TILE_COUNT = 9
NEWT_BASE_X = 80
NEWT_BASE_Y = 176
NEWT_OAM_ATTRIBUTES = $38
NEWT_TILES .byte 12, 0, 2, 10, 4, 6, 8, 32, 14
NEWT_X_COORDS .byte $0, $10, $20, $30, $10, $20, $30, $10, $20
NEWT_Y_COORDS .byte $0, $0, $0, $0, $10, $10, $10, $20, $20

SNAIL_OAM_INDEX = 9
SNAIL_FRAMES .byte 78, 96
SNAIL_OAM_ATTRIBUTES = $3a
DRAGONFLY_OAM_INDEX = 10
DRAGONFLY_FRAMES .byte 74, 76
DRAGONFLY_OAM_ATTRIBUTES = $3a

; TODO ~METASPRITES~ as all the cool devs say
init_newt_sprite
.as
.xl
    ; 8x8 and 16x16, base address $4000
    lda #TITLE_OBJSEL
    sta OBJSEL

    stz oam_data_x + (4*SNAIL_OAM_INDEX)
    lda #144
    sta oam_data_y + (4*SNAIL_OAM_INDEX)
    lda #SNAIL_OAM_ATTRIBUTES
    sta oam_data_flag + (4*SNAIL_OAM_INDEX)
    lda SNAIL_FRAMES
    sta oam_data_id + (4*SNAIL_OAM_INDEX)

    lda #$ff
    sta oam_data_x + (4*DRAGONFLY_OAM_INDEX)
    lda #$60
    sta title_dragonfly_y_base
    sta oam_data_y + (4*DRAGONFLY_OAM_INDEX)
    lda #DRAGONFLY_OAM_ATTRIBUTES
    sta oam_data_flag + (4*DRAGONFLY_OAM_INDEX)
    lda DRAGONFLY_FRAMES
    sta oam_data_id + (4*DRAGONFLY_OAM_INDEX)

    ldx #0
    ldy #0
-
    lda NEWT_X_COORDS,y
    clc
    adc #NEWT_BASE_X
    sta oam_data_x,x
    lda NEWT_Y_COORDS,y
    clc
    adc #NEWT_BASE_Y
    sta oam_data_y,x
    lda NEWT_TILES,y
    sta oam_data_id,x
    lda #NEWT_OAM_ATTRIBUTES
    sta oam_data_flag,x
    inx
    inx
    inx
    inx
    iny
    cpy #NEWT_TILE_COUNT
    bne -
    rts

move_creatures
.al
.xl
    php
    sep #$20

    lda oam_data_x + (4*DRAGONFLY_OAM_INDEX)
    cmp #2
    bcc _no_dragonfly

    dec oam_data_x + (4*DRAGONFLY_OAM_INDEX)
    ; dec oam_data_x + (4*DRAGONFLY_OAM_INDEX)
    ldx title_dragonfly_y_lookup
    lda SINE_TABLE,x
    ; asr 3
    cmp #$80
    ror
    cmp #$80
    ror
    cmp #$80
    ror
    clc
    adc title_dragonfly_y_base
    sta oam_data_y + (4*DRAGONFLY_OAM_INDEX)
    inc title_dragonfly_y_lookup
    inc title_dragonfly_y_lookup
    inc title_dragonfly_y_lookup
    inc title_dragonfly_y_lookup
    inc title_dragonfly_y_lookup
    ; commented so it moves up relative to scroll
    ; dec title_dragonfly_y_base
    bra _scroll_newt

_no_dragonfly
    lda #$e0
    sta oam_data_y + (4*DRAGONFLY_OAM_INDEX)
_scroll_newt
    ; scroll at the same speed as the background so visual placement is the same
    ; +1 for snail
    ldy #NEWT_TILE_COUNT + 1
    ldx #0
-   lda oam_data_y,x
    cmp #TITLE_SPRITE_HIDDEN_Y
    beq +
    inc oam_data_y,x
+   inx
    inx
    inx
    inx
    dey
    bne -
    plp
    rts

animate_dragonfly
.al
.xl
    lda title_dragonfly_frame
    eor #1
    sta title_dragonfly_frame
    tax
    lda DRAGONFLY_FRAMES,x
    sep #$20
    sta oam_data_id + (4*DRAGONFLY_OAM_INDEX)
    rep #$20
    rts

animate_snail
.al
.xl
    inc oam_data_x + (4*SNAIL_OAM_INDEX)
    lda title_snail_frame
    eor #1
    sta title_snail_frame
    tax
    lda SNAIL_FRAMES,x
    sep #$20
    sta oam_data_id + (4*SNAIL_OAM_INDEX)
    rep #$20
    rts

hide_newt
.al
.xl
    php
    sep #$20

    lda #TITLE_SPRITE_HIDDEN_Y
    ldx #0
    ; +2 for snail and dragonfly
    ldy #NEWT_TILE_COUNT + 2
-   sta oam_data_y,x
    inx
    inx
    inx
    inx
    dey
    bne -

    plp
    rts

FISH_ANIMATION_VALUES .word $1086, $1300, $1302, $1304, $1306, $1308
FISH_ANIMATION_COUNT = 6
FISH_ANIMATION_DELAY = 4
FISH_ANIMATION_START_DELAY = $100

animate_fish
.al
.xl
    lda title_tile_anim_delay
    beq _cycle
    dec title_tile_anim_delay
    bra _write
_cycle
    inc title_tile_anim_frame
    lda title_tile_anim_frame
    cmp #FISH_ANIMATION_DELAY
    bne _write
    stz title_tile_anim_frame
    inc title_tile_anim_step
    lda title_tile_anim_step
    cmp #FISH_ANIMATION_COUNT
    bne _write
    stz title_tile_anim_step
    lda #FISH_ANIMATION_START_DELAY
    sta title_tile_anim_delay
_write
    sep #$20
    lda #$80
    sta VMAIN
    rep #$20
    ldx #$066a
    stx VMADD
    lda title_tile_anim_step
    asl
    tax
    lda FISH_ANIMATION_VALUES,x
    sta VMDATA
    rts

; clears from $3000.w to $3fff.w
clear_bg3_tiles
.as
.xl
    ldx #DMAMODE_PPUFILL
    stx DMAMODE
    ldx #<>ZERO
    stx DMAADDR
    lda #`ZERO
    sta DMAADDRBANK
    ldx #$2000 ; in bytes
    stx DMALEN
    ldx #$3000 ; in words
    stx VMADDL

    lda #$80
    sta VMAIN

    lda #1
    sta MDMAEN

    rts