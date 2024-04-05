; define an ascii encoding
.enc "ascii"
; identity mapping for printable
.cdef " ~", 0

.include "ppu.asm"
.include "cpu.asm"
.include "dma.asm"

; start at beginning of .sfc
* = $0
; text source pointer for VWF routine
vwf_src .word ?
; base address of current tile
vwf_dst .word ?
; base address of next tile
vwf_next .word ?
; font byte currently being shifted/copied
vwf_font_ptr .word ?

* = $100

; 32 tiles * 16 bytes/tile * 4 lines = 1024 bytes
vwf_tiles .fill $400

; how many chars to draw
vwf_count .word ?

vwf_row .word ?
vwf_ch .word ?
; the horizontal pixel offset into the current tile
vwf_offs .word ?
vwf_remainder .word ?
vwf_tiles_written .word ?

; return values for text rendering
vwf_dmasrc .word ?
vwf_dmasrcbank .word ?
vwf_dmadst .word ?
vwf_dmalen .word ?
vwf_done .word ?

vwf_mapdst .word ?
vwf_mapcount .word ?
text_box_line .word ?
text_box_line_start .word ?

; main vs. nmi flag, nmi is skipped if this is 0
main_loop_done .word ?

scroll .word ?

; place first 32k
.logical $008000
.include "bank00.asm"
.here

; .logical $010000
; .include "bank01.asm"
; .here

; 128k minus one byte
* = $01ffff
.byte 0

; VRAM MAP
; 0000 - 07FF (0000 - 03FF): BG1 tilemap
; 0800 - 0FFF (0400 - 07FF): BG2 tilemap
; 1000 - 17FF (0800 - 0BFF): BG3 tilemap
; 1800 - 1FFF (0C00 - 0FFF): free
; 2000 - 3FFF (1000 - 1FFF): BG1 tiles
; 4000 - 5FFF (2000 - 2FFF): BG2 tiles (currently free)
; 6000 - 63FF (3000 - 31FF): BG3 tiles (variable width text tiles)
; 6400 - 7FFF (3200 - 3FFF): BG3 tiles (other)