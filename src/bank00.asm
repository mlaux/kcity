.as               ; Assume A8
.xs               ; Assume X8
.autsiz           ; Auto size detect
.databank $00     ; databank is 00
.dpage $0000      ; direct page is 0000

RESET
    clc
    xce ; enter 65816 mode
    rep #$30 ; AXY 16
    ldx #$1FFF
    txs
    phk
    plb
    lda #0000
    tcd

    lda #$008f
    sta $2100 ; turn the screen off

    lda #$8008     ; A -> B, FIXED SOURCE, WRITE BYTE | WRAM
    sta $4300
    lda #<>ZERO ; 64Tass | get low word
    sta $4302
    lda #`ZERO  ; 64Tass | get bank
    sta $4304
    stz $2181
    stz $2182      ; START AT 7E:0000
    stz $4305      ; DO 64K
    lda #$0001
    sta $420B      ; FIRE DMA
    sta $420B      ; FIRE IT AGAIN, FOR NEXT 64k

    rep #$20    ; A16
    lda #$008F  ; FORCE BLANK, SET OBSEL TO 0
    sta $2100
    stz $2105 ;6
    stz $2107 ;8
    stz $2109 ;A
    stz $210B ;C
    stz $210D ;E
    stz $210D ;E
    stz $210F ;10
    stz $210F ;10
    stz $2111 ;12
    stz $2111 ;12
    stz $2113 ;14
    stz $2113 ;14
    stz $2119 ;1A to get Mode7
    stz $211B ;1C these are write twice
    stz $211B ;1C regs
    stz $211D ;1E
    stz $211D ;1E
    stz $211F ;20
    stz $211F ;20
    stz $2123 ;24
    stz $2125 ;26
    stz $2126 ;27 YES IT DOUBLES OH WELL
    stz $2128 ;29
    stz $212A ;2B
    stz $212C ;2D
    stz $212E ;2F
    stz $2130 ;31
    lda #$00E0
    sta $2132

    ;ONTO THE CPU I/O REGS
    lda #$FF00
    sta $4200
    stz $4202 ;3
    stz $4204 ;5
    stz $4206 ;7
    stz $4208 ;9
    stz $420A ;B
    stz $420C ;D

    ; CLEAR VRAM
    rep #$20        ; A16
    lda #$1809      ; A -> B, fixed source, write word | vram
    sta $4300
    lda #<>ZERO  ; this get the low word, you will need to change if not using 64tass
    sta $4302
    lda #`ZERO   ; this gets the bank, you will need to change if not using 64tass
    sta $4304       ; and the upper byte will be 0
    stz $4305       ; do 64k
    lda #$80        ; inc on hi write
    sta $2115
    stz $2116       ; start at $$0000
    lda #$01
    sta $420B       ; fire dma
    ; CLEAR CG-RAM
    lda #$2208      ; a -> b, fixed source, write byte | cg-ram
    sta $4300
    lda #$200       ; 512 bytes
    sta $4305
    sep #$20        ; A8
    stz $2121       ; start at 0
    lda #$01
    sta $420B       ; fire dma
INF
    jmp INF

NMI_ISR
   ; nothing needed yet
EMPTY_ISR
   rti

; ROM header
* = $ffb0
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

; 65816 vectors
* = $ffe4
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