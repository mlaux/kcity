
INITS .word state_title_init, state_gameplay_init, state_journal_init
STATES .word state_title, state_gameplay, state_journal
VBLANKS .word state_title_vblank, state_gameplay_vblank, state_journal_vblank

run_state_init
    php
.al
.xl
    sep #$20
    lda #$80
    sta INIDISP

    rep #$20

    lda game_state
    asl
    tax
    jsr (INITS, x)

    sep #$20

    plp
    rts
