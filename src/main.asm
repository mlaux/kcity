; define an ascii encoding
.enc "ascii"
; identity mapping for printable
.cdef " ~", 0

.include "ppu.asm"
.include "cpu.asm"
.include "dma.asm"

; start at beginning of .sfc
* = $0
; base address of current tile
vwf_dst .word ?
; base address of next tile
vwf_next .word ?

* = $100

; 32 tiles * 16 bytes/tile * 4 lines = 1024 bytes
vwf_tiles .fill $400

; source pointer for VWF routine
vwf_src .word ?

vwf_row .word ?
vwf_ch .word ?
; the horizontal pixel offset into the current tile
vwf_offs .word ?
vwf_remainder .word ?

vwf_dmaout .word ?
vwf_dmaoutbank .word ?
vwf_dmalen .word ?
main_loop_done .word ?

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