; player_x, player_y are the center-bottom of the sprite in half-pixels
; to convert to top-left corner for rendering, subtract (16, 30) in half-pixels

PLAYER_ANIMATION_SPEED = 6
; in half pixels per frame
PLAYER_MOVEMENT_SPEED = 3
; half pixels to look ahead for script triggers
SCRIPT_TRIGGER_LOOKAHEAD = 8 << 1

PLAYER_DIRECTION_NONE = 0
PLAYER_DIRECTION_RIGHT = 1
PLAYER_DIRECTION_DOWN = 2
PLAYER_DIRECTION_LEFT = 3
PLAYER_DIRECTION_UP = 4

; OAM tile IDs for each 16x32 sprite slot (8 slots)
; slot N: top = 4*N, bottom = 4*N + 2
SPRITE_BASE_IDS_TOP .word $00, $04, $08, $0c, $10, $14, $18, $1c
SPRITE_BASE_IDS_BOTTOM .word $02, $06, $0a, $0e, $12, $16, $1a, $1e

MOVEMENT_JUMP_TABLE .addr go_right, go_down, go_left, go_up

PLAYER_OAM_FLAGS = $38

player_init
    php
    rep #$20

    ; set up OAM tile IDs for all 8 sprite slots
    lda #0
-   pha
    jsr set_sprite_id_16x32
    pla
    inc a
    cmp #NUM_SPRITE_SLOTS
    bne -

    ; set player OAM flags (priority 1, palette 4)
    sep #$20
    lda #PLAYER_OAM_FLAGS
    sta oam_data_flag
    sta oam_data_flag + 4
    rep #$20

    ; set player sprite data address (slot 0)
    lda #<>PLAYER_TILESET
    sta object_sprite_data
    lda #`PLAYER_TILESET
    sta object_sprite_data + 2

    inc player_locked

    ; enable objs on top layer with base address of $4000
    sep #$20
    lda #$62
    sta OBJSEL

    plp
    rts

; sets OAM slots for sprite id A to use the correct tile IDs
; hides the sprite (Y=$e0), flags default to 0
; caller should set flags separately
set_sprite_id_16x32
.xl
    php
    sep #$20
    asl ; to byte offset in sprite base ids table
    tax

    asl
    asl
    tay ; *2 again for dest offset in oam array, *2 because two sprites stacked up

    lda SPRITE_BASE_IDS_BOTTOM,x
    sta oam_data_id,y
    lda #0
    sta oam_data_flag,y
    lda #$e0
    sta oam_data_y,y
    iny
    iny
    iny
    iny
    lda SPRITE_BASE_IDS_TOP,x
    sta oam_data_id,y
    lda #0
    sta oam_data_flag,y
    lda #$e0
    sta oam_data_y,y

    plp
    rts

BIT_POSITIONS .byte $80, $40, $20, $10, $8, $4, $2, $1

; input: X = player X in pixels, Y = player Y in pixels
; checks collision at the player's feet position
check_collision_per_pixel
.al
.xl
    ; zp2 = playerX / 8
    txa
    pha
    srn 3
    sta zp2
    ; zp3 = playerX % 8
    pla
    and #7
    sta zp3

    ; calculate byte offset into image.
    ; 32 bytes per row for 256x256 maps, 64 for 512x512
    ; idx = playerY * bytes_per_row + zp2
    tya
    sln 5
    ldx current_map_size
    beq +
    asl
+   clc
    adc zp2
    tax
    lda @l collision_map,x
    and #$ff
    ldx zp3
    ; x offset within that byte
    and BIT_POSITIONS,x

    rts

; sets facing_object_script if the player is facing a tile that activates a script
; calls map_set_warp if the player is on a tile that warps
; parameters: X = player X in pixels, Y = player Y in pixels
; assumes: AXY 16
check_script_triggers
.al
.xl
    ; convert X to tile coordinate
    txa
    lsr
    lsr
    lsr
    lsr
    sta zp2

    ; convert Y to tile coordinate and multiply by map width
    ; ((y >> 4) << 4) == (y & $fff0)
    tya
    and #$fff0
    ldx current_map_size
    beq +
    ; extra << 1 for 32x32 maps
    asl

    ; y*width+x
+   clc
    adc zp2
    tay
    lda (script_trigger_map_ptr),y
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
    ora text_box_num_options
    beq +
    rts

    ; for 512x256 maps: if recently transitioned to the other section, wait
    ; for button up and then another button down before resuming movement, so
    ; the player doesn't just immediately transition sections again
