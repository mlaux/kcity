; script interpreter and related test scripts

; a script is an array of steps and a length
; each step is 16 bytes long (1 timing word, 1 opcode word, and 12 data bytes)
; +0: number of frames to wait before continuing
;     -1: wait for A button
;      0: one-time action
;    > 0: time delay
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
; TODO:
; $6: lock/unlock player
; $7: set variable
; $8..?: conditional branch
; - change sprite movement to use same direction system as player
; - variable length steps using table of lengths?

; stop showing a text box if one is showing
OPCODE_RESET_TEXT_BOX = 0

; for text boxes:
; +4: x byte (8x8 tile coordinates)
; +5: y byte (8x8 tile coordinates)
; +6: width byte (8x8 tile coordinates)
; +7: number of lines (1-4)
; +8..F: up to 4 line pointers
; height is always 8px * (2 + num lines)
OPCODE_TEXT_BOX = 1

; sets flip/priority/palette byte in OAM
; +4: sprite index (currently 0 to 15)
; +5: value to set
OPCODE_SET_SPRITE_FLAGS = 2

; sets x/y position of sprite
; +4: sprite index
; +5: x coordinate in pixels
; +6: y coordinate in pixels
OPCODE_SET_SPRITE_POS = 3

; moves the sprite by the given signed value in a direction
; +4: sprite index
; +5: signed value to add to the position
OPCODE_MOVE_SPRITE_X = 4
OPCODE_MOVE_SPRITE_Y = 5

; TODO if lines are always stored contiguously in memory, only need one pointer
; and can use the 255 to advance to the next line
TEST_CHAR .text "Just a sample text box to test tile memory usage", 255
TEST_CHAR2 .text "MMMMMMMMMMMMMMMMMMMMMMMMMM", 255
TEST_CHAR3 .text "MMMMMMMMMMMMMMMMMMMMMMMMMM", 255
TEST_CHAR4 .text "MMMMMMMMMMMMMMMMMMMMMMMMMM", 255

TEST_SCRIPT
    .byte 10, 0, OPCODE_RESET_TEXT_BOX, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; do nothing for 10 frames

    .byte $ff, $ff, OPCODE_TEXT_BOX, 0, 1, 21, 30, 4 ; text box for 128 frames at (1, 21), width=30 tiles, lines=4
    .word TEST_CHAR, TEST_CHAR2, TEST_CHAR3, TEST_CHAR4 ; line pointers for text box

    ;.byte 1, 0, OPCODE_SET_SPRITE_POS, 0, 1, $20, $20, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; sprite 1 position 32, 32
    ;.byte 1, 0, OPCODE_SET_SPRITE_FLAGS, 0, 1, $3a, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; sprite 1 flags $3a
    ;.byte $20, 0, OPCODE_MOVE_SPRITE_X, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

    .byte 0, 0, OPCODE_RESET_TEXT_BOX, 0 ; reset
TEST_SCRIPT_LENGTH = 3

DISPLAY_LOCATION_NAME_TEMPLATE
    .byte $8, 0, OPCODE_RESET_TEXT_BOX, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; do nothing for 8 frames
    .byte $80, 0, OPCODE_TEXT_BOX, 0, 1, 1, 15, 1 ; location name text box at (1, 1), width=15 tiles, lines=1
    .word $DEAD, 0, 0, 0 ; will be replaced
    .byte 0, 0, OPCODE_RESET_TEXT_BOX, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; reset

DISPLAY_LOCATION_NAME_LENGTH = * - DISPLAY_LOCATION_NAME_TEMPLATE

EMPTY_STRING .byte $ff
OBJECT_DESC .text "What could be down here?", 255
OBJECT_DESC2_1 .text "It's a standard 55-gallon drum.", 255
OBJECT_DESC2_2 .text "'AMMONIUM PERSULFATE NET WT 412 KG'", 255

BOOKSHELF_MESSAGE1 .text "Hey!", 255
BOOKSHELF_MESSAGE2 .text "Don't look in there.", 255

TEST_OBJECT_SCRIPT
    .byte $ff, $ff, OPCODE_TEXT_BOX, 0, 1, 21, 30, 1
    .word OBJECT_DESC, 0, 0, 0
    .byte 1, 0, OPCODE_RESET_TEXT_BOX, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

