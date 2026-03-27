; script interpreter and related test scripts

; a script is an array of steps and a length
; each step is 16 bytes long (1 timing word, 1 opcode word, and 12 data bytes)
; +0: number of frames to wait before continuing
;    > 0: time delay before moving on
;      0: one-time action
;     -1: wait for A button
;     -2: wait for script_step_result to change to non-zero, B to continue anyway
;     -3: wait for script_step_result to change to non-zero, no cancel
; +2: opcode
; +4..F: up to 12 parameter bytes depending on the type of step, then padding
;        to 16 byte boundary
; the last step only needs the bytes actually read for the step, not all 16

SELF = $ff

WAIT_FOR_A = -1
WAIT_RESULT_CANCEL_OK = -2
WAIT_RESULT_NO_CANCEL = -3
RANDOM_WAIT = -4

RESULT_CANCELLED = -1

; canonical location for temp decision text box results when not changing
; a persistent var
SCRIPT_STORAGE_TEMP_RESULT = 0
SCRIPT_STORAGE_IN_MENU = 1
SCRIPT_STORAGE_SAVE_SLOT = 2

; script opcodes:
; $0: no operation
; $1: show text box
; $2: hide text box
; $3: set object flags
; $4: set object position
; $5: add/sub object x
; $6: add/sub object y
; $7: set sprite direction
; $8: set variable
; $9: read script_step_result into variable, reset result
; $a: increment variable
; $b: add two variables or variable+constant
; $c: unconditional branch
; $d: branch if equal
; $e: branch if not equal
; $f: lock/unlock player
; $10: clear text tiles (keep box visible)
; $11: save game
; $12: call function

; can eliminate some redundancy in the implementations of these
script_operations
    .addr op_none
    .addr op_text_box, op_hide_text_box
    .addr op_set_object_flags, op_set_object_position
    .addr op_move_object_x, op_move_object_y
    .addr op_set_sprite_direction
    .addr op_set_variable
    .addr op_read_result
    .addr op_inc_variable
    .addr op_add
    .addr op_unconditional_branch
    .addr op_branch_eq
    .addr op_branch_ne
    .addr op_set_player_locked
    .addr op_clear_text_tiles
    .addr op_save_game
    .addr op_call_function

; just wait for the specified amount of frames
OPCODE_WAIT = 0

step_wait .macro
    .sint \1
    .word OPCODE_WAIT
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.endm

; +4: AND mask for rng result
; +6: minimum value to add
; result = (rng_next & mask) + minimum
step_random_wait .macro
    .sint RANDOM_WAIT
    .word OPCODE_WAIT
    .word \1
    .word \2
    .fill 8
.endm

; for text boxes:
; +4: x byte (8x8 tile coordinates)
; +5: y byte (8x8 tile coordinates)
; +6: width byte (8x8 tile coordinates)
; +7: number of lines (1-4)
; +8..F: up to 4 line pointers
; height is always 8px * (2 + num lines)
; TODO if lines are always stored contiguously in memory, only need one pointer
; and can use the 255 to advance to the next line
OPCODE_TEXT_BOX = 1

; TODO: named/default parameters
step_text_box .macro
    .sint 0
    .word OPCODE_TEXT_BOX
    .byte \1
    .byte \2
    .byte \3
    .byte \4
    .word <>\5
    .word <>\6
    .word <>\7
    .word <>\8
.endm

; hide the currently shown text box and return
OPCODE_HIDE_TEXT_BOX = 2

step_hide_text_box .macro
    .sint 0
    .word OPCODE_HIDE_TEXT_BOX
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.endm

; clear text tiles and reset text rendering, but keep box visible
OPCODE_CLEAR_TEXT_TILES = $10

step_clear_text_tiles .macro
    .sint 0
    .word OPCODE_CLEAR_TEXT_TILES
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.endm

; sets flip/priority/palette byte in object_flags
; +4: object index (0-6)
; +6: flags value
OPCODE_SET_OBJECT_FLAGS = 3

step_set_object_flags .macro
    .sint 0
    .word OPCODE_SET_OBJECT_FLAGS
    .word \1
    .word \2
    .fill 8
