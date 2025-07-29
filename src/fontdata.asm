
GENEVA_CHARS .binary "../font/geneva.2bp"
CHAR_WIDTHS .binary "../font/chwidths.bin"

; heights for 1, 2, 3, 4 lines (8x8 font)
TEXT_BOX_HEIGHTS .byte 0, $18, $20, $28, $30

; heights for 1, 2, 3, 4 lines (8x16 font - double height)
TEXT_BOX_HEIGHTS_8X16 .byte 0, $30, $40, $50, $60

; $40 for $AA lines
; $40 for $BB more lines
; $51 for $CC lines
; $40 for 1 line (really to end of frame)
; $0 for end
TEXT_HDMA_TABLE .byte $AA, $40, $BB, $40, $CC, $51, $1, $40, 0
