; define an ascii encoding
.enc "ascii"
; identity mapping for printable
.cdef " ~", 0

.include "ppu.asm"
.include "cpu.asm"
.include "dma.asm"

; start at beginning of .sfc
* = $0

* = $100
; source pointer for VWF routine
vwf_src .word ?
vwf_tile .fill $8

vwf_ch .byte ?
; the horizontal pixel offset into the current tile
vwf_offs .byte ?
rendered_text .fill $100

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