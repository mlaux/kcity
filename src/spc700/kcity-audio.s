;; Terrific Audio Driver LoadSongData and audio driver/data .incbin statements.
;;
;; This file is automatically generated by `tad-compiler ca65-export`.
;;
;; It MUST BE recreated if the audio project has changed (including samples, sound effects and songs).
;;

; SPDX-License-Identifier: Unlicense
;
; This is free and unencumbered software released into the public domain.
;
; Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in
; source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any
; means.
;
; In jurisdictions that recognize copyright laws, the author or authors of this software dedicate any
; and all copyright interest in the software to the public domain. We make this dedication for the
; benefit of the public at large and to the detriment of our heirs and successors. We intend this
; dedication to be an overt act of relinquishment in perpetuity of all present and future rights to
; this software under copyright law.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
; NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
; WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
; SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
;
; For more information, please refer to <http://unlicense.org/>


.setcpu "65816"

.export LoadAudioData: Far

.export Tad_Loader_Bin := __Tad_AudioData_0 + 0
.export Tad_Loader_SIZE = 116
.export Tad_AudioDriver_Bin := __Tad_AudioData_0 + 116
.export Tad_AudioDriver_SIZE = 1602
.export Tad_BlankSong_Bin := __Tad_AudioData_0 + 1718
.export Tad_BlankSong_SIZE = 37

;; [u24 ; N_DATA_ITEMS] - table of offsets within the binary file
;; u16 footer - 16 bit clipped binary file size (used to determine the size of the last item)
Tad_DataTable := __Tad_AudioData_0 + 1755
Tad_DataTable_SIZE = 8

N_DATA_ITEMS = 2
AUDIO_DATA_BANK = .bankbyte(__Tad_AudioData_0)

.import TAD_IO_VERSION
.assert TAD_IO_VERSION = 14, lderror, "TAD_IO_VERSION in audio driver does not match TAD_IO_VERSION in tad-audio.s"


.segment "BANK1"
  __Tad_AudioData_0: .incbin "kcity-audio.bin", $0
  .assert .sizeof(__Tad_AudioData_0) = $2c3c, error, "kcity-audio.bin file size does not match binary size in the assembly file"


;; LoadAudioData callback (LOROM mapping)
;;
;; Called using JSL (return with RTL)
;;
;; IN: A = 0 - Common audio data (MUST return carry set)
;; IN: A >= 1 - Song data (might be invalid)
;; OUT: Carry set if input (`A`) was valid
;; OUT: A:X = far address
;; OUT: Y = size
.a8
.i16
;; DB unknown
.proc LoadAudioData
    .assert .not .defined(HIROM), error, "HIROM is defined in code designed for LOROM"

    .assert N_DATA_ITEMS > 1, error, "No common audio data"

    cmp     #N_DATA_ITEMS
    bcc     @ValidInput
        ; return false
        clc
        rtl
@ValidInput:

    rep     #$30
.a16
    and     #$ff

    pha

    asl
    ; carry clear
    adc     1,s
    tax

    ; Calculate data size
    ; ASSUMES data size > 0 and <= $ffff
    lda     f:Tad_DataTable+3,x
    sec
    sbc     f:Tad_DataTable,x
    tay

    lda     f:Tad_DataTable,x
    cmp     #$8000
    ora     #$8000
    sta     1,s

    ; carry = bit 0 of bank byte

    sep     #$20
.a8
    lda     f:Tad_DataTable+2,x
    rol
    clc
    adc     #AUDIO_DATA_BANK

    plx

    sec
    rtl
.endproc

.assert .sizeof(LoadAudioData) = 51, error

.assert .loword(__Tad_AudioData_0) = $8000, lderror, "__Tad_AudioData_0 does not start at the beginning of a LoRom bank ($8000)"

.assert .bankbyte(Tad_DataTable) = .bankbyte(Tad_DataTable + Tad_DataTable_SIZE), lderror, "Tad_DataTable does not fit in a single bank"
