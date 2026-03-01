; 1. fade in to floor/wall close up with dripping water
; 2. cut to four different close up parts of juno/leif's room with
;       faint electrical hum, water dripping, cars outside (mode 1 bgs)
; 3. switch to mode7 bg of juno's bed, music fade in
; 4. slowly zoom out affine transformation matrix
; 5. transition to state_gameplay (full map) with cutscene continuing in script
;       interpreter. player gets control

PHASE_DRIP = 240
PHASE_SHELF = 180
PHASE_SCREEN = 180
PHASE_PHOTO = 180
PHASE_DRAWINGS = 180
PHASE_MODE7_BED = 300

state_opening_init
.al
.xl
    sep #$20
    ldx	#2
	jsr	spcLoad
    ldx #0
    jsr spcPlay
    jsr spcFlush
    ; wait for music to start
-   jsr spcReadStatus
    bit #SPC_P
    beq -
    rep #$20
    rts

state_opening
opening_drip
.al
.xl
    jsr enable_force_blank
    lda #$31
    sta my_bgmode
    lda #(BG1_ON | OBJ_ON)
    sta my_tm
    jsr load_drip_scene
    jsr disable_force_blank
    lda #EFFECT_FADE_IN
    sta effect_id
    lda #$7
    sta effect_speed
    stz effect_level
    jsr wait_for_effect
    lda #PHASE_DRIP
    sta opening_timer
_loop
    jsr wait_for_vblank
    dec opening_timer
    bne _loop
    jsr start_fade_out
    jsr wait_for_effect

opening_shelf
.al
.xl
    jsr enable_force_blank
    jsr load_room_parts
    stz my_bghofs
    lda #$120
    sta my_bgvofs
    jsr disable_force_blank
    lda #$f
    sta my_inidisp
    ;jsr start_fade_in
    ;jsr wait_for_effect
    lda #PHASE_SHELF
    sta opening_timer
_loop
    lda frame_counter
    and #$f
    bne +
    dec my_bgvofs
+   jsr wait_for_vblank
    dec opening_timer
    bne _loop

opening_screen
.al
.xl
    stz my_bghofs
    lda #-1
    sta my_bgvofs
    lda #PHASE_SCREEN
    sta opening_timer
_loop
    jsr wait_for_vblank
    sep #$20
    lda #$28
    sta CGADD
    lda frame_counter
    and #3
    cmp #2
    bcs +
    ldx #$90
-   lda OPENING_ROOM_PARTS_PALETTE,x
    sta CGDATA
    lda OPENING_ROOM_PARTS_PALETTE + 1,x
    sta CGDATA
    inx
    inx
    cpx #$98
    bne -
    bra _done
+   ldx #$50
-   lda OPENING_ROOM_PARTS_PALETTE,x
    sta CGDATA
    lda OPENING_ROOM_PARTS_PALETTE + 1,x
    sta CGDATA
    inx
    inx
    cpx #$58
    bne -
_done
    rep #$20
    dec opening_timer
    bne _loop

opening_photo
.al
.xl
    lda #$100
    sta my_bghofs
    lda #$120
    sta my_bgvofs
    lda #PHASE_PHOTO
    sta opening_timer
_loop
    jsr wait_for_vblank
    dec opening_timer
    bne _loop

opening_drawings
.al
.xl
    lda #$100
    sta my_bghofs
    stz my_bgvofs
    lda #PHASE_DRAWINGS
    sta opening_timer
_loop
    jsr wait_for_vblank
    dec opening_timer
    bne _loop

opening_mode7_bed
.al
.xl
    jsr enable_force_blank
    jsr load_mode7_data
    jsr set_mode7
    jsr disable_force_blank
    lda #$f
    sta my_inidisp
    lda #PHASE_MODE7_BED
    sta opening_timer
_loop
    lda frame_counter
    and #3
    bne +
    lda my_m7a
    cmp #$200
    beq +
    inc my_m7a
    inc my_m7d
+   jsr wait_for_vblank
    dec opening_timer
    bne _loop

