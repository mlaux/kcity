
update_play_timer
    php
    sep #$20
    inc frame_counter_mod_60
    lda frame_counter_mod_60
    cmp #60
    bne +
    stz frame_counter_mod_60
    inc play_time_hms + 5
    lda play_time_hms + 5
    cmp #10
    bne +
    stz play_time_hms + 5
    inc play_time_hms + 4
    lda play_time_hms + 4
    cmp #6
    bne +
    stz play_time_hms + 4
    inc play_time_hms + 3
    lda play_time_hms + 3
    cmp #10
    bne +
    stz play_time_hms + 3
    inc play_time_hms + 2
    lda play_time_hms + 2
    cmp #6
    bne +
    stz play_time_hms + 2
    inc play_time_hms + 1
    lda play_time_hms + 1
    cmp #10
    bne +
    stz play_time_hms + 1
    inc play_time_hms
    lda play_time_hms
    cmp #10
    bne +
    stz play_time_hms
+   plp
    rts

play_timer_digit .macro
    lda play_time_hms + \1
    and #$ff
    ; offset to charset, with $21 attributes
    clc
    adc #$21b0
    sta VMDATA
.endm

draw_play_timer
.al
.xl
    lda #$8a2
    sta VMADD
    ; not worth a loop
    #play_timer_digit 0
    #play_timer_digit 1
    #static_char ':'
    #play_timer_digit 2
    #play_timer_digit 3
    #static_char ':'
    #play_timer_digit 4
    #play_timer_digit 5
    rts