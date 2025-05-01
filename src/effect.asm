EFFECT_NONE = 0
EFFECT_FADE_IN = 1
EFFECT_FADE_OUT = 2
EFFECT_MOSAIC_ON = 3
EFFECT_MOSAIC_OFF = 4

; todo: integrate this with script system, no reason for it to be separate
run_effect
.as
.xl
    rep #$20
    lda frame_counter
    and effect_speed
    beq +
    rts

+   lda effect_id
    bne +
    rts

+   dec a
    asl
    tax
    sep #$20
    lda effect_level
    jmp (EFFECTS, x)

run_fade_in
    inc a
    cmp #$f
    bne +
    stz effect_id
+   sta effect_level
    sta my_inidisp
    rts

run_fade_out
    dec a
    bne +
    stz effect_id
+   sta effect_level
    sta my_inidisp
    rts

run_mosaic_on
    inc a
    cmp #$f
    bne +
    stz effect_id
+   sta effect_level
    asl
    asl
    asl
    asl
    ora #$f
    sta my_mosaic
    rts

run_mosaic_off
    dec a
    bne +
    stz effect_id
    stz my_mosaic
    rts

+   sta effect_level
    asl
    asl
    asl
    asl
    ora #$f
    sta my_mosaic

    rts

EFFECTS .word run_fade_in, run_fade_out, run_mosaic_on, run_mosaic_off

; "Effect-aware" way to disable rendering immediately
enable_force_blank
    php
    sep #$20
    lda #$80
    sta INIDISP
    sta my_inidisp
    plp
    rts

; leaves brightness at 0. set to something else separately if needed
disable_force_blank
    php
    sep #$20
    stz INIDISP
    stz my_inidisp
    plp
    rts

start_fade_in
.al
.xl
    lda #EFFECT_FADE_IN
    sta effect_id
    lda #$1
    sta effect_speed
    stz effect_level
    rts

start_fade_out
.al
.xl
    lda #EFFECT_FADE_OUT
    sta effect_id
    lda #$1
    sta effect_speed
    lda #$f
    sta effect_level
    rts

wait_for_effect
.al
.xl
-   ldx #$1
    stx update_ppu
    lda effect_id
    bne -
    stz update_ppu
    rts