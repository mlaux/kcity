
state_title_init
.al
.xl
    rts

state_title
.al
.xl
    lda #1
    sta main_loop_done
-   wai
    lda main_loop_done
    bne -
    rts

state_title_vblank
.al
.xl
    rts
