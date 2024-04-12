; each element is 16 bytes long (1 timing word, 1 opcode word, and 12 data bytes)
; - number of frames to wait before continuing (-1 = wait for A button)
; - opcode
; - 12 bytes depending on the type of element

; script opcode
; $0: nop
; $1: show text box

; for text boxes:
; x: byte
; y: byte
; w: byte
; number of lines (1-4): byte
; 4x line pointers (empty slot = 0)
; height is always 2 + num lines

script_element_t .struct len, op
    frame_length .word \len
    opcode .word \op
    params .fill 12
.endstruct

TEST_SCRIPT
    .byte   10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; do nothing for 10 frames

    .byte 200, 0, 1, 0, 20, 20, 150, 1 ; text box for 200 frames at (20, 20), width=150, lines=1
    .word TEST_CHAR, 0, 0, 0 ; line pointers for text box

    .byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ; reset

script_operations .word op_none, op_text_box

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
    rts

+   asl
    asl
    asl
    asl
    clc
    adc script_ptr
    sta script_element_ptr

    lda script_step_start_frame

    ; if 0, the step started on this frame
    bne +
    lda frame_counter
    sta script_step_start_frame

+   clc
    adc (script_element_ptr)
    cmp frame_counter

    ; if start + length >= frame_counter
    bcs +
    inc script_step
    stz script_step_start_frame
    rts

+   ldy #$2
    lda (script_element_ptr), y
;    bne +

+   asl
    tax
    jmp (script_operations, x)

op_none
    ; 0 = reset everything
    stz text_box_enabled
    rts

op_text_box
    lda #$1
    sta text_box_enabled
    jsr update_text
    rts