.endm

; sets x/y position of object in half-pixels
; +4: object index (0-6)
; +6: x (half-pixels)
; +8: y (half-pixels)
OPCODE_SET_OBJECT_POS = 4

step_set_object_pos .macro
    .sint 0
    .word OPCODE_SET_OBJECT_POS
    .word \1
    .word \2
    .word \3
    .fill 6
.endm

; adds a signed delta to object position each frame (half-pixels)
; +4: object index (0-6)
; +6: signed delta per frame (half-pixels)
OPCODE_MOVE_OBJECT_X = 5
step_move_object_x .macro
    .sint \1
    .word OPCODE_MOVE_OBJECT_X
    .word \2
    .sint \3
    .fill 8
.endm

OPCODE_MOVE_OBJECT_Y = 6
step_move_object_y .macro
    .sint \1
    .word OPCODE_MOVE_OBJECT_Y
    .word \2
    .sint \3
    .fill 8
.endm

; sets the direction (calculates the offset into the walk cycle)
; eventually will be used for other animations too?
; this is a true sprite id, 0 means player, 1 means object 0, etc
; +4: object index
; +5: direction
OPCODE_SET_SPRITE_DIRECTION = 7
step_set_sprite_direction .macro
    .sint 0
    .word OPCODE_SET_SPRITE_DIRECTION
    .byte \1
    .byte \2
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.endm

; +4: step to branch to
OPCODE_UNCONDITIONAL_BRANCH = $c
step_unconditional_branch .macro
    .sint 0
    .word OPCODE_UNCONDITIONAL_BRANCH
    .word \1
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.endm

step_goto_label .macro
    .sint 0
    .word OPCODE_UNCONDITIONAL_BRANCH
    .word (\1.\2 - \1) >> 4
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.endm

; +4: variable slot
; +6: the value
OPCODE_SET_VARIABLE = 8
step_set_variable .macro
    .sint 0
    .word OPCODE_SET_VARIABLE
    .word \1
    .word \2
    .byte 0, 0, 0, 0, 0, 0, 0, 0
.endm

; +4: variable slot
; +6: value to compare
; +8: step to branch to
OPCODE_BRANCH_EQ = $d
step_branch_eq .macro
    .sint 0
    .word OPCODE_BRANCH_EQ
    .word \1
    .word \2
    .word \3
    .byte 0, 0, 0, 0, 0, 0
.endm

OPCODE_BRANCH_NE = $e
step_branch_ne .macro
    .sint 0
    .word OPCODE_BRANCH_NE
    .word \1
    .word \2
    .word \3
    .byte 0, 0, 0, 0, 0, 0
.endm

step_branch_label .macro
    .sint 0
    .word \1
    .word \2
    .sint \3
    .word (\4.\5 - \4) >> 4
    .byte 0, 0, 0, 0, 0, 0
.endm

OPCODE_INC_VARIABLE = $a
step_inc_variable .macro
    .sint 0
    .word OPCODE_INC_VARIABLE
    .word \1
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.endm

OPCODE_SET_PLAYER_LOCKED = $f
step_set_player_locked .macro
    .sint 0
    .word OPCODE_SET_PLAYER_LOCKED
    .word \1
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.endm

OPCODE_ADD = $b
; script_storage[dst] = script_storage[src1] + src2
; +4: destination variable index
; +6: source1 variable index
; +8: flags (currently 0 = src2 is a variable, 1 = src2 is a constant)
; +9: source2 (variable index or constant value)
step_add .macro
    .sint 0
    .word OPCODE_ADD
    .word \1 ; dst
    .word \2 ; src1
    .byte \3 ; flags
    .word \4 ; src2
    .byte 0, 0, 0, 0, 0
.endm

OPCODE_READ_RESULT = $9
; script_storage[dst] = script_step_result
; +4: destination variable index
step_read_result .macro
    .sint 0
    .word OPCODE_READ_RESULT
    .word \1
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.endm

OPCODE_SAVE_GAME = $11

step_save_game .macro
    .sint 0
    .word OPCODE_SAVE_GAME
    .fill 12
.endm

OPCODE_CALL_FUNCTION = $12

