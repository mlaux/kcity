B_BUTTON      = $8000
Y_BUTTON      = $4000
SELECT_BUTTON = $2000
START_BUTTON  = $1000
UP_BUTTON     = $0800
DOWN_BUTTON   = $0400
LEFT_BUTTON   = $0200
RIGHT_BUTTON  = $0100
A_BUTTON      = $80
X_BUTTON      = $40
L_BUTTON      = $20
R_BUTTON      = $10

read_input
.al
.xl
    ; https://snes.nesdev.org/wiki/Controller_reading
-   lda HBVJOY
    and #1
    bne -
    lda joypad_current
    sta joypad_last
    lda JOY1L
    sta joypad_current ; buttons currently pressed
    eor joypad_last
    and joypad_current
    sta joypad_new  ; buttons newly pressed this frame (0->1)

    ; if (A pressed && !script_ptr && facing_object_script)
    bit #A_BUTTON
    beq +
    lda script_ptr
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
    jmp save_game

+   bit #START_BUTTON
    beq +
    jmp load_game

+   rts