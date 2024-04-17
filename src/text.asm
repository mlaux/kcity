; contains routines for rendering text in a variable-width font to WRAM,
; and copying those tiles to VRAM

DIALOG_BOX_BASE = $ac2
TILE_DESTINATION_START = $3010
TILE_ID_START = $2002
BYTES_PER_TILE = $10

vwf_frame_loop
.al
.xl
    lda text_box_enabled
    bne +
    stz current_text
    stz text_index
    rts

+   lda current_text
    bne +

    lda text_index
    cmp text_box_num_lines
    beq +

    asl
    tay
    lda (text_box_lines), y
    sta current_text

    ; string currently being drawn?
+   lda vwf_end_of_string
    bne _no

    ; yes, keep going with current string
_yes
    lda #1
    sta vwf_count
    jmp vwf_draw_string

    ; no, anything to draw?
_no
    ldx current_text
    bne _draw_next_string
    rts

    ; yes, start it
_draw_next_string
    lda text_index
    asl
    tax
    lda LINE_START_TABLE, x
    tay
    ldx current_text
    jsr vwf_init_string
    inc text_index
    bra _yes

; call from vblank to transfer text tiles and do text box background HDMA
text_box_vblank
.as
.xl
    ldy vwf_dmalen
    beq +

    jsr vwf_dma_tiles
    jsr vwf_transfer_map
    stz vwf_dmalen

+   lda text_box_enabled
    bne +
    stz HDMAEN
    jmp vwf_reset_map ; reuse rts

    ; place text box at proper location
+   lda text_box_wh0
    sta WH0
    lda text_box_wh1
    sta WH1

    ldx text_box_num_lines
    lda TEXT_BOX_HEIGHTS, x
    sta text_box_hdma_table + 4

    lda #$0
    sta DMAMODE
    lda #CGADSUB & $ff
    sta DMAPPUREG
    ldx #text_box_hdma_table
    stx DMAADDR
    stz DMAADDRBANK
    lda #$1
    sta HDMAEN

+   rts

; - resets destination text tile pointer to beginning of WRAM output buffer
; - resets next tile pointer to the tile after that
; - resets VRAM pointer to the beginning of tile data for BG3 tileset
; assumes: A16
vwf_reset_tiles
.al
    lda #vwf_tiles
    sta vwf_dst
    clc
    adc #BYTES_PER_TILE
    sta vwf_next

    lda #TILE_DESTINATION_START
    sta vwf_dmadst

    ; incrementing tile counter
    lda #TILE_ID_START
    sta vwf_tilemap_id

    lda #1
    sta vwf_end_of_string
    rts

; get ready to render the next string
; input: X - address of string
;        Y - destination in tilemap
; assumes: A16
vwf_init_string
.al
.xl
    lda vwf_dst
    clc
    adc #BYTES_PER_TILE
    sta vwf_dst
    adc #BYTES_PER_TILE
    sta vwf_next

    stx vwf_src
    sty vwf_tilemap_dst
    stz vwf_offs
    stz vwf_end_of_string

    rts

; Renders text in variable-width font to tiles and returns the rendered text
; for copying to VRAM during the next blanking interval.
; vwf_src points to the currently processed char.
; vwf_dst points to the first byte of the current tile (in WRAM).
; input: vwf_src = address of string
;        vwf_count = count of characters to draw (-1 for everything)
; returns: vwf_dmasrc = base address of rendered text to send to VRAM
;          vwf_dmadst = destination address for VRAM DMA
;          vwf_dmalen = number of tiles to send to VRAM
; assumes: AXY 16
vwf_draw_string
.al
.xl
    lda vwf_end_of_string
    beq +
    rts

    ; before doing anything set the return value
+   lda vwf_dst
    sta vwf_dmasrc
    stz vwf_dmasrcbank

; this is kind of crazy branching???
; surely i can optimize how this works
_check_count
    lda vwf_count
    ; if length parameter was negative, want whole string
    bmi _load_char
    dec vwf_count
    bmi _exit_length_parameter_reached

_load_char
    lda (vwf_src)
    and #$ff
    cmp #$ff
    sta vwf_ch
    bne _process_char

    ; end of string. next time called, return immediately
    inc vwf_end_of_string
    stz current_text
    ; take into account any unfinished tiles this time
    lda vwf_next
    bra +

_exit_length_parameter_reached
    ; calculate length used (in bytes)
    lda vwf_dst
