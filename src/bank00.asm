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
.endsection

.dsection data
.section data
.include "mapdata.asm"
.include "playerdata.asm"
.include "fontdata.asm"
FILLER_PALETTES .fill 256
.endsection

* = $ffb0
.dsection header
.section header
ZERO
    .fill 16,0
    .text "K****** walled city"
    .fill $ffd5 - *, $20 ; pad title with space
    .byte $20   ; Mapping
    .byte $00   ; Rom
    .byte $07   ; 128K
    .byte $00   ; 0 SRAM
    .byte $00   ; NTSC-J
    .byte $33   ; Version 3
    .byte $00   ; rom version 0
    .word $FFFF ; complement
    .word $0000 ; CRC
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