; +4: function address (24-bit)
step_call_function .macro
    .sint 0
    .word OPCODE_CALL_FUNCTION
    .addr \1
    .byte `\1
    .fill 9
.endm

; this gets copied to RAM so it can modify the script with a pointer to the
; location name that's being entered when the map is loaded
DISPLAY_LOCATION_NAME_TEMPLATE
    #step_wait 8
    ; first line pointer is modified
    #step_text_box 1, 1, 24, 1, $DEAD, 0, 0, 0
    #step_wait $80
    #step_hide_text_box

DISPLAY_LOCATION_NAME_LENGTH = * - DISPLAY_LOCATION_NAME_TEMPLATE

EMPTY_STRING .byte $ff
MESSAGE_SAVED .text "Saved", $ff
MESSAGE_SAVE_CORRUPTED .text "Save data corrupted", $ff
OBJECT_DESC .text "What could be down here?", $ff
OBJECT_DESC2_1 .text "It's a standard 55-gallon drum.", $ff
OBJECT_DESC2_2 .text "'AMMONIUM PERSULFATE NET WT 412 KG'", $ff

BOOKSHELF_MESSAGE1 .text "Hey!", $ff
BOOKSHELF_MESSAGE2 .text "Don't look in there.", $ff

TEST_DECISION_1 .text "Pet the cat?", $ff
TEST_DECISION_2 .text $80, "Yes", $ff
TEST_DECISION_3 .text $80, "No", $ff
TEST_DECISION_4 .text $80, "Maybe...", $ff
TEST_MEOW .text "Meow", $ff

SCRIPT_MESSAGE_SAVED
    #step_text_box 1, 1, 5, 1, MESSAGE_SAVED, 0, 0, 0
    #step_wait $40
    #step_hide_text_box

SCRIPT_MESSAGE_SAVE_CORRUPTED
    #step_text_box 1, 1, 13, 1, MESSAGE_SAVE_CORRUPTED, 0, 0, 0
    #step_wait $80
    #step_hide_text_box

TEST_OBJECT_SCRIPT
    ; bug: if the script was triggered by pressing A, that A press would
    ; immediately dismiss the indeterminate text box, so wait a frame
    #step_wait 1
    #step_text_box 1, 21, 30, 1, OBJECT_DESC, 0, 0, 0
    #step_wait WAIT_FOR_A
    #step_hide_text_box

TEST_HAIR_BLEACH
    #step_text_box 1, 21, 30, 3, OBJECT_DESC2_1, EMPTY_STRING, OBJECT_DESC2_2, 0
    #step_wait $c0
    #step_hide_text_box

TEST_REACT_TO_BOOKSHELF
    #step_set_player_locked 1
    #step_set_object_pos 0, $d0, $14e
    #step_set_sprite_direction 1, PLAYER_DIRECTION_UP
    #step_set_object_flags 0, $3a
    #step_move_object_y 8, 0, -2
    #step_set_sprite_direction 1, 0
    #step_text_box 7, 18, 4, 1, BOOKSHELF_MESSAGE1, 0, 0, 0
    #step_wait $20
    #step_set_sprite_direction 1, PLAYER_DIRECTION_RIGHT
    #step_move_object_x 24, 0, 2
    #step_set_sprite_direction 1, 0
    #step_hide_text_box
    #step_set_sprite_direction 1, PLAYER_DIRECTION_UP
    #step_move_object_y 48, 0, -2
    #step_set_sprite_direction 1, 0
    #step_text_box 1, 21, 30, 1, BOOKSHELF_MESSAGE2, 0, 0, 0
    #step_wait $80
    #step_hide_text_box
    #step_set_sprite_direction 1, PLAYER_DIRECTION_DOWN
    #step_move_object_y 32, 0, 2
    #step_set_sprite_direction 1, PLAYER_DIRECTION_RIGHT
    #step_move_object_x 64, 0, 2
    #step_set_object_flags 0, 0
    #step_set_sprite_direction 1, 0
    #step_set_player_locked 0

TEST_MISC
    ; test add opcode
    ; [0] = 4
    ; [1] = 8
    ; [2] = [0] + [1]
    ; [3] = 12
    ; [3] = [3] + 16
    ; #step_set_variable 0, 4
    ; #step_set_variable 1, 8
    ; #step_add 2, 0, 0, 1
    ; #step_set_variable 3, 12
    ; #step_add 3, 3, 1, 16

    ; test decision text box
    #step_text_box 1, 21, 30, 4, TEST_DECISION_1, TEST_DECISION_2, TEST_DECISION_3, TEST_DECISION_4
    #step_wait WAIT_RESULT_NO_CANCEL
    #step_read_result SCRIPT_STORAGE_TEMP_RESULT
    #step_branch_ne SCRIPT_STORAGE_TEMP_RESULT, 1, 8
    #step_clear_text_tiles
    ; clear_text_tiles takes one vblank to take effect. if i immediately went
    ; on to the step_text_box, the pending clear action would immediately clear
    ; the new text.
    #step_wait 1
    #step_text_box 1, 21, 30, 1, TEST_MEOW, 0, 0, 0
    #step_wait WAIT_FOR_A
    #step_hide_text_box

SCRIPT_CAT
    #step_set_sprite_direction SELF, 0
    #step_random_wait $1f, $10
    #step_set_sprite_direction SELF, PLAYER_DIRECTION_RIGHT
    #step_move_object_x $20, SELF, 2
    #step_set_sprite_direction SELF, 0
    #step_random_wait $1f, $10
    #step_set_sprite_direction SELF, PLAYER_DIRECTION_LEFT
    #step_move_object_x $20, SELF, -2
    #step_unconditional_branch 0

OBJECT_SCRIPTS .addr TEST_OBJECT_SCRIPT, TEST_HAIR_BLEACH, TEST_REACT_TO_BOOKSHELF, TEST_MISC, SCRIPT_CAT
OBJECT_SCRIPT_LENGTHS .word 4, 3, 25, 9, 9
CAT_SCRIPT_INDEX = 5

; resolves object target index from script byte +4 into X
; SELF ($ff) → current_script_slot - 2 (= object_index * 2)
; assumes 16-bit accumulator
resolve_target .macro
    .block
    ldy #$4
    lda (script_element_ptr),y
    and #$ff
    cmp #SELF
    bne _not_self
    ldx current_script_slot
    dex
    dex
    bra _done
_not_self
    asl
    tax
_done
    .bend
.endm

; resolves sprite target index from script byte +4 into X
; SELF ($ff) → current_script_slot (= sprite_id * 2)
; assumes 8-bit accumulator
load_anim_index .macro
    .block
    ldy #$4
    lda (script_element_ptr),y
    cmp #SELF
    bne _not_self
    ldx current_script_slot
    bra _done
_not_self
    asl
    tax
_done
    .bend
.endm

copy_ram_scripts
.as
.xl
    ldx #DISPLAY_LOCATION_NAME_LENGTH - 1
-   lda DISPLAY_LOCATION_NAME_TEMPLATE,x
    sta location_name_script,x
    dex
    bpl -

    rts

; sets the script to run, if a script is not already running
; X: address of script to run
; Y: length of the script
; assumes: AXY 16
set_script
.al
.xl
    lda script_slot_ptr
    bne +
    stx script_slot_ptr
    stx script_slot_element_ptr
    sty script_slot_length
    stz script_slot_step
    stz script_slot_result
    stx zp0
    lda (zp0)
    sta script_slot_time_remaining
+   rts

clear_script
.al
.xl
    stz script_ptr
    stz script_element_ptr
    stz script_step
    stz script_length
    rts

clear_all_script_slots
.al
.xl
    ldx #(NUM_SCRIPT_SLOTS - 1) * 2
-   stz script_slot_ptr,x
    stz script_slot_element_ptr,x
    stz script_slot_step,x
    stz script_slot_length,x
    stz script_slot_time_remaining,x
    stz script_slot_result,x
    dex
    dex
    bpl -
    rts

; X = slot index * 2
script_slot_load
.al
.xl
    lda script_slot_ptr,x
    sta script_ptr
    lda script_slot_element_ptr,x
    sta script_element_ptr
    lda script_slot_step,x
    sta script_step
    lda script_slot_length,x
    sta script_length
    lda script_slot_time_remaining,x
    sta script_step_time_remaining
    lda script_slot_result,x
    sta script_step_result
    stx current_script_slot
    rts

script_slot_save
.al
.xl
    ldx current_script_slot
    lda script_ptr
    sta script_slot_ptr,x
    lda script_element_ptr
    sta script_slot_element_ptr,x
    lda script_step
    sta script_slot_step,x
    lda script_length
    sta script_slot_length,x
    lda script_step_time_remaining
    sta script_slot_time_remaining,x
    lda script_step_result
    sta script_slot_result,x
    rts

run_all_scripts
.al
.xl
    ; slot 0: interaction script
    ldx #0
    jsr script_slot_load
    jsr run_script_v2
    rep #$20
    jsr script_slot_save

    ; slots 1-7: object background scripts
    lda num_active_objects
    beq _all_done

    stz zp0

_next_bg
    lda zp0
    asl
    tax
    lda object_bg_script,x
    beq _skip_bg

    ; slot = (object_index + 1) * 2
    lda zp0
    inc a
    asl
    tax
    jsr script_slot_load
    jsr run_script_v2
    rep #$20
    jsr script_slot_save

_skip_bg
    inc zp0
    lda zp0
    cmp num_active_objects
    bne _next_bg

_all_done
    rts

set_script_step
.al
.xl
    sta script_step
    asl
    asl
    asl
    asl
    clc
    adc script_ptr
    sta script_element_ptr
    rts

run_script_v2
.al
.xl
    lda script_ptr
    bne _check_script_end
    rts

_check_script_end
    lda script_step
    cmp script_length
    bne _run_step
    jmp clear_script

_run_step
    ldy #$2
    lda (script_element_ptr),y
    asl
    tax
    per _done_with_step - 1
    sep #$20
    jmp (script_operations,x)

_done_with_step
    rep #$20
    ; check for negative length
    lda script_step_time_remaining
    bpl _check_time

_check_indeterminate
    cmp #-1
    beq _check_a_button
    cmp #+RANDOM_WAIT
    beq _handle_random_wait

_check_result_condition
    lda script_step_result
    bne _go_to_next_step
    rts

_check_a_button
    lda joypad_new
    bit #A_BUTTON
    bne _go_to_next_step
    rts

_handle_random_wait
    jsr rng_next
    ldy #$4
    and (script_element_ptr),y
    clc
    ldy #$6
    adc (script_element_ptr),y
    sta script_step_time_remaining
    rts

    ; not indeterminate
_check_time
    dec script_step_time_remaining
    bmi _go_to_next_step
    rts

_go_to_next_step
    inc script_step
    lda script_step
    cmp script_length
    bne +
    rts

+   lda script_element_ptr
    clc
    adc #$10
    sta script_element_ptr
    lda (script_element_ptr)
    sta script_step_time_remaining
    bra _run_step

op_none
.as
.xl
    rts

op_text_box
.as
.xl
    ldy #$4
    lda (script_element_ptr),y
    sta text_box_x
    ldy #$5
    lda (script_element_ptr),y
    sta text_box_y

    ldy #$6
    lda (script_element_ptr),y
    sta text_box_width
    ldy #$7
    lda (script_element_ptr),y
    sta text_box_num_lines
    rep #$20
    lda #1
    sta text_box_enabled
    lda script_element_ptr
    clc
    adc #8
    sta text_box_lines

    stz text_index

    lda (text_box_lines)
    ldx text_box_x
    inx
    ldy text_box_y
    iny
    jmp vwf_init_string

op_hide_text_box
.as
.xl
    lda #1
    sta text_box_hide_requested
    rts

op_clear_text_tiles
.as
.xl
    lda #$1
    sta text_box_clear_requested
    rts

op_set_object_flags
.as
.xl
    rep #$20
    #resolve_target
    ldy #$6
    lda (script_element_ptr),y
    and #$ff
    sta object_flags,x
    rts

op_set_object_position
.as
.xl
    rep #$20
    #resolve_target
    ldy #$6
    lda (script_element_ptr),y
    sta object_x,x
    ldy #$8
    lda (script_element_ptr),y
    sta object_y,x
    rts

op_move_object_x
.as
.xl
    rep #$20
    #resolve_target
    ldy #$6
    lda (script_element_ptr),y
    clc
    adc object_x,x
    sta object_x,x
    rts

op_move_object_y
.as
.xl
    rep #$20
    #resolve_target
    ldy #$6
    lda (script_element_ptr),y
    clc
    adc object_y,x
    sta object_y,x
    rts

op_set_sprite_direction
.as
.xl
    #load_anim_index

    rep #$20
    lda sprites_anim_direction,x
    sta sprites_anim_previous_direction,x
    ldy #$5
    lda (script_element_ptr),y
    and #$ff
    bne +

    ; direction 0 -> go to standing pose
    stz sprites_anim_offset,x

+   sta sprites_anim_direction,x

    rts

op_set_variable
.as
.xl
    rep #$20
    ldy #$4
    lda (script_element_ptr),y
    asl
    tax
    ldy #$6
    lda (script_element_ptr),y
    sta script_storage,x
    rts

op_read_result
.as
.xl
    rep #$20
    lda script_step_result
    pha
    stz script_step_result
    ldy #$4
    lda (script_element_ptr),y
    asl
    tax
    pla
    sta script_storage,x
    rts

op_inc_variable
.as
.xl
    rep #$20
    ldy #$4
    lda (script_element_ptr),y
    asl
    tax
    inc script_storage,x
    rts

; script_storage[dst] = script_storage[src1] + src2
; +4: destination variable index
; +6: source1 variable index
; +8: flags (currently 0 = src2 is a variable, 1 = src2 is a constant)
; +9: source2 (variable index or constant value)
; #step_add 1, 0, 0, 5 → script_storage[1] = script_storage[0] + 5
op_add
.as
.xl
    rep #$20
    ; push src1 to stack
    ldy #$6
    lda (script_element_ptr),y
    asl
    tax
    lda script_storage,x
    pha

    ; decide if src2 is variable or constant
    ldy #$8
    lda (script_element_ptr),y
    and #$1
    bne _src2_constant

_src2_variable
    ldy #$9
    lda (script_element_ptr),y
    asl
    tax
    lda script_storage,x
    bra _do_add

_src2_constant
    ldy #$9
    lda (script_element_ptr),y

    ; A is now set up with src2
_do_add
    clc
    ; todo study as example for stack addressing in other places, nice
    adc 1, s
    sta 1, s
    ldy #$4
    lda (script_element_ptr),y
    asl
    tax
    pla
    sta script_storage,x
    rts

op_unconditional_branch
.as
.xl
    rep #$20
    ldy #$4
    lda (script_element_ptr),y
    ; will be incremented after this runs, so need to decrement here
    dec a
    jmp set_script_step

op_branch_eq
.as
.xl
    rep #$20
    ldy #$4
    lda (script_element_ptr),y
    asl
    tax
    ldy #$6
    lda (script_element_ptr),y
    cmp script_storage,x
    bne +
    ldy #$8
    lda (script_element_ptr),y
    dec a
    jmp set_script_step
+   rts

op_branch_ne
.as
.xl
    rep #$20
    ldy #$4
    lda (script_element_ptr),y
    asl
    tax
    ldy #$6
    lda (script_element_ptr),y
    cmp script_storage,x
    beq +
    ldy #$8
    lda (script_element_ptr),y
    dec a
    jmp set_script_step
+   rts

op_set_player_locked
.as
.xl
    rep #$20
    ldy #$4
    lda (script_element_ptr),y
    sta player_locked

    rts

op_save_game
.as
.xl
    rep #$20
    lda script_storage + (SCRIPT_STORAGE_SAVE_SLOT * 2)
    jsr slot_number_to_offset
    jmp save_game

op_call_function
.as
.xl
    rep #$20
    ldy #$4
    lda (script_element_ptr),y
    sta $00
    ldy #$6
    lda (script_element_ptr),y
    and #$ff
    sta $02
    jml [$0000]