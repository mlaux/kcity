
PLAYER_PALETTE .binary "../experimental_gfx/player.palette"
PLAYER_TILESET .binary "../experimental_gfx/player.tiles"

PLAYER_ANIMATION_SPEED = 7
PLAYER_SPLITE_TABLE .byte $c, $e, $20, $e, $0, $2, $4, $2, $6, $8, $a, $8, $22, $24, $26, $24

PLAYER_DIRECTION_NONE = 0
PLAYER_DIRECTION_RIGHT = 1
PLAYER_DIRECTION_DOWN = 2
PLAYER_DIRECTION_LEFT = 3
PLAYER_DIRECTION_UP = 4

MOVEMENT_JUMP_TABLE .word go_right, go_down, go_left, go_up

move_player
.al
.xl
    lda player_direction
    sta player_previous_direction
    stz player_direction

    lda joypad_current

    bit #RIGHT_BUTTON
    beq +
    ldx #PLAYER_DIRECTION_RIGHT
    stx player_direction

+   bit #DOWN_BUTTON
    beq +
    ldx #PLAYER_DIRECTION_DOWN
    stx player_direction

+   bit #LEFT_BUTTON
    beq +
    ldx #PLAYER_DIRECTION_LEFT
    stx player_direction

+   bit #UP_BUTTON
    beq +
    ldx #PLAYER_DIRECTION_UP
    stx player_direction

+   lda player_direction
    bne _moving_now
    eor player_previous_direction
    bne _was_moving_before_but_not_now

    ; not moving now, not moving before
    rts

_was_moving_before_but_not_now
    lda player_previous_direction
    dec a
    asl
    asl
    inc a
    tax
    lda PLAYER_SPLITE_TABLE, x
    and #$ff
    sta player_sprite_id
    lda #$1
    sta player_animation_index
    rts

_moving_now
    eor player_previous_direction
    beq _moving_now_and_was_moving_before

    ; was not moving before, but is now
    lda player_direction
    dec a
    asl
    asl
    tax
    lda PLAYER_SPLITE_TABLE, x
    and #$ff
    sta player_sprite_id
    stz player_animation_index


_moving_now_and_was_moving_before
    lda player_direction
    dec a
    asl
    tax
    jmp (MOVEMENT_JUMP_TABLE, x)

go_right
    inc player_x
    bra animate_player
go_down
    inc player_y
    bra animate_player
go_left
    dec player_x
    bra animate_player
go_up
    dec player_y
    bra animate_player

animate_player
    lda frame_counter
    and #PLAYER_ANIMATION_SPEED
    bne +

    lda player_direction
    and #$ff
    dec a
    asl
    asl
    clc
    adc player_animation_index
    tax
    lda PLAYER_SPLITE_TABLE, x
    and #$ff
    sta player_sprite_id

    lda player_animation_index
    inc a
    and #$3
    sta player_animation_index

+   rts