; ANDed with the frame counter to decide whether to go to the next frame, should be 2^n - 1
PLAYER_ANIMATION_SPEED = 15

PLAYER_DIRECTION_NONE = 0
PLAYER_DIRECTION_RIGHT = 1
PLAYER_DIRECTION_DOWN = 2
PLAYER_DIRECTION_LEFT = 3
PLAYER_DIRECTION_UP = 4

PLAYER_SIZE = 16

; hardcoding for each slot for now
SPRITE_BASE_IDS_FEET .word $2, $6
SPRITE_BASE_IDS_HEAD .word $0, $4
SPRITE_INITIAL_FLAGS .word $38, $0
SPRITE_ID_TO_DATA .word $0, $2000

MOVEMENT_JUMP_TABLE .word go_right, go_down, go_left, go_up

player_init
.al
.xl
    ; send first frame's tile data
    lda #0
    ldx #0
    jsr dma_queue_add

    lda #0
    jsr set_sprite_id_16x32
    lda #1
    jsr set_sprite_id_16x32

    inc player_locked

    ; enable objs on top layer with base address of $4000
    sep #$20
    lda #$62
    sta OBJSEL
    rep #$20

    rts

; sets OAM slots [a, a+1] to sprite ids [SPRITE_BASE_IDS_FEET[a], SPRITE_BASE_IDS_HEAD[a]]
; sets palette and visibility
set_sprite_id_16x32
.al
.xl
    asl ; to byte offset in sprite base ids table
    tax
    asl
    tay ; to dest offset in sprites_id array

    lda SPRITE_BASE_IDS_FEET, x
    sta sprites_id, y
    lda SPRITE_INITIAL_FLAGS, x
    sta sprites_flag, y
    iny
    iny
    lda SPRITE_BASE_IDS_HEAD, x
    sta sprites_id, y
    lda SPRITE_INITIAL_FLAGS, x
    sta sprites_flag, y
    rts

; if target_player_x/y are set, sets the position to that
; otherwise sets to the initial position for the map
; parameters: X = offset of this map's data in map data arrays (map id << 1)
player_set_initial_position
.al
.xl
    php
    rep #$20

    lda target_player_x
    beq +
    sta player_x
    sta player_x_head
    stz target_player_x
    bra _y

+   lda START_X - 2, x
    sta player_x
    sta player_x_head

_y
    lda target_player_y
    beq +
    sta player_y
    sec
    sbc #$10
    sta player_y_head
    stz target_player_y
    bra _done

+   lda START_Y - 2, x
    sta player_y
    sec
    sbc #$10
    sta player_y_head

_done
    plp
    rts

; returns: A = 1 if walking to the tile at the given coordinates is permitted, 0 otherwise
; parameters: X = player X in pixel coordinates, Y = player Y (top left corner)
; assumes: AXY 16
check_tilemap_collision
.al
.xl
    txa
    ; want to check middle of player, not top left
    clc
    adc #PLAYER_SIZE >> 1
    lsr
    lsr
    lsr
    lsr
    sta zp2

    tya
    clc
    adc #PLAYER_SIZE >> 1

    ; lsr lsr lsr lsr, asl asl asl asl
    and #$f0

    ; y*width+x
    clc
    adc zp2
    tay
    lda (collision_map_ptr), y
    bit #$80
    beq +
    and #$7f
    jmp map_set_warp

+   bit #$40
    beq +
    and #$3f
    asl
    sta facing_object_script
    lda #0
    rts

+   and #$ff
    stz facing_object_script
    rts


; reads input, moves the player, and animates if necessary. call from the main loop
; parameters: none
; returns: none
; assumes: AXY 16
move_player
.al
.xl
    lda player_locked
    beq +
    rts

+   lda player_direction
    sta player_previous_direction
    stz player_direction

    lda joypad_current

    ; check each direction, directions that are checked later override directions
    ; that are checked first. i checked some popular SNES RPGs and this behavior seems fine

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

    ; n -> 0
    ; not moving now but was moving before - skip to first animation frame (idle)
    lda player_previous_direction

    ; (direction - 1) << 7 = offset in tile data for frame 0
    dec a
    sln 7
    ldx #0
    jsr dma_queue_add
    stz player_anim_offset
    stz player_anim_timer

    ; done
    rts

    ; 0 -> n, n -> m
    ; was not moving before, but is now, or changed direction
    ; skip to second animation frame (stepping forward)
_starting_to_move
    dec a
    sln 7
    ; same as above but add $400 to skip to first frame
    clc
    adc #$400
    ldx #0
    jsr dma_queue_add

    lda #$400
    sta player_anim_offset
    stz player_anim_timer

