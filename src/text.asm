; contains routines for rendering text in a variable-width font to WRAM,
; and copying those tiles to VRAM

; - resets destination text tile pointer to beginning of WRAM output buffer
; - resets next tile pointer to the tile after that
; assumes: A16
vwf_reset
.al
    lda #$3000
    sta vwf_dmadst
    lda #$800
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

    ; vwf_src points to the currently processed char.
    ; vwf_dst points to the first byte of the current tile.
_each_char
    lda vwf_count
    bmi _want_entire_string
    dec vwf_count
    bmi _exit

_want_entire_string
    lda (vwf_src)
    and #$ff
    cmp #$ff
    beq _exit_end_of_string
    sta vwf_ch

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

_no_tile_increment
    ; successfully completed this char without overflowing the tile
    ; onto the next char
    inc vwf_src
    brl _each_char

_exit_end_of_string
    ; next time called, return immediately
    inc vwf_done
    ; take into account any unfinished tiles this time
    lda vwf_next
    bra +
_exit
    ; calculate length used (in bytes)
    lda vwf_dst
+   sec
    sbc vwf_dmasrc
    sta vwf_dmalen
    rts

; sends the tilemap (increasing numbers from 0)
vwf_transfer_map
.as
.xl
    ldx vwf_mapdst
    stx VMADD
    lda #$80
    sta VMAIN

    lda vwf_dmalen ; in BYTES
    lsr
    lsr
    lsr
    lsr

-   ldy vwf_mapcount
    sty VMDATA
    inc vwf_mapcount
    dec a
    bne -

    rep #$20
    lda vwf_mapcount
    and #$ff
    clc
    adc #$800
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
