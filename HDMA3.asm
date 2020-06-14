;hdma effect 3
;change the horizontal scroll

;using indirect mode
;change the set to make moving sine wave


.segment "CODE"


copy_f3:
	php
	AXY16
	BLOCK_MOVE  (end_IT-IND_TABLE), IND_TABLE, $7e1000
	plp
	rts


set_f3:
	A8
	XY16
	stz bg1_scroll_x ;= $210d
	stz bg1_scroll_x ;write twice register
	
	jsr Shuffle_f3
	
	lda #$42 ;indirect mode = the 0100 0000 bit ($40)
	sta $4300 ;1 register, write twice
	lda #$0d ;bg1_scroll_x horizontal scroll bg1
	sta $4301 ;destination
	ldx #.loword(H_TABLE5)
	stx $4302 ;address
	lda #^H_TABLE5
	sta $4304 ;address
	lda #$7e
	sta $4307 ;indirect address bank
	
	lda #1 ;channel 1
	sta hdma_enable ;$420c
	rts
	

exit_f3:
	A8
;make sure H scroll is back to normal	
	stz bg1_scroll_x ;= $210d
	stz bg1_scroll_x ;write twice register
	rts
	
Shuffle_f3:
	php
	A8
	lda frame_count
	and #3
	bne @exit
;only does this every 4th frame	
;when frame_count & 3 == 0
	AXY16
	lda $1000
	sta temp1
	
	lda $1002
	sta $1000
	lda $1004
	sta $1002
	lda $1006
	sta $1004
	lda $1008
	sta $1006
	lda $100a
	sta $1008
	lda $100c
	sta $100a
	lda $100e
	sta $100c
	lda $1010
	sta $100e
	lda $1012
	sta $1010
	lda $1014
	sta $1012
	lda $1016
	sta $1014
	lda $1018
	sta $1016
	lda $101a
	sta $1018
	lda $101c
	sta $101a
	lda $101e
	sta $101c
	
	lda temp1
	sta $101e
@exit:	
	plp
	rts

	

H_TABLE5:
.byte 8
.addr $1000
.byte 8
.addr $1002
.byte 8
.addr $1004
.byte 8
.addr $1006
.byte 8
.addr $1008
.byte 8
.addr $100a
.byte 8
.addr $100c
.byte 8
.addr $100e
.byte 8
.addr $1010
.byte 8
.addr $1012
.byte 8
.addr $1014
.byte 8
.addr $1016
.byte 8
.addr $1018
.byte 8
.addr $101a
.byte 8
.addr $101c
.byte 8
.addr $101e

.byte 8
.addr $1000
.byte 8
.addr $1002
.byte 8
.addr $1004
.byte 8
.addr $1006
.byte 8
.addr $1008
.byte 8
.addr $100a
.byte 8
.addr $100c
.byte 8
.addr $100e
.byte 8
.addr $1010
.byte 8
.addr $1012
.byte 8
.addr $1014
.byte 8
.addr $1016
;cut some
.byte 0
	
	
;https://www.daycounter.com/Calculators/Sine-Generator-Calculator.phtml	
;0x8,0xb,0xe,0xf,0x10,0xf,0xe,0xb,
;0x8,0x5,0x2,0x1,0x0,0x1,0x2,0x5,	
;indirect	

;scroll registers are low then high
;16x2
IND_TABLE:
.byte 0, 0
.byte 3, 0
.byte 6, 0
.byte 7, 0
.byte 8, 0
.byte 7, 0
.byte 6, 0
.byte 3, 0
.byte 0, 0
.byte $fd, 0
.byte $fa, 0
.byte $f9, 0
.byte $f8, 0
.byte $f9, 0
.byte $fa, 0
.byte $fd, 0
.byte 0,0
end_IT:
	
	
	
	
	