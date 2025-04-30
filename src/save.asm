
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

    ldx #SCRIPT_MESSAGE_SAVED
    ldy #2
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

    plp
    rts