state_gameplay_init
.al
.xl
    sep #$20
    jsr enable_force_blank

    jsr clear_bg3_tiles
    jsr palette_init
    ; todo move this? the vwf_reset_map later in the init can overwrite the 
    ; font tiles if the previous text write operation overflowed into the font
    ; tiles, when it clears its area
    jsr tileset_init ; for font and player tiles only
    jsr background_init
    jsr copy_ram_scripts

    lda #`music_water
    ldy #<>music_water
    jsr SPX_Transfer_XMS
    jsr SPXM_BuildDir
    jsr SPXM_Reset
    jsr SPX_Flush
    jsr SPXM_Play

    rep #$20

    jsr player_init

    lda #GENEVA_CHARS
    jsr vwf_set_font
    lda #1
    jsr vwf_set_palette
    lda #FONT_TYPE_8X8
    jsr vwf_set_font_type
    jsr vwf_reset_map
    jsr vwf_reset_tiles

    jsr gameplay_restore_state

    ; don't call map_set_warp because it'll initiate a fade-out and lock
    ; the player's position, which i don't want
    jsr map_run_warp
    jsr disable_force_blank
    jmp start_fade_in

state_gameplay
.al
.xl
    jsr process_input
    jsr move_player
    jsr set_updated_player_pos
    jsr run_script_v2

    ; run_script_v2 changes to 8 bit, change back
    rep #$20
    jsr animate_npcs
    jsr vwf_frame_loop

    lda target_warp_map
    beq +
    jsr start_fade_out
    jsr wait_for_effect
    ; this might go into the next frame (but it's ok because it enables force blank)
    jsr map_run_warp
    jsr start_fade_in
    jmp disable_force_blank
+   rts

background_init
.as
.xl
    ; set up screen addresses
    stz BG1SC ; we want the screen at $0000 and size 32x32
    lda #%00000100 ; layer 2 at $0400.w and size 32x32
    sta BG2SC
    lda #%00001010 ; layer 3 at $0800.w and size 32x64
    sta BG3SC

    ; BG1 tile data at $1000 which is the first 4K word step
    ; BG2 tile data at $2000
    lda #$21
    sta BG12NBA

    lda #3
    sta BG34NBA ; BG3 tile data at $3000

    lda #$9
    sta BGMODE
    sta my_bgmode ; 8x8 chars mode 1, BG3 priority

    ; $3ff = -1 vertical scroll, since first line is not drawn
    lda #$ff
    sta BG1VOFS
    lda #$03
    sta BG1VOFS

    ; enable bg1+bg3+obj on main screen
    lda #(BG1_ON | BG3_ON | OBJ_ON)
    sta TM
    sta my_tm

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

    ldx #size(TITLE_HDMA_TABLE) - 1
-   lda TITLE_HDMA_TABLE, x
    sta title_glitch_hdma_table, x
    dex
    bpl -


    rts

process_input
.al
.xl
    lda joypad_new
    ; if (A pressed && !script_ptr && facing_object_script)
    bit #A_BUTTON
    beq +
    lda script_ptr
    bne +
    ldx facing_object_script
    beq +

    lda OBJECT_SCRIPTS - 2, x
    ldy OBJECT_SCRIPT_LENGTHS - 2, x
    tax
    jsr set_script

+   lda joypad_new
    bit #SELECT_BUTTON
    beq +
    jmp save_game

+   bit #START_BUTTON
    beq +
    jmp load_game

+   bit #X_BUTTON
    beq +
    jsr gameplay_save_state
    jmp open_journal ; discards call stack

+   rts


spc_message_received
    rts

state_gameplay_vblank
.al
.xl
    sep #$20

    ; move player and send updated position to OAM
    jsr vblank_oam_dma

    ; send over any new vram tiles
    jsr dma_queue_run_vblank

    ; DMA generated text tiles if needed, or reset tilemap if turning off text box
    ; send HDMA table for text box overlay if needed
    jsr text_box_vblank

    rts

gameplay_save_state
.al
.xl
    ; save player position. this is so that map_set_warp will use this
    ; position when reloading the map when coming back to gameplay, instead
    ; of the default start position for the map
    lda player_x
    sta target_player_x
    lda player_y
    sta target_player_y

    ; save scroll position
    lda my_bghofs
    sta saved_bghofs
    lda my_bgvofs
    sta saved_bgvofs
    rts

gameplay_restore_state
.al
.xl
    lda current_map_id
    sta target_warp_map

    ; do not explicitly need to restore player position because map_set_warp calls
    ; player_set_initial_position, which will do it

    ; restore scroll position
    lda saved_bghofs
    sta my_bghofs
    lda saved_bgvofs
    sta my_bgvofs

    stz my_bg3hofs
    stz my_bg3vofs

    rts