; script interpreter and related test scripts

; a script is an array of steps and a length
; each step is 16 bytes long (1 timing word, 1 opcode word, and 12 data bytes)
; +0: number of frames to wait before continuing
;     -1: wait for A button
;      0: one-time action
;    > 0: time delay before moving on
; +2: opcode
; +4..F: up to 12 parameter bytes depending on the type of step, then padding
;        to 16 byte boundary
; the last step only needs the bytes actually read for the step, not all 16

; script opcodes:
; $0: reset text box
; $1: show text box
; $2: set sprite flags
; $3: set sprite position
; $4: add/sub sprite x
; $5: add/sub sprite y
; $6: set sprite direction
; TODO:
; $6: lock/unlock player
; $7: set variable
; $8..?: conditional branch
; - change sprite movement to use same direction system as player
; - variable length steps using table of lengths?

; just wait for the specified amount of frames
OPCODE_WAIT = 0

step_wait .macro
    .sint \1
    .word OPCODE_WAIT
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.endm

; for text boxes:
; +4: x byte (8x8 tile coordinates)
; +5: y byte (8x8 tile coordinates)
; +6: width byte (8x8 tile coordinates)
; +7: number of lines (1-4)
; +8..F: up to 4 line pointers
; height is always 8px * (2 + num lines)
OPCODE_TEXT_BOX = 1

; TODO: named/default parameters
step_text_box .macro
    .sint \1
    .word OPCODE_TEXT_BOX
    .byte \2
    .byte \3
    .byte \4
    .byte \5
    .word \6
    .word \7
    .word \8
    .word \9
.endm

; hide the currently shown text box and return
OPCODE_HIDE_TEXT_BOX = 2

step_hide_text_box .macro
    .sint 0
    .word OPCODE_HIDE_TEXT_BOX
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.endm

; sets flip/priority/palette byte in OAM
; +4: sprite index (currently 0 to 15)
; +5: value to set
OPCODE_SET_SPRITE_FLAGS = 3

step_set_sprite_flags .macro
    .sint 0
    .word OPCODE_SET_SPRITE_FLAGS
    .byte \1
    .byte \2
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.endm

; sets x/y position of sprite
; +4: sprite index
; +5: x coordinate in pixels
; +6: y coordinate in pixels
OPCODE_SET_SPRITE_POS = 4

step_set_sprite_pos .macro
    .sint 0
    .word OPCODE_SET_SPRITE_POS
    .byte \1
    .byte \2
    .byte \3
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0
.endm

; moves the sprite by the given signed value in a direction
; +4: sprite index
; +5: signed value to add to the position
OPCODE_MOVE_SPRITE_X = 5
step_move_sprite_x .macro
    .sint \1
    .word OPCODE_MOVE_SPRITE_X
    .byte \2
    .byte \3
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.endm

OPCODE_MOVE_SPRITE_Y = 6
step_move_sprite_y .macro
    .sint \1
    .word OPCODE_MOVE_SPRITE_Y
    .byte \2
    .byte \3
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.endm

; sets the direction (calculates the offset into the walk cycle)
; eventually will be used for other animations too?
; +4: sprite index
; +5: direction
OPCODE_SET_SPRITE_DIRECTION = 7
step_set_sprite_direction .macro
    .sint 0
    .word OPCODE_SET_SPRITE_DIRECTION
    .byte \1
    .byte \2
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
.endm

; TODO if lines are always stored contiguously in memory, only need one pointer
; and can use the 255 to advance to the next line
TEST_CHAR .text "Just a sample text box to test tile memory usage", 255
TEST_CHAR2 .text "MMMMMMMMMMMMMMMMMMMMMMMMMM", 255
TEST_CHAR3 .text "MMMMMMMMMMMMMMMMMMMMMMMMMM", 255
TEST_CHAR4 .text "MMMMMMMMMMMMMMMMMMMMMMMMMM", 255

TEST_SCRIPT
    ; #step_wait 10

    ; #step_set_sprite_pos 1, 96, 152
    ; #step_set_sprite_flags 1, $3a
    ; #step_set_sprite_direction 1, 3
    ; #step_text_box -1, 1, 21, 30, 4, TEST_CHAR, TEST_CHAR2, TEST_CHAR3, TEST_CHAR4
    ; #step_hide_text_box

TEST_SCRIPT_LENGTH = 0

; this gets copied to RAM so it can modify the script with a pointer to the
; location name that's being entered when the map is loaded
DISPLAY_LOCATION_NAME_TEMPLATE
    #step_wait 8
    ; first line pointer is modified
    #step_text_box $80, 1, 1, 15, 1, $DEAD, 0, 0, 0
    #step_hide_text_box

DISPLAY_LOCATION_NAME_LENGTH = * - DISPLAY_LOCATION_NAME_TEMPLATE

EMPTY_STRING .byte $ff
OBJECT_DESC .text "What could be down here?", 255
OBJECT_DESC2_1 .text "It's a standard 55-gallon drum.", 255
OBJECT_DESC2_2 .text "'AMMONIUM PERSULFATE NET WT 412 KG'", 255

BOOKSHELF_MESSAGE1 .text "Hey!", 255
BOOKSHELF_MESSAGE2 .text "Don't look in there.", 255

