TILEMAP_SIZE = $800
PALETTE_OFFSET = $10
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

    ldx #$3c88
    stx VMADD

    #dma_ppu_data CPU_USAGE_TILES

    ldx #$3fd8 ; blank spot after 'z'
    stx VMADD

    #dma_ppu_data CURSOR_TILE

    plp
    rts

; copies 16x32 sprite in tileset to video ram 
; no idea what i'm doing but i need to implement this or i'll run out of
; tile IDs with just a few characters on screen
; input: a - base address of 16x32 sprite data
;        x - dest 16x32 sprite id
; AXY 16

; (frame * 0x400) + (direction * 0x80) for the top half of the sprite
; and that plus 0x200 for the bottom half
dma_queue_add
.al
.xl
    pha
    lda dma_queue_length
    asl
    tay

    lda #DMAMODE_PPUDATA
    sta dma_queue_entry_mode, y
    sta dma_queue_entry_mode + 2, y
    lda #PLAYER_GRAPHICS_BANK
    sta dma_queue_entry_addr_bank, y
    sta dma_queue_entry_addr_bank + 2, y
    lda #$80
    sta dma_queue_entry_vmain, y
    sta dma_queue_entry_vmain + 2, y
    ; lda #$80
    sta dma_queue_entry_length, y
    sta dma_queue_entry_length + 2, y

    txa
    sln 5
    clc
    adc #$4000
    sta dma_queue_entry_vmadd, y
    adc #$100
    sta dma_queue_entry_vmadd + 2, y

    pla
    clc
    adc #<>PLAYER_TILESET
    sta dma_queue_entry_addr, y
    adc #$200
    sta dma_queue_entry_addr + 2, y

    inc dma_queue_length
    inc dma_queue_length
    rts

dma_queue_run_vblank
.al
.xl
    php
    rep #$20
    lda dma_queue_length
    beq _done
    dec a
    asl
    tax

-   lda dma_queue_entry_mode, x
    sta DMAMODE
    lda dma_queue_entry_addr, x
    sta DMAADDR
    lda dma_queue_entry_length, x
    sta DMALEN
    lda dma_queue_entry_vmadd, x
    sta VMADD

    sep #$20
    lda dma_queue_entry_addr_bank, x
    sta DMAADDRBANK
    lda dma_queue_entry_vmain, x
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
    sta target_warp_map
    inc player_locked
    jmp start_fade_out

; i can't tell if this is janky or good
map_run_warp
.al
.xl
    php

    ; turn the screen off
    sep #$20
    jsr enable_force_blank

    lda #$80
    sta VMAIN
    lda #MAP_GRAPHICS_BANK
    sta DMAADDRBANK

    ; if HDMA is enabled it'll interfere with normal DMA on the same channel
    stz HDMAEN

    rep #$20
    lda #DMAMODE_PPUDATA
    sta DMAMODE

    ; get x set up with offset of this map's data in each array
    lda target_warp_map
    sta current_map_id
    stz target_warp_map
    and #$ff
    asl
    tax

    lda START_BGMODE - 2, x
    sta my_bgmode
    lda START_HOFS - 2, x
    sta my_bghofs
    lda START_VOFS - 2, x
    sta my_bgvofs

    lda ALL_TILEMAPS - 2, x
    sta DMAADDR
    lda #TILEMAP_SIZE
    sta DMALEN

    stz VMADD

    sep #$20
    lda #1
    sta MDMAEN
    rep #$20

    lda ALL_TILESETS - 2, x
    sta DMAADDR
    lda ALL_TILESET_LENGTHS - 2, x
    sta DMALEN

    lda #$1000
    sta VMADD

    sep #$20
    lda #1
    sta MDMAEN
    rep #$20

    lda ALL_MAP_PALETTES - 2, x
    sta DMAADDR
    lda #TILEMAP_PALETTE_SIZE
    sta DMALEN
    lda #DMAMODE_CGDATA
    sta DMAMODE

    lda COLLISION_MAPS - 2, x
    sta zp1
    lda COLLISION_MAP_LENGTHS - 2, x
    sta zp2
    phx
    jsr decompress_collision_map
    plx
    lda SCRIPT_TRIGGER_MAPS - 2, x
    sta script_trigger_map_ptr

    ; patch script that displays location names in memory to have
    ; the new location's name and start the script
    lda LOCATION_NAMES - 2, x
    sta location_name_script + 24
    phx
    ldx #location_name_script
    ldy #3
    jsr set_script
    plx

    sep #$20

    lda #PALETTE_BANK
    sta DMAADDRBANK
    ; write the palette
    lda #PALETTE_OFFSET
    sta CGADD

    lda #1
    sta MDMAEN

    jsr player_set_initial_position
    stz player_locked

    plp
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
    lda (zp1), y
    iny
    and #$ff
    sta zp3

    ; get the byte to write
    lda (zp1), y
    iny
    and #$ff

-   sta @l collision_map, x
    inx
    dec zp3
    bne -
    cpy zp2
    bne _next_set

    rts