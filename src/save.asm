
save_game
.al
.xl
    php
    rep #$20

    lda current_map_id
    sta sram_map_id
    lda player_x
    sta sram_player_x
    lda player_y
    sta sram_player_y
    lda game_progress
    sta sram_game_progress
    ; lda play_time
    ; sta sram_play_time
    ; lda play_time_hi
    ; sta sram_play_time_hi

    ldx #SCRIPT_MESSAGE_SAVED
    ldy #3
    jsr set_script

    plp
    rts

load_game
.al
.xl
    php
    rep #$20

    lda sram_map_id
    sta target_warp_map

    lda sram_player_x
    sta target_player_x

    lda sram_player_y
    sta target_player_y

    lda sram_game_progress
    sta game_progress

    ; lda sram_play_time
    ; sta play_time

    ; lda sram_play_time_hi
    ; sta play_time_hi

    plp
    rts