_process_movement
    lda player_direction
    bne +
    ; not moving now, not moving before, done
    ; 0 -> 0
    rts

    ; continue moving in same direction
    ; n -> n
+   asl
    tax
    ; MOVEMENT_JUMP_TABLE[(player_direction - 1) << 1]()
    jmp (MOVEMENT_JUMP_TABLE - 2, x)

go_right
    ldx player_x
    cpx #SCREEN_WIDTH - PLAYER_SIZE
    bne +
    bra animate_player

    ; check tile at (x + 1, y)
+   inx
    ldy player_y
    jsr check_tilemap_collision
    beq +

    inc player_x
    inc player_x_head
+   bra animate_player

go_down
    ldy player_y
    cpy #SCREEN_HEIGHT - PLAYER_SIZE
    bne +
    bra animate_player

    ; check tile at (x, y + 1)
+   iny
    ldx player_x
    jsr check_tilemap_collision
    beq +

    inc player_y
    inc player_y_head
+   bra animate_player

go_left
    ; check left edge of screen
    ldx player_x
    bne +
    bra animate_player

    ; check tile at (x - 1, y)
+   dex
    ldy player_y
    jsr check_tilemap_collision
    beq +

    dec player_x
    dec player_x_head
+   bra animate_player

go_up
    ldy player_y
    bne +
    bra animate_player

    ; check tile at (x, y - 1)
+   dey
    ldx player_x
    jsr check_tilemap_collision
    beq animate_player

    dec player_y
    dec player_y_head

animate_player
    ; if it's not time to go to the next frame, exit
    inc player_anim_timer
    lda player_anim_timer
    cmp #PLAYER_ANIMATION_SPEED
    beq +
    rts

    ; $400, $800, $c00, $1000, $1400, $1800, reset
+   stz player_anim_timer
    lda player_anim_offset
    clc
    adc #$400
    cmp #$1c00
    beq +
    sta player_anim_offset
    bra _go

+   lda #$400
    sta player_anim_offset

_go
    lda player_direction
    dec a
    sln 7
    clc
    adc player_anim_offset
    ldx #0
    jmp dma_queue_add

animate_sprite_v2
.al
.xl
    txa
    asl
    tax

    lda sprites_direction, x
    and #$ff
    bne _moving

    ; if direction = 0 try previous direction so it can set a final idle frame
    lda sprites_previous_direction, x
    and #$ff
    bne _stopped

    ; current and prev direction both 0, nothing to do
    rts

_stopped
    stz sprites_previous_direction, x
    ; set frame 0 for previous direction
    dec a
    sln 7
    clc
    adc SPRITE_ID_TO_DATA, x
    jmp dma_queue_add

_moving
    ; if it's not time to go to the next frame, exit
    inc sprites_anim_timer, x
    lda sprites_anim_timer, x
    cmp #PLAYER_ANIMATION_SPEED
    beq +
    rts

;     ; $400, $800, $c00, $1000, $1400, $1800, reset
+   stz sprites_anim_timer, x
    lda sprites_anim_offset, x
    clc
    adc #$400
    cmp #$1c00
    beq +
    sta sprites_anim_offset, x
    bra _go

+   lda #$400
    sta player_anim_offset

_go
    lda sprites_direction, x
    dec a
    sln 7
    clc
    adc sprites_anim_offset, x
    adc SPRITE_ID_TO_DATA, x
    jmp dma_queue_add

animate_npcs
.al
.xl
    ldx #1
    jmp animate_sprite_v2

; send over the updated data calculated by move_player
; parameters: none
; returns: none
; assumes: A8, XY16
vblank_oam_dma
.as
.xl
    ; this whole copy can go away once i change some 16-bit writes to 8-bit
    ; then data can go directly into the oam_data_main instead_of the sprite_*

    ; source
    ldx #2 * NUM_OAM_ENTRIES - 2
    ; destination
    ldy #4 * NUM_OAM_ENTRIES - 1
-   lda sprites_flag, x
    sta oam_data_main, y
    dey
    lda sprites_id, x
    sta oam_data_main, y
    dey
    lda sprites_y, x
    sta oam_data_main, y
    dey
    lda sprites_x, x
    sta oam_data_main, y
    dey
    dex
    dex
    bpl -

    ldx #0
    stx OAMADD
    ldx #DMAMODE_OAMDATA
    stx DMAMODE
    ldx #<>oam_data_main
    stx DMAADDR
    lda #`oam_data_main
    sta DMAADDRBANK
    lda #OAM_MAIN_LENGTH
    sta DMALEN
    lda #1
    sta MDMAEN
    
    rts