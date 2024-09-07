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
    jmp (EFFECTS,x)

run_fade_in
    inc a
    cmp #$f
    bne +
    stz effect_id
+   sta effect_level
    sta INIDISP
    rts

run_fade_out
    dec a
    bne +
    stz effect_id
+   sta effect_level
    sta INIDISP
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
    sta MOSAIC
    rts

run_mosaic_off
    dec a
    bne +
    stz effect_id
    stz MOSAIC
    rts

+   sta effect_level
    asl
    asl
    asl
    asl
    ora #$f
    sta MOSAIC

    rts

EFFECTS .word run_fade_in, run_fade_out, run_mosaic_on, run_mosaic_off
