TILEMAP_SIZE = $800
PALETTE_OFFSET = $10
PALETTE_SIZE = $70

tileset_init
.as
.xl
    ldx #DMAMODE_PPUDATA
    stx DMAMODE

    lda #$80
    sta VMAIN

    ldx #$2000
    stx VMADD

    #dma_ppu_data GENEVA_CHARS

    ldx #$4000
    stx VMADD

    #dma_ppu_data NPC_TILESET

    rts

; copies 16x32 sprite in tileset to video ram 
; no idea what i'm doing but i need to implement this or i'll run out of
; tile IDs with just a few characters on screen
; input: a - tile id
; AXY 16

; (frame * 0x400) + (direction * 0x80) for the top half of the sprite
; and that plus 0x200 for the bottom half
dma_queue_add
.al
.xl
    pha
    lda dma_queue_length
    asl
    tax

    lda #DMAMODE_PPUDATA
    sta dma_queue_entry_mode, x
    sta dma_queue_entry_mode + 2, x
    lda #`PLAYER_TILESET
    sta dma_queue_entry_addr_bank, x
    sta dma_queue_entry_addr_bank + 2, x
    lda #$80
    sta dma_queue_entry_vmain, x
    sta dma_queue_entry_vmain + 2, x
    ; lda #$80
    sta dma_queue_entry_length, x
    sta dma_queue_entry_length + 2, x

    lda #$4000 ; 4020, 4100, 4120
    sta dma_queue_entry_vmadd, x
    lda #$4100
    sta dma_queue_entry_vmadd + 2, x

    pla
    clc
    adc #<>PLAYER_TILESET
    sta dma_queue_entry_addr, x
    adc #$200
    sta dma_queue_entry_addr + 2, x

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
    lda #EFFECT_FADE_OUT
    sta effect_id
    lda #$1
    sta effect_speed
    lda #$f
    sta effect_level
    rts

; i can't tell if this is janky or good
map_run_warp
.al
.xl
    php
    rep #$20
    
    lda target_warp_map
    bne +
    plp
    rts

+   lda effect_id
    beq +
    ; still fading out
    plp
    rts

    ; turn the screen off
+   sep #$20
    lda #$80
    sta INIDISP

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

    lda ALL_TILEMAPS - 2, x
    sta DMAADDR
    lda #TILEMAP_SIZE
    sta DMALEN

    stz VMADD

    sep #$20
    lda #$80
    sta VMAIN
    lda #`TEST_TILEMAP
    sta DMAADDRBANK

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

    lda ALL_PALETTES - 2, x
    sta DMAADDR
    lda #PALETTE_SIZE
    sta DMALEN
    lda #DMAMODE_CGDATA
    sta DMAMODE

    lda COLLISION_MAPS - 2, x
    sta collision_map_ptr

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

    ; write the palette
    lda #PALETTE_OFFSET
    sta CGADD

    lda #1
    sta MDMAEN

    jsr player_set_initial_position

    ; start fade in effect
    lda #EFFECT_FADE_IN
    sta effect_id
    lda #$1
    sta effect_speed
    stz effect_level

    ; disable force blank but still 0 brightness
    lda #$0
    sta INIDISP

    stz player_locked

    plp
    rts