+   lda map_transition_wait
    beq +
    lda joypad_new
    bit #(UP_BUTTON | DOWN_BUTTON | LEFT_BUTTON | RIGHT_BUTTON)
    bne +
    rts

+   stz map_transition_wait
    lda player_anim_direction
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
    clc
    adc object_sprite_data
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
    sta player_direction
    sln 7
    ; same as above but add $400 to skip to first frame
    clc
    adc object_sprite_data
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
    jmp (MOVEMENT_JUMP_TABLE - 2,x)

go_right
    lda player_x
    clc
    adc #PLAYER_MOVEMENT_SPEED
    ; is x + speed < max_x
    cmp current_map_max_player_x
    bcc +
    ; no, clamp to max x
    lda current_map_max_player_x
    sta player_x
    brl animate_player

    ; set up Y once for both checks (convert to pixels)
+   lda player_y
    lsr
    tay

    ; check script triggers with larger lookahead
    lda player_x
    clc
    adc #SCRIPT_TRIGGER_LOOKAHEAD
    cmp current_map_max_player_x
    bcc +
    lda current_map_max_player_x
+   lsr
    tax
    phx
    phy
    jsr check_script_triggers
    ply
    plx

    ; check collision at movement speed
    lda player_x
    clc
    adc #PLAYER_MOVEMENT_SPEED
    lsr
    tax
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
    ; is y + speed < max_y
    cmp current_map_max_player_y
    bmi +
    ; no, clamp to max y
    lda current_map_max_player_y
    sta player_y
    brl animate_player

    ; --- begin 512x256 bottom-of-screen transition - might not keep

    ; is this hub AND is the player walking past the transition point
+   lda current_map_scroll_flags
    and #4
    beq _no_split_map
    lda player_y
    sec
    sbc my_bgvofs
    sbc my_bgvofs
    clc
    adc #PLAYER_MOVEMENT_SPEED
    cmp #448
    bcc _no_split_map
    lda my_bgvofs
    eor #256
    sta my_bgvofs
    lda #416
    clc
    adc my_bgvofs
    adc my_bgvofs
    sta player_y
    ; flip sprite to face up (away from camera)
    lda #PLAYER_DIRECTION_UP
    sta player_anim_direction
    ; queue sprite data for facing up with current animation offset
    ; (PLAYER_DIRECTION_UP - 1) << 7 + player_anim_offset
    lda #PLAYER_DIRECTION_UP - 1
    sta player_direction
    sln 7
    clc
    adc object_sprite_data
    ldx #0
    jsr dma_queue_add
    inc map_transition_wait
    brl animate_player

    ; --- end 512x256 code

    ; set up X once for both checks (convert to pixels)
_no_split_map
    lda player_x
    lsr
    tax

    ; check script triggers with larger lookahead
    lda player_y
    clc
    adc #SCRIPT_TRIGGER_LOOKAHEAD
    cmp current_map_max_player_y
    bmi +
    lda current_map_max_player_y
+   lsr
    tay
    phx
    phy
    jsr check_script_triggers
    ply
    plx

    ; check collision at movement speed
    lda player_y
    clc
    adc #PLAYER_MOVEMENT_SPEED
    lsr
    tay
    jsr check_collision_per_pixel
    beq +

    lda player_y
    clc
    adc #PLAYER_MOVEMENT_SPEED
    sta player_y
+   brl animate_player

go_left
    ; check left edge of screen
    ; center must stay >= 16 half-pixels
    ; is x - speed >= 16?
    lda player_x
    sec
    sbc #PLAYER_MOVEMENT_SPEED
    cmp #16
    bpl +
    ; no, clamp
    lda #16
    sta player_x
    brl animate_player

    ; set up Y once for both checks (convert to pixels)
+   lda player_y
    lsr
    tay

    ; check script triggers with larger lookahead
    lda player_x
    sec
    sbc #SCRIPT_TRIGGER_LOOKAHEAD
    ; clamp to x=16 here
    cmp #16
    bpl +
    lda #16
+   lsr
    tax
    phx
    phy
    jsr check_script_triggers
    ply
    plx

    ; check collision at movement speed
    lda player_x
    sec
    sbc #PLAYER_MOVEMENT_SPEED
    lsr
    tax
    jsr check_collision_per_pixel
    beq +

    lda player_x
    sec
    sbc #PLAYER_MOVEMENT_SPEED
    sta player_x
+   bra animate_player

go_up
    ; check top edge of screen
    ; is y - speed >= 62?
    lda player_y
    sec
    sbc #PLAYER_MOVEMENT_SPEED
    cmp #$3e
    bpl +
    ; no, clamp
    lda #$3e
    sta player_y
    bra animate_player

    ; set up X once for both checks (convert to pixels)
