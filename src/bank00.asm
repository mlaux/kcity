.dsection code
.section code
.include "main.asm"
.include "state.asm"
.include "title.asm"
.include "gameplay.asm"
.include "journal.asm"
.include "input.asm"
.include "text.asm"
.include "tileset.asm"
.include "palette.asm"
.include "effect.asm"
.include "player.asm"
.include "script.asm"
.include "save.asm"
.include "time.asm"
.include "opening.asm"
.include "file_sel.asm"
.include "menu.asm"
.endsection

.dsection map_data
.section map_data
.include "mapdata.asm"
.endsection
.dsection font_data
.section font_data
.include "fontdata.asm"
.endsection

.dsection palettes
.section palettes
.include "palettes.asm"
.endsection

.dsection snesmod
.section snesmod
.include "snesmod/snesmod.asm"
.include "snesmod/spcdriv.asm"
.endsection

.warn format("bank00 free space: $%04x", $80ffb0 - *)

; * = $f000
; .dsection tad_driver
; .section tad_driver
; .binary "spc700/kcity-audio.sfc", 0, $1000
; .endsection

* = $80ffb0
.dsection header
.section header
ZERO
    ; reference: section 1-2-14 of SNES Development Manual, Book 1
    ; "Software Submission Requirements: ROM Registration Data Specification"
    .fill 16, 0  ; extended data, not using it
    .text "K****** walled city" ; game title
    .fill $80ffd5 - *, $20 ; pad title with space
    .byte $30   ; mapping mode 20, fast speed
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
* = $80ffe4
.dsection vectors
.section vectors
v16_COP    .addr EMPTY_ISR
v16_BRK    .addr EMPTY_ISR
v16_ABORT  .addr EMPTY_ISR
v16_NMI    .addr NMI_ISR
v16_RESET  .addr EMPTY_ISR
v16_IRQ    .addr EMPTY_ISR

; 6502 vectors
* = $80fff4
v02_COP    .addr EMPTY_ISR
v02_BRK    .addr EMPTY_ISR
v02_ABORT  .addr EMPTY_ISR
v02_NMI    .addr EMPTY_ISR
v02_RESET  .addr RESET
v02_IRQ    .addr EMPTY_ISR
.endsection