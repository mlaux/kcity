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

    #dma_ppu_data PLAYER_TILESET

    rts

map_set_warp
    php
    sep #$20
    sta target_warp_map
    lda #EFFECT_FADE_OUT
    sta effect_id
    lda #$1
    sta effect_speed
    inc player_locked
    plp
    rts

; i can't tell if this is janky or good
map_run_warp
.as
.xl
    lda target_warp_map
    bne +
    rts

+   lda effect_id
    beq +
    ; still fading out
    rts

    ; turn the screen off
+   lda #$80
    sta INIDISP

    ; if HDMA is enabled it'll interfere with normal DMA on the same channel
    stz HDMAEN

    rep #$30
    lda #DMAMODE_PPUDATA
    sta DMAMODE

    ; get x set up with offset of this map's data in each array
    lda target_warp_map
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
    stz DMAADDRBANK

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

    stz player_locked
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

    ; set initial player coordinates
    lda START_X - 2, x
    sta player_x
    lda START_Y - 2, x
    sta player_y

    ; start fade in effect
    lda #EFFECT_FADE_IN
    sta effect_id

    ; disable force blank but still 0 brightness
    lda #$0
    sta INIDISP

    rts