+   sec
    sbc vwf_dmasrc
    sta vwf_dmalen

    rts

_process_char
    ; look up tile in font (go to last byte because it iterates backwards)
    ; vwf_font_ptr = GENEVA_CHARS + (16 * vwf_ch) + 15
    asl
    asl
    asl
    asl
    clc
    adc #GENEVA_CHARS
    adc #$f
    sta vwf_font_ptr

    ; for each byte in the current destination tile
    ldy #15
_each_byte
    sep #$20

    ; save existing tile byte
    lda (vwf_dst), y
    sta vwf_cur_tile_byte

    lda #0
    sta vwf_remainder

    ; loads equivalent byte from font for this char
    lda (vwf_font_ptr)

    ldx vwf_offs
-   beq _done_shifting
    ; remove the rightmost "vwf_offs" pixels
    lsr
    ; and store them in the remainder to be placed in the next tile
    ror vwf_remainder
    dex
    bra -

_done_shifting
    ; combine new partial character with existing tile
    ; 0 - transparent, 1 - black, 2 - black, 3 - white
    ora vwf_cur_tile_byte
    sta (vwf_dst), y

    ; leftover pixels need to go in the next tile
    lda vwf_remainder
    sta (vwf_next), y

    rep #$20

    dec vwf_font_ptr
    dey
    bpl _each_byte

    ; vwf_offs = (vwf_offs + CHAR_WIDTHS[vwf_ch]) % 8;
    ldx vwf_ch
    lda CHAR_WIDTHS, x
    and #$ff
    clc
    adc vwf_offs
    sta vwf_offs

    ; if vwf_offs < 8 move to next tile
    cmp #8
    bmi _no_tile_increment
    and #7
    sta vwf_offs

    lda vwf_next
    sta vwf_dst
    clc
    adc #BYTES_PER_TILE
    sta vwf_next

_no_tile_increment
    ; successfully completed this char without overflowing the tile
    ; onto the next char
    inc vwf_src

    ; all the crazy branching above is because there's no conditional relative long branch
    brl _check_count

; input: y = number of bytes to transfer
vwf_dma_tiles
.as
.xl
    sty DMALEN
    ldx #DMAMODE_PPUDATA
    stx DMAMODE

    ldx vwf_dmasrc
    stx DMAADDR
    lda vwf_dmasrcbank
    sta DMAADDRBANK

    ldx vwf_dmadst
    stx VMADD
    lda #$80
    sta VMAIN

    lda #1
    sta MDMAEN

    ; advance vram pointer by however many words were written
    rep #$20
    lda vwf_dmalen
    lsr
    clc
    adc vwf_dmadst
    sta vwf_dmadst
    sep #$20
    rts

; sets the tilemap (increasing tile id from 1) starting at the position
; previously set with vwf_set_position, to tiles generated by vwf_draw_string
; and vwf_dma_tiles
; assumes: A8 XY16
vwf_transfer_map
.as
.xl
    ldx vwf_tilemap_dst
    stx VMADD
    lda #$80
    sta VMAIN

    ; in BYTES, divide by 16 to get num tiles
    lda vwf_dmalen
    lsr
    lsr
    lsr
    lsr

    ; write tile ids
-   ldx vwf_tilemap_id
    stx VMDATA
    inc vwf_tilemap_id
    inc vwf_tilemap_dst
    dec a
    bne -

    rts

; only call from vblank
vwf_reset_map
.as
.xl
    rep #$20

    lda vwf_tilemap_id
    sec
    sbc #TILE_ID_START
    bne +

    ; if equal nothing to do
    sep #$20
    rts

    ; byte count to clear = 16 * num tiles used
+   asl
    asl
    asl
    asl
    sta DMALEN

    ldx #DMAMODE_PPUFILL
    stx DMAMODE

    sep #$20

    ldx #<>ZERO
    stx DMAADDR
    lda #`ZERO
    sta DMAADDRBANK

    ldx #TILE_DESTINATION_START
    stx VMADD
    lda #$80
    sta VMAIN

    lda #1
    sta MDMAEN

    ldx #TILE_ID_START
    stx vwf_tilemap_id

    rts

LINE_START_TABLE .word DIALOG_BOX_BASE, DIALOG_BOX_BASE + $20, DIALOG_BOX_BASE + $40, DIALOG_BOX_BASE + $60
; heights for 1, 2, 3, 4 lines
TEXT_BOX_HEIGHTS .byte 0, $18, $20, $28, $30