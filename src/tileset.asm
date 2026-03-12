TILEMAP_SIZE = $800
; backdrop color, text box colors, cursor, etc are in palette 0. map background
; palettes start at $10
PALETTE_OFFSET = $10
; juno is always $c0 (palette $c). map-defined palettes can be $d0, $e0, $f0
OBJ_PALETTE_OFFSET = $d0
TILEMAP_PALETTE_SIZE = $e0

mono_font_init
.xl
    php
    sep #$20
    ldx #DMAMODE_PPUDATA
    stx DMAMODE

    lda #$80
    sta VMAIN

    ; nice empty spot before the sprite data
    ldx #$3d00
    stx VMADD

    #dma_ppu_data GENEVA_CHARS

    ; ldx #$3c88
    ; stx VMADD

    ; #dma_ppu_data CPU_USAGE_TILES

    ldx #$3fd8 ; blank spot after 'z'
    stx VMADD

    #dma_ppu_data CURSOR_TILE

    plp
    rts

; copies 16x32 sprite frame to VRAM via DMA queue
; input: a - full 16-bit source address within bank
;        x - dest 16x32 sprite slot * 2
; AXY 16
dma_queue_add
.al
.xl
    pha
    lda dma_queue_length
    asl
    tay

    lda #DMAMODE_PPUDATA
    sta dma_queue_entry_mode,y
    sta dma_queue_entry_mode + 2,y
    lda #PLAYER_GRAPHICS_BANK
    sta dma_queue_entry_addr_bank,y
    sta dma_queue_entry_addr_bank + 2,y
    lda #$80
    sta dma_queue_entry_vmain,y
    sta dma_queue_entry_vmain + 2,y
    ; lda #$80
    sta dma_queue_entry_length,y
    sta dma_queue_entry_length + 2,y

    txa
    cmp #8
    ; skip over bottom row of 16x16 tile data
    bcc +
    clc
    adc #8
+   sln 5
    clc
    adc #$4000
    sta dma_queue_entry_vmadd,y
    adc #$100
    sta dma_queue_entry_vmadd + 2,y

    pla
    sta dma_queue_entry_addr,y
    clc
    adc #$200
    sta dma_queue_entry_addr + 2,y

    inc dma_queue_length
    inc dma_queue_length
    rts

dma_queue_run_vblank
    php
    rep #$20
.al
.xl
    lda dma_queue_length
    beq _done
    dec a
    asl
    tax

-   lda dma_queue_entry_mode,x
    sta DMAMODE
    lda dma_queue_entry_addr,x
    sta DMAADDR
    lda dma_queue_entry_length,x
    sta DMALEN
    lda dma_queue_entry_vmadd,x
    sta VMADD

    sep #$20
    lda dma_queue_entry_addr_bank,x
    sta DMAADDRBANK
    lda dma_queue_entry_vmain,x
    sta VMAIN
    lda #$1
    sta MDMAEN
    rep #$20

    dec dma_queue_length
    dex
    dex
    bpl -

_done
    plp
    rts

map_set_warp
.al
.xl
    sta target_warp_id
    inc player_locked
    jmp start_fade_out

map_run_warp
.al
.xl
    lda target_warp_id
    asl
    tax
    lda WARP_TARGET_MAPS - 2,X
    sta target_map_id
    lda WARP_TARGET_X - 2,x
    sta target_player_x
    lda WARP_TARGET_Y - 2,x
    sta target_player_y
    ; falls through

