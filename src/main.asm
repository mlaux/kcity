; define an ascii encoding
.enc "ascii"
; identity mapping for printable
.cdef " ~", 0

.include "ppu.asm"
.include "cpu.asm"
.include "dma.asm"

; start at beginning of .sfc
* = $0
vwf_dst .word ?

* = $100
vwf_tiles .fill $200
; source pointer for VWF routine
vwf_src .word ?

vwf_row .word ?
vwf_ch .word ?
; the horizontal pixel offset into the current tile
vwf_offs .word ?

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