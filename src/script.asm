; each element is 16 bytes long (1 timing byte, 1 opcode byte, and 14 data bytes)
; - number of frames to wait before continuing (-1 = wait for A button)
; - opcode
; - 14 bytes depending on the type of element

; script opcode
; $0: nop
; $1: show text box

; for text boxes:
; x: byte
; y: byte
; w: byte
; byte number of lines (1-4)
; 4x line pointers (empty slot = 0)
; height is always 2 + num lines

TEST_SCRIPT .word 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

script_operations .word op_none, op_text_box

; to run a script store its address in script_ptr and the number of elements in script_length
activate_script
.as
.xl
    lda frame_counter
    rts

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
    bne +
    lda frame_counter
    sta script_step_start_frame

+   clc
    adc (script_element_ptr)
    cmp frame_counter
    ; if start + length > frame_counter
    beq +
    bcs +
    inc script_step
    lda frame_counter
    sta script_step_start_frame
    rts

+   ldy #$2
    lda (script_element_ptr), y
    asl
    tax
    jmp (script_operations, x)

op_none
    rts

op_text_box
    rts