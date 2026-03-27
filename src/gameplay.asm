state_gameplay_init
.al
.xl
    sep #$20

    ; skip music init if coming back from the journal
    lda game_state
    cmp #STATE_ID_JOURNAL
    beq +
    ; opening had faded the volume to 0
    ldx #255
    jsr spcSetModuleVolume
    ldx	#1
	jsr	spcLoad
    ldx #0
    jsr spcPlay
    jsr spcFlush
-   jsr spcReadStatus
    bit #SPC_P
    beq -

+   jsr enable_force_blank

    jsr clear_bg3_tiles
    jsr clear_bg3_tilemap
    jsr palette_init
    jsr background_init
    jsr copy_ram_scripts

    rep #$20

    jsr player_init

    lda #<>GENEVA_CHARS
    jsr vwf_set_font
    lda #0
    jsr vwf_set_palette
    lda #FONT_TYPE_8X8
    jsr vwf_set_font_type
    jsr vwf_reset_map
    jsr vwf_reset_tiles
    ; for Geneva font
    jsr mono_font_init

    ; don't call map_set_warp because it'll initiate a fade-out and lock
    ; the player's position, which i don't want. warp id was already set to 1
    ; in file_sel if "start" is chosen
    lda target_warp_id
    beq _no_warp
    jsr map_run_warp
    bra _map_loaded
_no_warp
    ; for returning from journal or loading game
    jsr load_map
_map_loaded
    stz my_bg3hofs
    stz my_bg3vofs
    jsr update_scroll
    jsr disable_force_blank
    jmp start_fade_in

state_gameplay
.al
.xl
    jsr rng_next
    jsr process_input
    jsr move_player
    jsr update_scroll
    jsr set_updated_player_pos
    jsr set_updated_object_positions
    jsr run_all_scripts
    jsr animate_npcs
    jsr vwf_frame_loop

    ; warp-or-load-map is getting kind of messy
    lda target_warp_id
    beq +
    ; map_set_warp starts a fade out
    jsr wait_for_effect
    ; this might go into the next frame (but it's ok because it enables force blank)
    jsr map_run_warp
    jsr start_fade_in
    jmp disable_force_blank
+   lda target_map_id
    beq +
    jsr wait_for_effect
    jsr load_map
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
-   lda TEXT_HDMA_TABLE,x
    sta text_box_hdma_table,x
    dex
    bpl -

    ldx #size(TITLE_HDMA_TABLE) - 1
-   lda TITLE_HDMA_TABLE,x
    sta title_glitch_hdma_table,x
    dex
    bpl -

    rts

process_input
.al
.xl
    lda text_box_num_options
    beq +
    ; active text box overrides any other input
    jmp process_text_box_input

+   lda joypad_new
    ; if (A pressed && !script_ptr && facing_object_script)
    bit #A_BUTTON
    beq +
    lda script_slot_ptr
    bne +
    ldx facing_object_script
    beq +

    lda OBJECT_SCRIPTS - 2,x
    ldy OBJECT_SCRIPT_LENGTHS - 2,x
    tax
    jsr set_script

+   lda joypad_new
    bit #SELECT_BUTTON
    beq +
    ldx current_save_slot_offset
    jmp save_game

+   bit #START_BUTTON
    beq +
    ldx current_save_slot_offset
    jmp load_game

+   bit #X_BUTTON
    beq +
    ldx #<>SCRIPT_SHOW_MENU
    ldy #SCRIPT_SHOW_MENU_NUM_STEPS
    jsr set_script

+   bit #Y_BUTTON
    beq +
    jsr gameplay_save_state
    jmp open_journal ; discards call stack

+   rts

CURSOR_OAM_OFFSET = (15 * 4)

process_text_box_input
.al
.xl
_check_b
    lda joypad_new
    bit #B_BUTTON
    beq _check_a
    lda script_slot_time_remaining
    ; + to accept signed constant operands
    cmp #+WAIT_RESULT_CANCEL_OK
    bne _check_a
    lda #+RESULT_CANCELLED
    sta script_slot_result
    rts

_check_a
    lda joypad_new
    bit #A_BUTTON
    beq _check_up_down
    lda text_box_active_option
    inc a
    sta script_slot_result
    rts

_check_up_down
    lda joypad_new
    bit #UP_BUTTON
    beq _check_down

    ; up pressed - decrement selection with wrapping
    lda text_box_active_option
    beq _wrap_to_bottom
    dec a
    sta text_box_active_option
    bra _done

_wrap_to_bottom
    lda text_box_num_options
    dec a
    sta text_box_active_option
    bra _done

_check_down
    lda joypad_new
    bit #DOWN_BUTTON
    beq _done

    ; down pressed - increment selection with wrapping
    lda text_box_active_option
    inc a
    cmp text_box_num_options
    bcc _store_selection
    lda #0

_store_selection
    sta text_box_active_option

_done
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
    
    rep #$20
    lda script_storage + (SCRIPT_STORAGE_IN_MENU << 1)
    beq +
    jsr draw_play_timer

+   rts

gameplay_save_state
.al
.xl
    ; save player position. this is so that map_set_warp will use this
    ; position when reloading the map when coming back to gameplay, instead
    ; of the default start position for the map
    lda current_map_id
    sta target_map_id
    lda player_x
    sta target_player_x
    lda player_y
    sta target_player_y

    rts

clear_bg3_tilemap
.as
.xl
    ldx #DMAMODE_PPUFILL
    stx DMAMODE

    ldx #<>ZERO
    stx DMAADDR
    lda #`ZERO
    sta DMAADDRBANK
    ldx #$800
    stx VMADD ; in words
    stx DMALEN ; in bytes

    lda #$80
    sta VMAIN
    lda #1
    sta MDMAEN
    rts