TEST_HAIR_BLEACH
    .byte $c0, 0, OPCODE_TEXT_BOX, 0, 1, 21, 30, 3
    .word OBJECT_DESC2_1, EMPTY_STRING, OBJECT_DESC2_2, 0
    .byte 1, 0, OPCODE_RESET_TEXT_BOX, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

TEST_REACT_TO_BOOKSHELF
    .byte 1, 0, OPCODE_SET_SPRITE_POS, 0, 1, 96, 152, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 1, 0, OPCODE_SET_SPRITE_FLAGS, 0, 1, $3a, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 8, 0, OPCODE_MOVE_SPRITE_Y, 0, 1, $ff, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte $20, 0, OPCODE_TEXT_BOX, 0, 7, 18, 4, 1
    .word BOOKSHELF_MESSAGE1, 0, 0, 0
    .byte 1, 0, OPCODE_RESET_TEXT_BOX, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 24, 0, OPCODE_MOVE_SPRITE_X, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 48, 0, OPCODE_MOVE_SPRITE_Y, 0, 1, $ff, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte $80, 0, OPCODE_TEXT_BOX, 0, 1, 21, 30, 1
    .word BOOKSHELF_MESSAGE2, 0, 0, 0
    .byte 1, 0, OPCODE_RESET_TEXT_BOX, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 32, 0, OPCODE_MOVE_SPRITE_Y, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 64, 0, OPCODE_MOVE_SPRITE_X, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 1, 0, OPCODE_SET_SPRITE_FLAGS, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

OBJECT_SCRIPTS .word TEST_OBJECT_SCRIPT, TEST_HAIR_BLEACH, TEST_REACT_TO_BOOKSHELF
OBJECT_SCRIPT_LENGTHS .word 2, 2, 12

load_sprite_byte_index .macro
    ; x = sprite_id * 2
    ldy #$4
    lda (script_element_ptr), y
    asl
    tax
.endm

; can eliminate some redundancy in the implementations of these
script_operations .word op_none, op_text_box, op_set_sprite_flags, op_set_sprite_position, op_move_sprite_x, op_move_sprite_y

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
    sty script_length
+   rts

; to run a script store its address in script_ptr and the number of elements in script_length
run_script
.al
.xl
    lda script_ptr
    bne +
    rts

+   lda script_step
    cmp script_length
    bne +
    stz script_ptr
    stz script_element_ptr
    stz script_length
    stz script_step
    stz script_step_start_frame
    rts

+   asl
    asl
    asl
    asl
    clc
    adc script_ptr
    sta script_element_ptr

    lda script_step_start_frame
    bne _check_next_step_conditions

    ; if 0, the step started on this frame, need to set the
    ; script_set_start_frame = current_frame
    lda frame_counter
    sta script_step_start_frame
    ; skip expiration checks because A button might still be set from
    ; interacting with an object to start this step!
    bra _run_step

    ; check for -1 length
_check_next_step_conditions
    lda (script_element_ptr)
    cmp #$ffff
    bne _check_time

    lda joypad_new
    bit #A_BUTTON
    bne _go_to_next_step
    bra _run_step

    ; not indeterminate
_check_time
    lda (script_element_ptr)
    clc
    adc script_step_start_frame
    cmp frame_counter
    bcs _run_step

_go_to_next_step
    ; if start + length >= frame_counter or duration == -1 and A pressed
    inc script_step
    stz script_step_start_frame
    rts

_run_step
    ldy #$2
    lda (script_element_ptr), y
    asl
    tax
    sep #$20
    jmp (script_operations, x)

op_none
    ; 0 = reset everything
    stz text_box_enabled
    rts

op_text_box
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
    #load_sprite_byte_index

    ldy #$5
    lda (script_element_ptr), y
    sta sprites_flag, x

    rts

op_set_sprite_position
    #load_sprite_byte_index

    ldy #$5
    lda (script_element_ptr), y
    sta sprites_x, x

    ldy #$6
    lda (script_element_ptr), y
    sta sprites_y, x

    rts

op_move_sprite_x
    #load_sprite_byte_index

    lda sprites_x, x
    ldy #$5
    clc
    adc (script_element_ptr), y
    sta sprites_x, x

    rts

op_move_sprite_y
    #load_sprite_byte_index

    lda sprites_y, x
    ldy #$5
    clc
    adc (script_element_ptr), y
    sta sprites_y, x

    rts
