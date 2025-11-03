; 7  bit  0
; ---- ----
; F... BBBB
; |    ||||
; |    ++++- Screen brightness (linear steps from 0 = none to $F = full)
; +--------- Force blanking
INIDISP = $802100

OBJSEL = $802101
OAMADD = $802102
OAMADDL = $802102
OAMADDH = $802103
OAMDATA = $802104

; 7  bit  0
; ---- ----
; 4321 PMMM
; |||| ||||
; |||| |+++- BG mode (see below)
; |||| +---- Mode 1 BG3 priority (0 = normal, 1 = high)
; |||+------ BG1 character size (0 = 8x8, 1 = 16x16)
; ||+------- BG2 character size (0 = 8x8, 1 = 16x16)
; |+-------- BG3 character size (0 = 8x8, 1 = 16x16)
; +--------- BG4 character size (0 = 8x8, 1 = 16x16)
BGMODE = $802105

; 7  bit  0
; ---- ----
; SSSS 4321
; |||| ||||
; |||| |||+- Enable BG1 mosaic
; |||| ||+-- Enable BG2 mosaic
; |||| |+--- Enable BG3 mosaic
; |||| +---- Enable BG4 mosaic
; ++++------ Mosaic size in pixels (0 = 1x1, ..., 15 = 16x16)
MOSAIC = $802106

; 7  bit  0
; ---- ----
; AAAA AAYX
; |||| ||||
; |||| |||+- Horizontal tilemap count (0 = 1 tilemap, 1 = 2 tilemaps)
; |||| ||+-- Vertical tilemap count (0 = 1 tilemap, 1 = 2 tilemaps)
; ++++-++--- Tilemap VRAM address (word address = AAAAAA << 10)
BG1SC = $802107
BG2SC = $802108
BG3SC = $802109
BG4SC = $80210A

; 7  bit  0
; ---- ----
; BBBB AAAA
; |||| ||||
; |||| ++++- BG1 CHR word base address (word address = AAAA << 12)
; ++++------ BG2 CHR word base address (word address = BBBB << 12)
BG12NBA = $80210B

; 7  bit  0
; ---- ----
; DDDD CCCC
; |||| ||||
; |||| ++++- BG3 CHR word base address (word address = CCCC << 12)
; ++++------ BG4 CHR word base address (word address = DDDD << 12)
BG34NBA = $80210C

; 15  bit  8   7  bit  0
;  ---- ----   ---- ----
;  .... ..XX   XXXX XXXX
;         ||   |||| ||||
;         ++---++++-++++- BGn horizontal scroll

; On write: BGnHOFS = (value << 8) | (bgofs_latch & ~7) | (bghofs_latch & 7)
;           bgofs_latch = value
;           bghofs_latch = value

; Note: BG1HOFS uses the same address as M7HOFS
BG1HOFS = $80210D

M7HOFS = $80210D

; 15  bit  8   7  bit  0
;  ---- ----   ---- ----
;  .... ..YY   YYYY YYYY
;         ||   |||| ||||
;         ++---++++-++++- BGn vertical scroll

; On write: BGnVOFS = (value << 8) | bgofs_latch
;           bgofs_latch = value

; Note: BG1VOFS uses the same address as M7VOFS
BG1VOFS = $80210E

M7VOFS = $80210E
BG2HOFS = $80210F
BG2VOFS = $802110
BG3HOFS = $802111
BG3VOFS = $802112
BG4HOFS = $802113
BG4VOFS = $802114

; 7  bit  0
; ---- ----
; M... RRII
; |    ||||
; |    ||++- Address increment amount:
; |    ||     0: Increment by 1 word
; |    ||     1: Increment by 32 words
; |    ||     2: Increment by 128 words
; |    ||     3: Increment by 128 words
; |    ++--- Address remapping: (VMADD -> Internal)
; |           0: None
; |           1: Remap rrrrrrrr YYYccccc -> rrrrrrrr cccccYYY (2bpp)
; |           2: Remap rrrrrrrY YYcccccP -> rrrrrrrc ccccPYYY (4bpp)
; |           3: Remap rrrrrrYY YcccccPP -> rrrrrrcc cccPPYYY (8bpp)
; +--------- Address increment mode:
;             0: Increment after writing $2118 or reading $2139
;             1: Increment after writing $2119 or reading $213A
VMAIN = $802115

;   VMADDH      VMADDL
;   $2117       $2116
; 7  bit  0   7  bit  0
; ---- ----   ---- ----
; hHHH HHHH   LLLL LLLL
; |||| ||||   |||| ||||
; ++++-++++---++++-++++- VRAM word address

; On write: Update VMADD
;           vram_latch = [VMADD]
VMADD = $802116
VMADDL = $802116
VMADDH = $802117

;  VMDATAH     VMDATAL
;   $2119       $2118
; 7  bit  0   7  bit  0
; ---- ----   ---- ----
; HHHH HHHH   LLLL LLLL
; |||| ||||   |||| ||||
; ++++-++++---++++-++++- VRAM data word

; On $2118 write: If address increment mode == 0: increment VMADD
; On $2119 write: If address increment mode == 1: increment VMADD
VMDATA = $802118
VMDATAL = $802118
VMDATAH = $802119

M7SEL = $80211A
M7A = $80211B
M7B = $80211C
M7C = $80211D
M7D = $80211E
M7X = $80211F
M7Y = $802120
CGADD = $802121
CGDATA = $802122
W12SEL = $802123
W34SEL = $802124
WOBJSEL = $802125
WH0 = $802126
WH1 = $802127
WH2 = $802128
WH3 = $802129
WBGLOG = $80212A
WOBJLOG = $80212B

; 7  bit  0
; ---- ----
; ...O 4321
;    | ||||
;    | |||+- Enable BG1 on main screen
;    | ||+-- Enable BG2 on main screen
;    | |+--- Enable BG3 on main screen
;    | +---- Enable BG4 on main screen
;    +------ Enable OBJ on main screen
TM = $80212C

BG1_ON = $1
BG2_ON = $2
BG3_ON = $4
BG4_ON = $8
OBJ_ON = $10

; 7  bit  0
; ---- ----
; ...O 4321
;    | ||||
;    | |||+- Enable BG1 on subscreen
;    | ||+-- Enable BG2 on subscreen
;    | |+--- Enable BG3 on subscreen
;    | +---- Enable BG4 on subscreen
;    +------ Enable OBJ on subscreen
TS = $80212D

TMW = $80212E
TSW = $80212F
CGWSEL = $802130
CGADSUB = $802131
COLDATA = $802132

; 7  bit  0
; ---- ----
; EX.. HOiI
; ||   ||||
; ||   |||+- Screen interlacing
; ||   ||+-- OBJ interlacing
; ||   |+--- Overscan mode
; ||   +---- High-res mode
; |+-------- EXTBG mode
; +--------- External sync
SETINI = $802133
MPYL = $802134
MPYM = $802135
MPYH = $802136
SLHV = $802137
OAMDATAREAD = $802138
VMDATALREAD = $802139
VMDATAHREAD = $80213A
CGDATAREAD = $80213B
OPHCT = $80213C
OPVCT = $80213D
STAT77 = $80213E
STAT78 = $80213F

dma_ppu_data .macro
    ldx #<>\1
    stx DMAADDR
    lda #`\1
    sta DMAADDRBANK
    ldx #size(\1)
    stx DMALEN

    lda #1
    sta MDMAEN
.endmacro