TEST_OBJECT_SCRIPT
    ; bug: if the script was triggered by pressing A, that A press would
    ; immediately dismiss the indeterminate text box, so wait a frame
    #step_wait 1
    #step_text_box -1, 1, 21, 30, 1, OBJECT_DESC, 0, 0, 0
    #step_hide_text_box

TEST_HAIR_BLEACH
    #step_text_box $c0, 1, 21, 30, 3, OBJECT_DESC2_1, EMPTY_STRING, OBJECT_DESC2_2, 0
    #step_hide_text_box

TEST_REACT_TO_BOOKSHELF
    #step_set_sprite_pos 1, 96, 152
    #step_set_sprite_direction 1, PLAYER_DIRECTION_UP
    #step_set_sprite_flags 1, $3a
    #step_move_sprite_y 8, 1, $ff
    #step_set_sprite_direction 1, 0
    #step_text_box $20, 7, 18, 4, 1, BOOKSHELF_MESSAGE1, 0, 0, 0
    #step_set_sprite_direction 1, PLAYER_DIRECTION_RIGHT
    #step_move_sprite_x 24, 1, 1
    #step_set_sprite_direction 1, 0
    #step_hide_text_box
    #step_set_sprite_direction 1, PLAYER_DIRECTION_UP
    #step_move_sprite_y 48, 1, $ff
    #step_set_sprite_direction 1, 0
    #step_text_box $80, 1, 21, 30, 1, BOOKSHELF_MESSAGE2, 0, 0, 0
    #step_hide_text_box
    #step_set_sprite_direction 1, PLAYER_DIRECTION_DOWN
    #step_move_sprite_y 32, 1, 1
    #step_set_sprite_direction 1, PLAYER_DIRECTION_RIGHT
    #step_move_sprite_x 64, 1, 1
    #step_set_sprite_flags 1, 0

OBJECT_SCRIPTS .word TEST_OBJECT_SCRIPT, TEST_HAIR_BLEACH, TEST_REACT_TO_BOOKSHELF
OBJECT_SCRIPT_LENGTHS .word 3, 2, 20

load_sprite_byte_index .macro
    ; x = sprite_id * 2
    ldy #$4
    lda (script_element_ptr), y
    asl
    tax
.endm

; can eliminate some redundancy in the implementations of these
script_operations
    .word op_none
    .word op_text_box, op_hide_text_box
    .word op_set_sprite_flags, op_set_sprite_position
    .word op_move_sprite_x, op_move_sprite_y
    .word op_set_sprite_direction

copy_ram_scripts
.as
.xl
    ldx #DISPLAY_LOCATION_NAME_LENGTH - 1
-   lda DISPLAY_LOCATION_NAME_TEMPLATE, x
    sta location_name_script, x
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
    lda script_ptr
    bne +
    stx script_ptr
    stx script_element_ptr
    sty script_length
    lda (script_element_ptr)
    sta script_step_time_remaining
+   rts

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
    stz script_ptr
    stz script_element_ptr
    stz script_step
    stz script_length
    rts

_run_step
    ldy #$2
    lda (script_element_ptr), y
    asl
    tax
    pea #_done_with_step - 1
    sep #$20
    jmp (script_operations, x)

_done_with_step
    rep #$20
    ; check for -1 length
    lda script_step_time_remaining
    cmp #$ffff
    bne _check_time

    lda joypad_new
    bit #A_BUTTON
    bne _go_to_next_step
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

op_hide_text_box
.as
.xl
    stz text_box_enabled
    rts

op_text_box
.as
.xl
    ldy #$4
    lda (script_element_ptr), y
    sta text_box_x
    ldy #$5
    lda (script_element_ptr), y
    sta text_box_y

    ldy #$6
    lda (script_element_ptr), y
    sta text_box_width
    ldy #$7
    lda (script_element_ptr), y
    sta text_box_num_lines
    lda #$1
    sta text_box_enabled
    rep #$20
    lda script_element_ptr
    clc
    adc #8
    sta text_box_lines

    rts

op_set_sprite_flags
.as
.xl
    #load_sprite_byte_index

    ldy #$5
    lda (script_element_ptr), y
    sta sprites_flag, x

    rts

op_set_sprite_position
.as
.xl
    #load_sprite_byte_index

    ldy #$5
    lda (script_element_ptr), y
    sta sprites_x, x

    ldy #$6
    lda (script_element_ptr), y
    sta sprites_y, x

    rts

op_move_sprite_x
.as
.xl
    #load_sprite_byte_index

    lda sprites_x, x
    ldy #$5
    clc
    adc (script_element_ptr), y
    sta sprites_x, x

    rts

op_move_sprite_y
.as
.xl
    #load_sprite_byte_index

    lda sprites_y, x
    ldy #$5
    clc
    adc (script_element_ptr), y
    sta sprites_y, x

    rts

op_set_sprite_direction
.as
.xl
    #load_sprite_byte_index

    rep #$20
    lda sprites_direction, x
    sta sprites_previous_direction, x
    ldy #$5
    lda (script_element_ptr), y
    and #$ff
    bne +

    stz sprites_animation_index, x
    inc sprites_animation_index, x

+   sta sprites_direction, x

    rts