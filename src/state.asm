STATE_ID_TITLE = 0
STATE_ID_FILE_SELECT = 1
STATE_ID_OPENING = 2
STATE_ID_GAMEPLAY = 3
STATE_ID_JOURNAL = 4

; all functions will be called with AXY16 and should return with AXY16
INITS
    .addr state_title_init
    .addr state_file_select_init
    .addr state_opening_init
    .addr state_gameplay_init
    .addr state_journal_init
STATES
    .addr state_title
    .addr state_file_select
    .addr state_opening
    .addr state_gameplay
    .addr state_journal
VBLANKS
    .addr state_title_vblank
    .addr state_file_select_vblank
    .addr state_opening_vblank
    .addr state_gameplay_vblank
    .addr state_journal_vblank

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

    inc state_transitioning

    rep #$20
    tya
    asl
    tax
    jsr (INITS,x)

    ply
    sty game_state
    dec state_transitioning

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
