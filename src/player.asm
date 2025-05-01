
PLAYER_SIZE = 16

PLAYER_ANIMATION_SPEED = 6
PLAYER_MOVEMENT_SPEED = 3 ; in half pixels per frame
SCALED_MAX_PLAYER_X = (SCREEN_WIDTH - PLAYER_SIZE) << 1
SCALED_MAX_PLAYER_Y = (SCREEN_HEIGHT - PLAYER_SIZE) << 1

PLAYER_DIRECTION_NONE = 0
PLAYER_DIRECTION_RIGHT = 1
PLAYER_DIRECTION_DOWN = 2
PLAYER_DIRECTION_LEFT = 3
PLAYER_DIRECTION_UP = 4

; hardcoding for each slot for now
SPRITE_BASE_IDS_FEET .word $2, $6
SPRITE_BASE_IDS_HEAD .word $0, $4
SPRITE_INITIAL_FLAGS .word $38, $0
SPRITE_ID_TO_DATA .word $0, $2000

MOVEMENT_JUMP_TABLE .word go_right, go_down, go_left, go_up

player_init
    php
    rep #$20

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

    plp
    rts

; sets OAM slots [a, a+1] to sprite ids [SPRITE_BASE_IDS_FEET[a], SPRITE_BASE_IDS_HEAD[a]]
; sets palette and visibility
set_sprite_id_16x32
.xl
    php
    sep #$20
    asl ; to byte offset in sprite base ids table
    tax

    asl
    asl
    tay ; *2 again for dest offset in oam array, *2 because two sprites stacked up

    lda SPRITE_BASE_IDS_FEET, x
    sta oam_data_id, y
    lda SPRITE_INITIAL_FLAGS, x
    sta oam_data_flag, y
    lda #$e0
    sta oam_data_y, y
    iny
    iny
    iny
    iny
    lda SPRITE_BASE_IDS_HEAD, x
    sta oam_data_id, y
    lda SPRITE_INITIAL_FLAGS, x
    sta oam_data_flag, y
    lda #$e0
    sta oam_data_y, y

    plp
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
    stz target_player_x
    bra _y

+   lda START_X - 2, x
    sta player_x

_y
    lda target_player_y
    beq +
    sta player_y
    stz target_player_y
    bra _done

+   lda START_Y - 2, x
    sta player_y

_done
    plp
    rts

BIT_POSITIONS .byte $80, $40, $20, $10, $8, $4, $2, $1

check_collision_per_pixel
.al
.xl
    ; zp2 = (playerX + 8) / 8
    txa
    clc
    adc #PLAYER_SIZE >> 1
    pha
    srn 3
    sta zp2
    ; zp3 = (playerX + 8) % 8
    pla
    and #7
    sta zp3

    ; calculate byte offset into image. 32 bytes per row
    ; idx = (playerY + 15) * 32 + zp2
    tya
    clc
    adc #PLAYER_SIZE - 1
    sln 5
    clc
    adc zp2
    tax
    lda @l collision_map, x
    and #$ff
    ldx zp3
    ; x offset within that byte
    and BIT_POSITIONS, x

    rts

; sets facing_object_script if the player is facing a tile that activates a script
; calls map_set_warp if the player is on a tile that warps
; parameters: X = player X in pixel coordinates, Y = player Y (top left corner)
; assumes: AXY 16
check_script_triggers
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
    lda (script_trigger_map_ptr), y
    bit #$80
    beq +
    and #$7f
    jmp map_set_warp

+   bit #$40
    beq +
    and #$3f
    asl
    sta facing_object_script
    rts

+   stz facing_object_script
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

+   lda player_anim_direction
    sta player_anim_previous_direction
    stz player_anim_direction

    lda joypad_current

    ; check each direction, directions that are checked later override directions
    ; that are checked first. i checked some popular SNES RPGs and this behavior seems fine

    bit #RIGHT_BUTTON
    beq +
    ldx #PLAYER_DIRECTION_RIGHT
    stx player_anim_direction

+   bit #DOWN_BUTTON
    beq +
    ldx #PLAYER_DIRECTION_DOWN
    stx player_anim_direction

+   bit #LEFT_BUTTON
    beq +
    ldx #PLAYER_DIRECTION_LEFT
    stx player_anim_direction

