state_gameplay_init
.al
.xl
    sep #$20

    jsr palette_init
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
    jsr vwf_reset_tiles

    ; hardcoded load of initial map. don't call map_set_warp because it'll
    ; initiate a fade-out and lock the player's position, which i don't want
    lda #2
    sta target_warp_map

    ; this will also disable force blank and set up the fade-in effect
    jsr map_run_warp

    rts

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
    ; this might go into the next frame (but it's ok because it enables force blank)
    jmp map_run_warp

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
    sta my_bgmode ; 8x8 chars mode 1, BG3 priority

    ; $3ff = -1 vertical scroll, since first line is not drawn
    lda #$ff
    sta BG1VOFS
    lda #$03
    sta BG1VOFS

    ; enable bg1+bg3+obj on main screen
    lda #(BG1_ON | BG3_ON | OBJ_ON)
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