; loads map `target_map_id` and places the player at `target_player_x`/`target_player_y`
; with facing direction of `player_direction`
load_map
.al
.xl
    php

    ; turn the screen off
    sep #$20
    jsr enable_force_blank

    ; if HDMA is enabled it'll interfere with normal DMA on the same channel
    stz HDMAEN

    rep #$20
    lda #1
    sta text_box_hide_requested
    jsr clear_all_script_slots

    lda #DMAMODE_PPUDATA
    sta DMAMODE
    lda #TILEMAP_SIZE
    sta DMALEN
    stz VMADD

    lda target_player_x
    sta player_x
    lda target_player_y
    sta player_y
    lda player_direction
    sln 7
    clc
    adc object_sprite_data
    ldx #0
    jsr dma_queue_add

    ; get x set up with offset of this map's data in each array
    lda target_map_id
    sta current_map_id
    asl
    tax

    lda START_BGMODE - 2,x
    sta my_bgmode
    lda START_HOFS - 2,x
    sta my_bghofs
    lda START_VOFS - 2,x
    sta my_bgvofs

    lda ALL_TILEMAPS - 2,x
    sta DMAADDR
    lda ALL_MAP_BANKS - 2,x
    sep #$20
    sta DMAADDRBANK
    lda #$80
    sta VMAIN
    lda #1
    sta MDMAEN
    rep #$20

    lda ALL_TILESETS - 2,x
    sta DMAADDR
    lda ALL_TILESET_LENGTHS - 2,x
    sta DMALEN

    lda #$1000
    sta VMADD

    sep #$20
    lda #1
    sta MDMAEN
    rep #$20

    lda ALL_MAP_PALETTES - 2,x
    sta DMAADDR
    lda #TILEMAP_PALETTE_SIZE
    sta DMALEN
    lda #DMAMODE_CGDATA
    sta DMAMODE

    sep #$20
    lda #PALETTE_BANK
    sta DMAADDRBANK
    lda #PALETTE_OFFSET
    sta CGADD

    lda #1
    sta MDMAEN

    lda #0
    sta CGADD
    lda #$a0
    sta CGDATA
    lda #$14
    sta CGDATA
    rep #$20

    lda COLLISION_MAPS - 2,x
    sta zp1
    lda COLLISION_MAP_LENGTHS - 2,x
    sta zp2
    phx
    jsr decompress_collision_map
    plx
    lda SCRIPT_TRIGGER_MAPS - 2,x
    sta script_trigger_map_ptr

    lda MAP_SIZES - 2,x
    sta current_map_size

    lda MAP_SCROLL_FLAGS - 2,x
    sta current_map_scroll_flags

    lda MAP_MAX_PLAYER_X - 2,x
    sta current_map_max_player_x

    lda MAP_MAX_PLAYER_Y - 2,x
    sta current_map_max_player_y

    ; lda MAP_MAX_SCROLL_Y - 2,x
    ; sta current_map_max_scroll_y

    ; patch script that displays location names in memory to have
    ; the new location's name and start the script
    lda LOCATION_NAMES - 2,x
    sta location_name_script + 24
    phx
    ldx #<>location_name_script
    ldy #4
    jsr set_script
    plx

    lda current_map_scroll_flags
    ; special split 512x256px maps, if y >= 512 half pixels, set vscroll to 256
    bit #4
    beq +
    lda player_y
    cmp #512
    bcc +
    lda #256
    sta my_bgvofs

+   phx
    jsr init_map_objects
    plx
    jsr init_map_obj_palettes

    stz player_locked
    stz target_warp_id
    stz target_map_id
    stz target_player_x
    stz target_player_y

    plp
    rts

; initialize objects for the current map from MAP_OBJECTS table
; X = map_id * 2
; assumes: AXY 16
init_map_objects
.al
.xl
    lda MAP_OBJECTS - 2,x
    sta zp2

    stz num_active_objects

    ; hide sprite slots 1-7 (OAM bytes 8 through 63)
    sep #$20
    ldx #8
    lda #$e0
-   sta oam_data_y,x
    inx
    inx
    inx
    inx
    cpx #64
    bne -
    rep #$20

    lda (zp2)
    bne +
    jmp _done
+   sta num_active_objects

    stz zp3

