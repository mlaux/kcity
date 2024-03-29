; Registers            Also known as...
DMAMODE      = $4300 ; DMAPn
DMAPPUREG    = $4301 ; BBADn
DMAADDR      = $4302 ; A1TnL
DMAADDRHI    = $4303 ; A1TnH
DMAADDRBANK  = $4304 ; A1Bn
DMALEN       = $4305 ; DASnL
DMALENHI     = $4306 ; DASnH

; Configuration for $43n0
; OR these together to get the desired effect
DMA_LINEAR   = $00
DMA_01       = $01
DMA_00       = $02
DMA_0011     = $03
DMA_0123     = $04
DMA_0101     = $05
DMA_FORWARD  = $00
DMA_CONST    = $08
DMA_BACKWARD = $10
DMA_INDIRECT = $40
DMA_READPPU  = $80

; These defines are meant for a 16-bit write to $43n0 and $43n1
; and they set up the channel for several common cases.
DMAMODE_PPULOFILL = ((<VMDATAL) << 8 | DMA_LINEAR | DMA_CONST)
DMAMODE_PPUHIFILL = ((<VMDATAH) << 8 | DMA_LINEAR | DMA_CONST)
DMAMODE_PPUFILL   = (<VMDATAL) << 8 | DMA_01     | DMA_CONST
DMAMODE_RAMFILL   = (<WMDATA)  << 8 | DMA_LINEAR | DMA_CONST
DMAMODE_PPULODATA = (<VMDATAL) << 8 | DMA_LINEAR | DMA_FORWARD
DMAMODE_PPUHIDATA = (<VMDATAH) << 8 | DMA_LINEAR | DMA_FORWARD
DMAMODE_PPUDATA   = (<VMDATAL) << 8 | DMA_01     | DMA_FORWARD
DMAMODE_CGDATA    = (<CGDATA)  << 8 | DMA_00     | DMA_FORWARD
DMAMODE_OAMDATA   = (<OAMDATA) << 8 | DMA_00     | DMA_FORWARD
DMAMODE_CGFILL    = (<CGDATA)  << 8 | DMA_00     | DMA_CONST