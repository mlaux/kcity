; contains routines for rendering text in a variable-width font to WRAM,
; and copying those tiles to VRAM

DIALOG_BOX_BASE = $ac2
LINE_START_TABLE .word DIALOG_BOX_BASE, DIALOG_BOX_BASE + $11, DIALOG_BOX_BASE + $21, DIALOG_BOX_BASE + $31

; - resets destination text tile pointer to beginning of WRAM output buffer
; - resets next tile pointer to the tile after that
; assumes: A16
vwf_reset
.al
    stz vwf_tiles_written
    lda #$3000
    sta vwf_dmadst
    lda #DIALOG_BOX_BASE
    sta vwf_mapdst
    ; incrementing tile counter
    lda #$2000
    sta vwf_mapcount
    lda #vwf_tiles
    sta vwf_dst
    clc
    adc #$10
    sta vwf_next
    rts

; Renders text in variable-width font to tiles and returns the rendered text
; for copying to VRAM during the next blanking interval.
; vwf_src points to the currently processed char.
; vwf_dst points to the first byte of the current tile.
; input: vwf_src = address of string
;        vwf_count = count of characters to draw (-1 for everything)
; returns: vwf_dmasrc = base address of rendered text to send to VRAM
;          vwf_dmadst = destination address for VRAM DMA
;          vwf_dmalen = number of tiles to send to VRAM
; assumes: AXY 16
vwf_draw_string
.al
.xl
    lda vwf_done
    beq +
    stz vwf_dmalen
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
    inc vwf_done
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
    sta vwf_row

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
    ora vwf_row
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
    cmp #8
    bmi _no_tile_increment
    sec
    sbc #8
    sta vwf_offs

    lda vwf_next
    sta vwf_dst
    clc
    adc #$10
    sta vwf_next
    inc vwf_tiles_written

_no_tile_increment
    ; successfully completed this char without overflowing the tile
    ; onto the next char
    inc vwf_src

    ; all the crazy branching above is because there's no conditional relative branch
    brl _check_count

; sends the tilemap (increasing tile id from 0)
vwf_transfer_map
.as
.xl
    ldx vwf_mapdst
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
-   ldx vwf_mapcount
    stx VMDATA
    inc vwf_mapcount
    dec a
    bne -

    ; bad word wrap, last tile of the line?
    ; lda vwf_mapcount
    ; and #$f
    ; cmp #$f
    ; bne +
    ; inc text_box_line

+   rep #$20

    ; loop up destination address in tilemap (line base - (16 * line) - 1)
    lda text_box_line
    asl
    tax
    lda LINE_START_TABLE, x
    sta text_box_line_start

    ; add to number of tiles written
    lda vwf_mapcount
    and #$ff
    clc
    adc text_box_line_start
    sta vwf_mapdst

    sep #$20

    rts

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