_next_object
    ; zp1 = zp2 + 2 + zp3 * OBJECT_ENTRY_SIZE
    lda zp3
    asl
    asl
    asl
    asl
    clc
    adc zp2
    adc #2
    sta zp1

    ; X = object_index * 2 (for 16-bit object arrays)
    lda zp3
    asl
    tax

    ldy #0
    lda (zp1),y
    sta object_x,x
    ldy #2
    lda (zp1),y
    sta object_y,x
    ldy #8
    lda (zp1),y
    sta object_flags,x
    ldy #10
    lda (zp1),y
    sta object_interaction_script,x
    ldy #12
    lda (zp1),y
    sta object_bg_script,x
    ldy #14
    lda (zp1),y
    sta object_num_anim_frames,x

    ; initialize background script slot if this object has one
    lda object_bg_script,x
    beq _no_bg_script
    asl
    tax
    lda OBJECT_SCRIPTS - 2,x
    sta zp0
    lda OBJECT_SCRIPT_LENGTHS - 2,x
    pha
    ; slot = (object_index + 1) * 2
    lda zp3
    inc a
    asl
    tax
    lda zp0
    sta script_slot_ptr,x
    sta script_slot_element_ptr,x
    pla
    sta script_slot_length,x
    stz script_slot_step,x
    stz script_slot_result,x
    lda (zp0)
    sta script_slot_time_remaining,x
_no_bg_script

    ; sprite data -> object_sprite_data[sprite_slot * 4]
    ; sprite_slot = object_index + 1
    lda zp3
    inc a
    asl
    asl
    tax
    ldy #4
    lda (zp1),y
    sta object_sprite_data,x
    ldy #6
    lda (zp1),y
    sta object_sprite_data + 2,x

    ; set OAM flags for feet and head
    ; OAM offset = sprite_slot * 8
    lda zp3
    inc a
    asl
    asl
    asl
    tax
    ldy #8
    lda (zp1),y
    sep #$20
    sta oam_data_flag,x
    sta oam_data_flag + 4,x
    rep #$20

    ; queue initial sprite frame (facing down, idle)
    lda zp3
    inc a
    asl
    tax
    ldy #4
    lda (zp1),y
    clc
    adc #$80        ; (PLAYER_DIRECTION_DOWN - 1) << 7
    jsr dma_queue_add

    stz sprites_anim_offset,x
    stz sprites_anim_timer,x

    inc zp3
    lda zp3
    cmp num_active_objects
    beq +
    jmp _next_object

+   jsr set_updated_object_positions

_done
    rts

init_map_obj_palettes
.al
.xl
    lda MAP_OBJ_PALETTES - 2,x
    sta zp2
    lda (zp2)
    sta zp3
    bne +
    ; no obj palettes to load for this map
    rts

+   lda #DMAMODE_CGDATA
    sta DMAMODE
    sep #$20
    lda #PALETTE_BANK
    sta DMAADDRBANK
    lda #$d0
    sta CGADD
    rep #$20

    ldy #2
-   lda (zp2),y
    sta DMAADDR
    lda #$20
    sta DMALEN
    sep #$20
    lda #1
    sta MDMAEN
    rep #$20
    iny
    iny
    dec zp3
    bne -

    rts

; very basic RLE that only works well on 1-bit images with large areas of the
; same color
;     - 0x01 0x20 -> 0x20
;     - 0x05 0xff -> 0xff 0xff 0xff 0xff 0xff
;     - etc
; input: zp1 - address of compressed data
;        zp2 - length of compressed data
; uses: AXY, zp3
decompress_collision_map
.al
.xl
    ; output pointer
    ldx #0
    ; input pointer
    ldy #0

_next_set
    ; get number of times for this byte
    lda (zp1),y
    iny
    and #$ff
    sta zp3

    ; get the byte to write
    lda (zp1),y
    iny
    and #$ff

-   sta @l collision_map,x
    inx
    dec zp3
    bne -
    cpy zp2
    bne _next_set

    rts