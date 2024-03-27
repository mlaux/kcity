; 7  bit  0
; ---- ----
; F... BBBB
; |    ||||
; |    ++++- Screen brightness (linear steps from 0 = none to $F = full)
; +--------- Force blanking
INIDISP = $2100

OBJSEL = $2101
OAMADDL = $2102
OAMADDH = $2103
OAMDATA = $2104

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
BGMODE = $2105

; 7  bit  0
; ---- ----
; SSSS 4321
; |||| ||||
; |||| |||+- Enable BG1 mosaic
; |||| ||+-- Enable BG2 mosaic
; |||| |+--- Enable BG3 mosaic
; |||| +---- Enable BG4 mosaic
; ++++------ Mosaic size in pixels (0 = 1x1, ..., 15 = 16x16)
MOSAIC = $2106

; 7  bit  0
; ---- ----
; AAAA AAYX
; |||| ||||
; |||| |||+- Horizontal tilemap count (0 = 1 tilemap, 1 = 2 tilemaps)
; |||| ||+-- Vertical tilemap count (0 = 1 tilemap, 1 = 2 tilemaps)
; ++++-++--- Tilemap VRAM address (word address = AAAAAA << 10)
BG1SC = $2107
BG2SC = $2108
BG3SC = $2109
BG4SC = $210A

; 7  bit  0
; ---- ----
; BBBB AAAA
; |||| ||||
; |||| ++++- BG1 CHR word base address (word address = AAAA << 12)
; ++++------ BG2 CHR word base address (word address = BBBB << 12)
BG12NBA = $210B

; 7  bit  0
; ---- ----
; DDDD CCCC
; |||| ||||
; |||| ++++- BG3 CHR word base address (word address = CCCC << 12)
; ++++------ BG4 CHR word base address (word address = DDDD << 12)
BG34NBA = $210C

; 15  bit  8   7  bit  0
;  ---- ----   ---- ----
;  .... ..XX   XXXX XXXX
;         ||   |||| ||||
;         ++---++++-++++- BGn horizontal scroll

; On write: BGnHOFS = (value << 8) | (bgofs_latch & ~7) | (bghofs_latch & 7)
;           bgofs_latch = value
;           bghofs_latch = value

; Note: BG1HOFS uses the same address as M7HOFS
BG1HOFS = $210D

M7HOFS = $210D

; 15  bit  8   7  bit  0
;  ---- ----   ---- ----
;  .... ..YY   YYYY YYYY
;         ||   |||| ||||
;         ++---++++-++++- BGn vertical scroll

; On write: BGnVOFS = (value << 8) | bgofs_latch
;           bgofs_latch = value

; Note: BG1VOFS uses the same address as M7VOFS
BG1VOFS = $210E

M7VOFS = $210E
BG2HOFS = $210F
BG2VOFS = $2110
BG3HOFS = $2111
BG3VOFS = $2112
BG4HOFS = $2113
BG4VOFS = $2114

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
VMAIN = $2115

;   VMADDH      VMADDL
;   $2117       $2116
; 7  bit  0   7  bit  0
; ---- ----   ---- ----
; hHHH HHHH   LLLL LLLL
; |||| ||||   |||| ||||
; ++++-++++---++++-++++- VRAM word address

; On write: Update VMADD
;           vram_latch = [VMADD]
VMADD = $2116
VMADDL = $2116
VMADDH = $2117

;  VMDATAH     VMDATAL
;   $2119       $2118
; 7  bit  0   7  bit  0
; ---- ----   ---- ----
; HHHH HHHH   LLLL LLLL
; |||| ||||   |||| ||||
; ++++-++++---++++-++++- VRAM data word

; On $2118 write: If address increment mode == 0: increment VMADD
; On $2119 write: If address increment mode == 1: increment VMADD
VMDATAL = $2118
VMDATAH = $2119
M7SEL = $211A
M7A = $211B
M7B = $211C
M7C = $211D
M7D = $211E
M7X = $211F
M7Y = $2120
CGADD = $2121
CGDATA = $2122
W12SEL = $2123
W34SEL = $2124
WOBJSEL = $2125
WH0 = $2126
WH1 = $2127
WH2 = $2128
WH3 = $2129
WBGLOG = $212A
WOBJLOG = $212B

; 7  bit  0
; ---- ----
; ...O 4321
;    | ||||
;    | |||+- Enable BG1 on main screen
;    | ||+-- Enable BG2 on main screen
;    | |+--- Enable BG3 on main screen
;    | +---- Enable BG4 on main screen
;    +------ Enable OBJ on main screen
TM = $212C

; 7  bit  0
; ---- ----
; ...O 4321
;    | ||||
;    | |||+- Enable BG1 on subscreen
;    | ||+-- Enable BG2 on subscreen
;    | |+--- Enable BG3 on subscreen
;    | +---- Enable BG4 on subscreen
;    +------ Enable OBJ on subscreen
TS = $212D
TMW = $212E
TSW = $212F
CGWSEL = $2130
CGADSUB = $2131
COLDATA = $2132

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
SETINI = $2133
MPYL = $2134
MPYM = $2135
MPYH = $2136
SLHV = $2137
OAMDATAREAD = $2138
VMDATALREAD = $2139
VMDATAHREAD = $213A
CGDATAREAD = $213B
OPHCT = $213C
OPVCT = $213D
STAT77 = $213E
STAT78 = $213F