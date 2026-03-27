MENU_OPTION_START .text $80, "Start", 255
MENU_OPTION_CONTINUE .text $80, "Continue", 255
MENU_OPTION_ID_START = 1
MENU_OPTION_ID_CONTINUE = 2

SCRIPT_FILE_SELECT
    #step_text_box 11, 12, 9, 2, MENU_OPTION_START, MENU_OPTION_CONTINUE, EMPTY_STRING, EMPTY_STRING
    #step_wait WAIT_RESULT_NO_CANCEL
    #step_read_result SCRIPT_STORAGE_TEMP_RESULT
    #step_branch_label OPCODE_BRANCH_NE, SCRIPT_STORAGE_TEMP_RESULT, MENU_OPTION_ID_START, SCRIPT_FILE_SELECT, _show_slots
    #step_call_function go_to_opening
_show_slots
    #step_call_function build_save_slot_strings
    #step_clear_text_tiles
    #step_wait 1
    #step_text_box 1, 11, 30, 3, save_slot_string1, save_slot_string2, save_slot_string3, EMPTY_STRING
_reread_result
    #step_wait WAIT_RESULT_CANCEL_OK
    #step_read_result SCRIPT_STORAGE_SAVE_SLOT
    #step_branch_label OPCODE_BRANCH_NE, SCRIPT_STORAGE_SAVE_SLOT, RESULT_CANCELLED, SCRIPT_FILE_SELECT, _check_slot
    ; cancelled, go back to start/continue
    #step_clear_text_tiles
    #step_wait 1
    #step_unconditional_branch 0
_check_slot
    #step_call_function check_selected_slot_valid
    #step_branch_label OPCODE_BRANCH_EQ, SCRIPT_STORAGE_TEMP_RESULT, 1, SCRIPT_FILE_SELECT, _do_load
    ; empty slot, wait for another result (play sound effect?)
    #step_goto_label SCRIPT_FILE_SELECT, _reread_result
_do_load
    #step_hide_text_box
    #step_wait 1
    #step_call_function go_to_gameplay_load

SCRIPT_FILE_SELECT_NUM_STEPS = (* - SCRIPT_FILE_SELECT) >> 4

state_file_select_init
.al
.xl
    jsr enable_force_blank
    sep #$20
    jsr clear_ppu_ram
    jsr palette_init
    lda #%00001010 ; layer 3 at $0800.w and size 32x64
    sta BG3SC
    lda #3
    sta BG34NBA ; BG3 tile data at $3000
    lda #9
    sta BGMODE
    sta my_bgmode ; 8x8 chars mode 1, BG3 priority
    lda #BG3_ON
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

    lda #0
    sta CGADD
    lda #$a0
    sta CGDATA
    lda #$14
    sta CGDATA
    rep #$20
    lda #<>GENEVA_CHARS
    jsr vwf_set_font
    lda #0
    jsr vwf_set_palette
    lda #FONT_TYPE_8X8
    jsr vwf_set_font_type
    jsr vwf_reset_map
    jsr vwf_reset_tiles
    jsr mono_font_init
    jsr disable_force_blank
    lda #$f
    sta my_inidisp
    lda #MENU_OPTION_ID_CONTINUE - 1
    sta text_box_active_option
    ldx #<>SCRIPT_FILE_SELECT
    ldy #SCRIPT_FILE_SELECT_NUM_STEPS
    jmp set_script

state_file_select
.al
.xl
    lda text_box_num_options
    beq +
    jsr process_text_box_input
+   ldx #0
    jsr script_slot_load
    jsr run_script_v2
    rep #$20
    jsr script_slot_save
    jmp vwf_frame_loop

state_file_select_vblank
.al
.xl
    sep #$20
    jmp text_box_vblank

go_to_opening
.al
.xl
    rep #$20
    jsr clear_all_script_slots
    lda #1
    sta text_box_hide_requested
    sta target_warp_id
    stz target_warp_id+1
    ldy #STATE_ID_OPENING
    jsr run_state_init
    jmp longjmp_main

go_to_gameplay_load
    rep #$20
    jsr clear_all_script_slots
    lda #1
    sta text_box_hide_requested
    lda script_storage + (SCRIPT_STORAGE_SAVE_SLOT * 2)
    jsr slot_number_to_offset
    jsr load_game
    ldy #STATE_ID_GAMEPLAY
    jsr run_state_init
    jmp longjmp_main