+   lda player_x
    lsr
    tax

    ; check script triggers with larger lookahead
    lda player_y
    sec
    sbc #SCRIPT_TRIGGER_LOOKAHEAD
    cmp #$3e
    bpl +
    lda #$3e
+   lsr
    tay
    phx
    phy
    jsr check_script_triggers
    ply
    plx

    ; check collision at movement speed
    lda player_y
    sec
    sbc #PLAYER_MOVEMENT_SPEED
    lsr
    tay
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
    adc object_sprite_data
    adc player_anim_offset
    ldx #0
    jmp dma_queue_add

; X = sprite slot (0-7)
; X*2 indexes into 16-bit sprite arrays, Y = X*4 indexes into object_sprite_data
animate_sprite_v2
.al
.xl
    txa
    asl
    tax     ; X = sprite_id * 2
    asl
    tay     ; Y = sprite_id * 4

    lda sprites_anim_direction,x
    and #$ff
    bne _moving

    ; if direction = 0 try previous direction so it can set a final idle frame
    lda sprites_anim_previous_direction,x
    and #$ff
    bne _stopped

    ; current and prev direction both 0, nothing to do
    rts

_stopped
    stz sprites_anim_previous_direction,x
    ; set frame 0 for previous direction
    dec a
    sln 7
    clc
    adc object_sprite_data,y
    jmp dma_queue_add

_moving
    ; if it's not time to go to the next frame, exit
    inc sprites_anim_timer,x
    lda sprites_anim_timer,x
    cmp #PLAYER_ANIMATION_SPEED
    bpl +
    rts

    ; $400, $800, $c00, $1000, $1400, $1800, reset
+   stz sprites_anim_timer,x
    lda sprites_anim_offset,x
    clc
    adc #$400
    cmp #$1c00
    beq +
    sta sprites_anim_offset,x
    bra _go

+   lda #$400
    sta sprites_anim_offset,x

_go
    lda sprites_anim_direction,x
    dec a
    sln 7
    clc
    adc sprites_anim_offset,x
    adc object_sprite_data,y
    jmp dma_queue_add

animate_npcs
.al
.xl
    lda num_active_objects
    beq +
    ldx #1
-   phx
    jsr animate_sprite_v2
    plx
    cpx num_active_objects
    beq +
    inx
    bra -
+   rts

set_updated_player_pos
.al
.xl
    ; convert player_x (center, half-pixels) to sprite position (left edge, pixels)
    lda current_map_scroll_flags
    and #1
    beq _no_hscroll
    lda player_x
    lsr
    sec
    sbc #8  ; center to left edge
    sec
    sbc my_bghofs
    bra _set_x
_no_hscroll
    lda player_x
    lsr
    sec
    sbc #8  ; center to left edge
_set_x
    sep #$20
    sta player_x_sprite
    sta player_x_head_sprite
    rep #$20

    ; convert player_y (bottom, half-pixels) to sprite position (top of bottom sprite, pixels)
    lda current_map_scroll_flags
    ; both 'regular' vertical scroll and hub split-map scroll need this behavior
    and #(2 | 4)
    beq _no_vscroll
    lda player_y
    lsr
    sec
    sbc #15  ; bottom to top of bottom sprite
    sec
    sbc my_bgvofs
    bra _set_y
_no_vscroll
    lda player_y
    lsr
    sec
    sbc #15  ; bottom to top of bottom sprite
_set_y
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

; updates my_bghofs and my_bgvofs based on player position
; centers player on screen, clamped to map boundaries
; parameters: none
; returns: none
update_scroll
.xl
    php
    rep #$20

    lda current_map_scroll_flags
    beq _done

    bit #1
    beq _check_vertical

    ; scroll_x = (player_x >> 1) - 128
    lda player_x
    lsr
    sec
    sbc #128
    bpl +
    lda #0
+   cmp #256
    bmi +
    lda #256
+   sta my_bghofs

_check_vertical
    lda current_map_scroll_flags
    bit #2
    beq _done

    ; scroll_y = (player_y >> 1) - 127
    ; visual center is player_y - 15, screen center is 112
    lda player_y
    lsr
    sec
    sbc #127
    ; -1 vertical scroll is displayed as 0 bc of how rendering works
    cmp #-1
    bpl +
    lda #-1
    ; 287 is really 288
+   cmp #287
    bmi +
    lda #287
+   sta my_bgvofs

_done
    plp
    rts