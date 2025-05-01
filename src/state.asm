
; all functions will be called with AXY16 and should return with AXY16
INITS
    .word state_title_init
    .word state_gameplay_init
    .word state_journal_init
STATES
    .word state_title
    .word state_gameplay
    .word state_journal
VBLANKS
    .word state_title_vblank
    .word state_gameplay_vblank
    .word state_journal_vblank

; turns rendering off and runs the state init function for the given state,
; then sets the game_state to the new value. this does not immediately start
; execution of the new state until the next time through the main loop -
; this is so that the old state can do more cleanup or busy wait for a
; transition animation to finish after the new state is ready to go.
;   parameters:
;     y: state to switch to
;   assumes:
;     X16
run_state_init
.xl
    php
    phy ; init function could use y

    sep #$20
    lda #$80
    sta my_inidisp
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

; discards the call stack and returns to the top of the main loop to start
; execution of the new state. Inspired by "goto mode" from NESFab
;   parameters: none
;   assumes: X16
longjmp_main
.xl
    ldx #$1fff
    txs
    sep #$20 ; expected by main_loop
    jmp main_loop
