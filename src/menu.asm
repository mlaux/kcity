MENU_OPTION_ITEMS .text $80, "Items", 255
MENU_OPTION_SAVE .text $80, "Save", 255
MENU_OPTION_ID_ITEMS = 1
MENU_OPTION_ID_SAVE = 2

SCRIPT_STORAGE_SAVE_SLOT = 2

SCRIPT_SHOW_MENU
    #step_set_player_locked 1
    #step_set_variable SCRIPT_STORAGE_IN_MENU, 1
    #step_text_box 1, 1, 10, 4, MENU_OPTION_ITEMS, MENU_OPTION_SAVE, EMPTY_STRING, EMPTY_STRING
    #step_wait WAIT_RESULT_CANCEL_OK
    #step_read_result SCRIPT_STORAGE_TEMP_RESULT
    #step_branch_label OPCODE_BRANCH_NE, SCRIPT_STORAGE_TEMP_RESULT, MENU_OPTION_ID_ITEMS, SCRIPT_SHOW_MENU, _check_save
    #step_wait 0 ; items action would go here
_check_save
    #step_branch_label OPCODE_BRANCH_NE, SCRIPT_STORAGE_TEMP_RESULT, MENU_OPTION_ID_SAVE, SCRIPT_SHOW_MENU, _exit_menu
    #step_call_function build_save_slot_strings
    #step_clear_text_tiles
    #step_wait 1
    #step_text_box 1, 1, 30, 4, save_slot_string1, save_slot_string2, save_slot_string3, EMPTY_STRING
    #step_wait WAIT_RESULT_CANCEL_OK
    #step_read_result SCRIPT_STORAGE_SAVE_SLOT
    #step_branch_label OPCODE_BRANCH_EQ, SCRIPT_STORAGE_SAVE_SLOT, RESULT_CANCELLED, SCRIPT_SHOW_MENU, _exit_menu
_do_save
    #step_save_game
    #step_clear_text_tiles
    #step_wait 1
    #step_text_box 1, 1, 10, 4, MESSAGE_SAVED, EMPTY_STRING, EMPTY_STRING, EMPTY_STRING
    #step_wait WAIT_FOR_A
_exit_menu
    #step_hide_text_box
    #step_set_variable SCRIPT_STORAGE_IN_MENU, 0
    #step_set_player_locked 0

SCRIPT_SHOW_MENU_NUM_STEPS = (* - SCRIPT_SHOW_MENU) >> 4
