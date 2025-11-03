
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