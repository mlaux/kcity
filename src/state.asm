
INITS .word state_title_init, state_gameplay_init, state_journal_init
STATES .word state_title, state_gameplay, state_journal
VBLANKS .word state_title_vblank, state_gameplay_vblank, state_journal_vblank

run_state_init
.as
.xl
    lda #$80
    sta INIDISP
    lda #0
    sta NMITIMEN

    rep #$20

    lda game_state
    asl
    tax
    jsr (INITS, x)

    ; initialization done, enable interrupts and auto joypad reading
    sep #$20
    lda #$81
    sta NMITIMEN

    rts
