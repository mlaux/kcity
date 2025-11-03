
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
    lda play_time_hms
    sta sram_play_time_hms
    lda play_time_hms + 2
    sta sram_play_time_hms + 2
    lda play_time_hms + 4
    sta sram_play_time_hms + 4

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

    lda sram_play_time_hms
    sta play_time_hms
    lda sram_play_time_hms + 2
    sta play_time_hms + 2
    lda sram_play_time_hms + 4
    sta play_time_hms + 4

    plp
    rts