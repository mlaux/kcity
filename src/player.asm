
PLAYER_PALETTE .binary "../experimental_gfx/player.palette"
PLAYER_TILESET .binary "../experimental_gfx/player.tiles"

PLAYER_ANIMATION_SPEED = 7
PLAYER_SPLITE_TABLE .byte $c, $e, $20, $e, $0, $2, $4, $2, $6, $8, $a, $8, $22, $24, $26, $24

PLAYER_DIRECTION_NONE = 0
PLAYER_DIRECTION_RIGHT = 1
PLAYER_DIRECTION_DOWN = 2
PLAYER_DIRECTION_LEFT = 3
PLAYER_DIRECTION_UP = 4

PLAYER_SIZE = 16

MOVEMENT_JUMP_TABLE .word go_right, go_down, go_left, go_up

; 1 ok, 0 NG
TEST_COLLISION_MAP .byte 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1
                   .byte 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1
                   .byte 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1
                   .byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
                   .byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
                   .byte 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1
                   .byte 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1
                   .byte 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1
                   .byte 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1
                   .byte 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1
                   .byte 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1
                   .byte 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1
                   .byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1
                   .byte 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1

; filler for other tiles
.fill $20

player_oam_update
.as
.xl
    ldx #$0
    stx OAMADD
    lda player_x
    sta OAMDATA
    lda player_y
    sta OAMDATA
    lda player_sprite_id
    sta OAMDATA
    lda #$38
    sta OAMDATA
    rts

; parameters: X = player X, Y = player Y
; returns: A = 1 if walking is permitted, 0 otherwise
check_tilemap_collision
.al
.xl
    txa
    ; clc
    ; adc #PLAYER_SIZE >> 1
    lsr
    lsr
    lsr
    lsr
    sta zp1

    tya
    ; clc
    ; adc #PLAYER_SIZE >> 1

    ; lsr lsr lsr lsr, asl asl asl asl
    and #$f0
    ; for debugging
    sta zp2

    ; y*width+x
    clc
    adc zp1
    sta zp3
    tax
    lda TEST_COLLISION_MAP, x
    and #$ff
    rts

move_player
.al
.xl
    lda player_x
    lsr
    lsr
    lsr
    lsr
    sta player_tile_x

    lda player_y
    lsr
    lsr
    lsr
    lsr
    sta player_tile_y

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
    eor player_previous_direction
    ; if same as before, just go straight to processing the input
    beq _process_movement

    ; different than before, need to jump to a specific animation frame
    lda player_direction
    bne _starting_to_move

    ; 1 -> 0
    ; not moving now but was moving before - skip to second animation frame (idle)
    lda player_previous_direction
    dec a
    asl
    asl
    inc a ; frame 1
    tax
    lda PLAYER_SPLITE_TABLE, x
    and #$ff
    sta player_sprite_id
    lda #$1
    sta player_animation_index

    rts

    ; 0 -> 1
    ; was not moving before, but is now, or changed direction
    ; skip to first animation frame (step)
_starting_to_move
    dec a
    asl
    asl
    tax
    lda PLAYER_SPLITE_TABLE, x
    and #$ff
    sta player_sprite_id
    stz player_animation_index

_process_movement
    lda player_direction
    bne +
    ; 0 -> 0
    rts

    ; 1 -> 1
+   dec a
    asl
    tax
    jmp (MOVEMENT_JUMP_TABLE, x)

go_right
    lda player_x
    cmp #SCREEN_WIDTH - PLAYER_SIZE
    bne +
    bra animate_player

    ; check tile at (x + player size + 1, y + playersize / 2)
+   clc
    adc #PLAYER_SIZE + 1
    tax
    lda player_y
    clc
    adc #PLAYER_SIZE >> 1
    tay
    jsr check_tilemap_collision
    bne +
    bra animate_player

+   inc player_x
    bra animate_player
go_down
    lda player_y
    cmp #SCREEN_HEIGHT - PLAYER_SIZE
    bne +
    bra animate_player

    ; check tile at (x + playersize / 2, y + player size + 1)
+   clc
    adc #PLAYER_SIZE + 1
    tay
    lda player_x
    clc
    adc #PLAYER_SIZE >> 1
    tax
    jsr check_tilemap_collision
    bne +
    bra animate_player

+   inc player_y
    bra animate_player
go_left
    ; check left edge of screen
    ldx player_x
    bne +
    bra animate_player

    ; check tile at (x - 1, y + playersize / 2)
+   dex
    lda player_y
    clc
    adc #PLAYER_SIZE >> 1
    tay
    jsr check_tilemap_collision
    bne +
    bra animate_player

+   dec player_x
    bra animate_player
go_up
    ldy player_y
    bne +
    bra animate_player

    ; check tile at (x + playersize / 2, y - 1)
+   dey
    lda player_x
    clc
    adc #PLAYER_SIZE >> 1
    tax
    jsr check_tilemap_collision
    bne +
    bra animate_player

+   dec player_y
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