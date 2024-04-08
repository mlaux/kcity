UP_BUTTON       = $0800
DOWN_BUTTON     = $0400
LEFT_BUTTON     = $0200
RIGHT_BUTTON    = $0100

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

    rts