opening_end
.al
.xl
    ; it actually processes this in reverse order, so to overwrite the default
    ; player direction with left, i need to add this first, then run_state_init
    ; which will queue up facing right... dumb
    lda #PLAYER_DIRECTION_LEFT - 1
    sta player_direction
    sln 7
    ldx #0
    jsr dma_queue_add

    ldy #2
    jsr run_state_init
    jmp longjmp_main

state_opening_vblank
.al
.xl

    php
    sep #$20
    lda my_m7sel
    sta M7SEL

    lda my_m7a
    sta M7A
    lda my_m7a + 1
    sta M7A
    lda my_m7b
    sta M7B
    lda my_m7b + 1
    sta M7B
    lda my_m7c
    sta M7C
    lda my_m7c + 1
    sta M7C
    lda my_m7d
    sta M7D
    lda my_m7d + 1
    sta M7D

    lda my_m7x
    sta M7X
    lda my_m7x + 1
    sta M7X
    lda my_m7y
    sta M7Y
    lda my_m7y + 1
    sta M7Y

    plp
    rts

load_drip_scene
.al
.xl
    php
    sep #$20
    ldx #DMAMODE_PPUDATA
    stx DMAMODE

    lda #$80
    sta VMAIN
    ldx #0
    stx VMADD
    #dma_ppu_data OPENING_DRIP_SCENE_TILEMAP

    ldx #$1000
    stx VMADD
    #dma_ppu_data OPENING_DRIP_SCENE_TILESET

    ldx #DMAMODE_CGDATA
    stx DMAMODE
    lda #$0
    sta CGADD
    #dma_ppu_data OPENING_DRIP_SCENE_PALETTE

    plp
    rts

load_room_parts
.al
.xl
    php
    sep #$20
    ldx #DMAMODE_PPUDATA
    stx DMAMODE

    lda #$80
    sta VMAIN
    ldx #0
    stx VMADD
    #dma_ppu_data OPENING_ROOM_PARTS_TILEMAP

    ldx #$1000
    stx VMADD
    #dma_ppu_data OPENING_ROOM_PARTS_TILESET

    ldx #DMAMODE_CGDATA
    stx DMAMODE
    lda #$0
    sta CGADD
    #dma_ppu_data OPENING_ROOM_PARTS_PALETTE

    plp
    rts

load_mode7_data
.xl
    php
    sep #$20

    lda #`MODE7_TILEMAP
    sta DMAADDRBANK

    ldx #DMAMODE_PPULODATA
    stx DMAMODE
    stz VMAIN
    ldx #0
    stx VMADD
    ldx #<>MODE7_TILEMAP
    stx DMAADDR
    ldx #MODE7_TILEMAP_LENGTH
    stx DMALEN
    lda #1
    sta MDMAEN

    ldx #DMAMODE_PPUHIDATA
    stx DMAMODE
    lda #$80
    sta VMAIN
    ldx #0
    stx VMADD
    ldx #<>MODE7_TILE0
    stx DMAADDR
    ldx #MODE7_TILE0_LENGTH
    stx DMALEN
    lda #1
    sta MDMAEN

    ; ldx #DMAMODE_CGDATA
    ; stx DMAMODE
    ; stz CGADD
    ; ldx #<>MODE7_PALETTE
    ; stx DMAADDR
    ; ldx #MODE7_PALETTE_LENGTH
    ; stx DMALEN
    ; lda #1
    ; sta MDMAEN

    plp
    rts

set_mode7
.al
.xl
    php
    sep #$20
    lda #7
    sta my_bgmode

    ldx #$80
    stx my_m7a
    stx my_m7d

    ldx #$200
    stx my_m7x
    ldx #$200
    stx my_m7y

    ldx #(1024 / 2) - (256 / 2)
    stx my_bghofs
    ldx #(1024 / 2) - (224 / 2)
    stx my_bgvofs

    plp
    rts

wait_for_vblank
.al
.xl
    inc update_ppu
-   lda update_ppu
    bne -
    rts