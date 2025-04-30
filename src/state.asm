
INITS .word state_title_init, state_gameplay_init, state_journal_init
STATES .word state_title, state_gameplay, state_journal
VBLANKS .word state_title_vblank, state_gameplay_vblank, state_journal_vblank

; y: state to switch to
run_state_init
.xl
    php
    phy

    sep #$20
    lda #$80
    sta INIDISP

    rep #$20
    tya
    asl
    tax
    jsr (INITS, x)

    ply
    sty game_state

    plp
    rts

    ; plp
    ; ldx #$1fff
    ; txs
    ; jmp main_loop
    ; ; ldx #main_loop
    ; ; phx
    ; ; rts
