.dsection code
.section code
.include "main.asm"
.include "input.asm"
.include "text.asm"
.include "tileset.asm"
.include "palette.asm"
.include "effect.asm"
.include "player.asm"
.include "script.asm"
.include "save.asm"
.endsection

.dsection data
.section data
.include "mapdata.asm"
.include "fontdata.asm"
.endsection

* = $f000
.dsection audiodriver
.section audiodriver
.binary "spc700/kcity-audio.sfc", 0, $1000
.endsection

* = $ffb0
.dsection header
.section header
ZERO
    ; reference: section 1-2-14 of SNES Development Manual, Book 1
    ; "Software Submission Requirements: ROM Registration Data Specification"
    .fill 16, 0  ; extended data, not using it
    .text "K****** walled city" ; game title
    .fill $ffd5 - *, $20 ; pad title with space
    .byte $20   ; mapping mode 20, normal speed
    .byte $02   ; ROM + SRAM + battery
    .byte $07   ; 2 << 7 = 128 KB (1 megabit) ROM size
    .byte $01   ; 2 << 1 = 2 KB (16 kilobits) SRAM size
    .byte $01   ; destination code = north america
    .byte $33   ; "fixed value"
    .byte $00   ; rom version 0
    .word $ffff ; checksum complement
    .word $0000 ; checksum
.endsection

; 65816 vectors
* = $ffe4
.dsection vectors
.section vectors
v16_COP    .word EMPTY_ISR
v16_BRK    .word EMPTY_ISR
v16_ABORT  .word EMPTY_ISR
v16_NMI    .word NMI_ISR
v16_RESET  .word EMPTY_ISR
v16_IRQ    .word EMPTY_ISR

; 6502 vectors
* = $fff4
v02_COP    .word EMPTY_ISR
v02_BRK    .word EMPTY_ISR
v02_ABORT  .word EMPTY_ISR
v02_NMI    .word EMPTY_ISR
v02_RESET  .word RESET
v02_IRQ    .word EMPTY_ISR
.endsection