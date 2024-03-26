; define an ascii encoding
.enc "ascii"
; identity mapping for printable
.cdef " ~", 32

; start at beginning of .sfc
* = $000000

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