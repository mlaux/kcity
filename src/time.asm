
; Convert play_time (24-bit, in frames at 60fps) to HHmm format
; Output: 4 ASCII digits stored in playtime_string
convert_playtime_to_hhmm
.al
.xl
    php
    rep #$20

    ; Copy play_time to temp for divisions
    lda play_time
    sta playtime_temp
    sep #$20
    lda play_time_hi
    sta playtime_temp + 2

    ; Divide by 60 to get total seconds
    jsr _divide_playtime_temp_by_60

    ; Divide by 60 again to get total minutes
    jsr _divide_playtime_temp_by_60

    ; Now playtime_temp contains total minutes
    ; Divide by 60 to get hours and minutes
    rep #$20
    lda playtime_temp
    sta WRDIVL
    sep #$20
    lda #60
    sta WRDIVB
    nop
    nop
    nop
    nop
    nop
    nop
    rep #$20
    lda RDMPYL
    pha
    lda RDDIVL

    ; Convert hours to 2 ASCII digits
    sep #$20
    sta WRDIVL
    stz WRDIVH
    lda #10
    sta WRDIVB
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    lda RDDIVL
    clc
    adc #$30
    sta playtime_string
    lda RDMPYL
    clc
    adc #$30
    sta playtime_string + 1

    ; Get minutes (saved on stack)
    rep #$20
    pla

    ; Convert minutes to 2 ASCII digits
    sep #$20
    sta WRDIVL
    stz WRDIVH
    lda #10
    sta WRDIVB
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    lda RDDIVL
    clc
    adc #$30
    sta playtime_string + 2
    lda RDMPYL
    clc
    adc #$30
    sta playtime_string + 3

    plp
    rts

; Internal helper: divide playtime_temp (24-bit) by 60
_divide_playtime_temp_by_60
.al
.xl
    sep #$20

    ; Divide high byte
    lda playtime_temp + 2
    sta WRDIVL
    stz WRDIVH
    lda #60
    sta WRDIVB
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    lda RDDIVL
    pha
    lda RDMPYL

    ; Divide middle byte with remainder from high byte
    sta WRDIVH
    lda playtime_temp + 1
    sta WRDIVL
    lda #60
    sta WRDIVB
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    lda RDDIVL
    pha
    lda RDMPYL

    ; Divide low byte with remainder from middle byte
    sta WRDIVH
    lda playtime_temp
    sta WRDIVL
    lda #60
    sta WRDIVB
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    lda RDDIVL
    sta playtime_temp
    pla
    sta playtime_temp + 1
    pla
    sta playtime_temp + 2

    rts
