;hdma effect 4
;change the mosaic register

;standard single hdma


.segment "CODE"

Set_F4:
	A8
	XY16
	
	stz $4300 ;1 register, write once
	lda #$06 ;mosaic
	sta $4301 ;destination
	ldx #.loword(H_TABLE6)
	stx $4302 ;address
	lda #^H_TABLE6
	sta $4304 ;address
	
	lda #1 ;channel 1
	sta HDMAEN ;$420c
	rts

	

	
	
H_TABLE6:
.byte 32, $0f
.byte 32, $1f
.byte 32, $2f
.byte 32, $4f
.byte 32, $6f
.byte 32, $9f
.byte 32, $ff
.byte 0
	
	
	
	