+   bit #UP_BUTTON
    beq +
    ldx #PLAYER_DIRECTION_UP
    stx player_anim_direction

+   lda player_anim_direction
    eor player_anim_previous_direction
    ; if same as before, just go straight to processing the input
    beq _process_movement

    ; different than before, need to jump to a specific animation frame
    lda player_anim_direction
    bne _starting_to_move

    ; n -> 0
    ; not moving now but was moving before - skip to first animation frame (idle)
    lda player_anim_previous_direction

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
    lda player_anim_direction
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
    lda player_x
    clc
    adc #PLAYER_MOVEMENT_SPEED
    ; would moving take you off the screen?
    cmp #SCALED_MAX_PLAYER_X
    bmi +
    ; yep, clamp to max x
    lda #SCALED_MAX_PLAYER_X
    sta player_x
    brl animate_player

    ; drop half pixel to check map
    ; check pixel at (x + speed, y)
+   lsr
    tax
    lda player_y
    lsr
    tay
    phx
    phy
    jsr check_script_triggers
    ply
    plx
    jsr check_collision_per_pixel
    beq +

    lda player_x
    clc
    adc #PLAYER_MOVEMENT_SPEED
    sta player_x
+   brl animate_player

go_down
    lda player_y
    clc
    adc #PLAYER_MOVEMENT_SPEED
    ; would moving take you off the screen?
    cmp #SCALED_MAX_PLAYER_Y
    bmi +
    ; clamp to max y
    lda #SCALED_MAX_PLAYER_Y
    sta player_y
    brl animate_player

    ; check pixel at (x, y + speed)
+   lsr
    tay
    lda player_x
    lsr
    tax
    phx
    phy
    jsr check_script_triggers
    ply
    plx
    jsr check_collision_per_pixel
    beq +

    lda player_y
    clc
    adc #PLAYER_MOVEMENT_SPEED
    sta player_y
    ; inc player_y_head
+   bra animate_player

go_left
    ; check left edge of screen
    lda player_x
    sec
    sbc #PLAYER_MOVEMENT_SPEED
    bpl +
    lda #0
    sta player_x
    bra animate_player

    ; check pixel at (x - speed, y)
+   lsr
    tax
    lda player_y
    lsr
    tay
    phx
    phy
    jsr check_script_triggers
    ply
    plx
    jsr check_collision_per_pixel
    beq +

    lda player_x
    sec
    sbc #PLAYER_MOVEMENT_SPEED
    sta player_x
+   bra animate_player

go_up
    ; check top edge of screen
    lda player_y
    sec
    sbc #PLAYER_MOVEMENT_SPEED
    bpl +
    lda #0
    sta player_y
    bra animate_player

    ; check pixel at (x, y - speed)
+   lsr
    tay
    lda player_x
    lsr
    tax
    phx
    phy
    jsr check_script_triggers
    ply
    plx
    jsr check_collision_per_pixel
    beq animate_player

    lda player_y
    sec
    sbc #PLAYER_MOVEMENT_SPEED
    sta player_y

animate_player
    ; if it's not time to go to the next frame, exit
    inc player_anim_timer
    lda player_anim_timer
    cmp #PLAYER_ANIMATION_SPEED
    bpl +
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
    lda player_anim_direction
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

    lda sprites_anim_direction, x
    and #$ff
    bne _moving

    ; if direction = 0 try previous direction so it can set a final idle frame
    lda sprites_anim_previous_direction, x
    and #$ff
    bne _stopped

    ; current and prev direction both 0, nothing to do
    rts

_stopped
    stz sprites_anim_previous_direction, x
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
    bpl +
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
    sta sprites_anim_offset, x

_go
    lda sprites_anim_direction, x
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

set_updated_player_pos
.al
.xl
    lda player_x
    lsr
    sep #$20
    sta player_x_sprite
    sta player_x_head_sprite
    rep #$20
    lda player_y
    lsr
    sep #$20
    sta player_y_sprite
    sec
    sbc #$10
    sta player_y_head_sprite
    rep #$20
    rts

; send over the updated data calculated by move_player
; parameters: none
; returns: none
; assumes: A8, XY16
vblank_oam_dma
.as
.xl
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