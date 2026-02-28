; 1. fade in to floor/wall close up with dripping water
; 2. cut to four different close up parts of juno/leif's room with
;       faint electrical hum, water dripping, cars outside (mode 1 bgs)
; 3. switch to mode7 bg of juno's bed, music fade in
; 4. slowly zoom out affine transformation matrix
; 5. transition to state_gameplay (full map) with cutscene continuing in script
;       interpreter. player gets control

; not sure if i'm going to need these because i'm doing all of this in a blocking way
PHASE_DRIP = 0
PHASE_SHELF = 1
PHASE_SCREEN = 2
PHASE_PHOTO = 3
PHASE_DRAWINGS = 4
PHASE_MODE7_BED = 5
PHASE_END = 6

state_opening_init
.al
.xl
    jsr enable_force_blank
    jsr load_mode7_data
    jsr set_mode7
    jsr disable_force_blank
    lda #$f
    sta my_inidisp
    rts

state_opening
.al
.xl
    lda frame_counter
    and #3
    beq +
    rts
+   lda my_m7a
    cmp #$200
    bne +
    rts
+   inc my_m7a
    inc my_m7d
    rts

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

    ldx #DMAMODE_CGDATA
    stx DMAMODE
    stz CGADD
    ldx #<>MODE7_PALETTE
    stx DMAADDR
    ldx #MODE7_PALETTE_LENGTH
    stx DMALEN
    lda #1
    sta MDMAEN

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