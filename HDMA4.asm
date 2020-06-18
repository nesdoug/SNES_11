;hdma effect 4
;change the mosaic register

;standard single hdma


.segment "CODE"

set_f4:
	A8
	XY16
	lda #$0f ; off / normal
	sta mosaic ;= $2106
	
	stz $4300 ;1 register, write once
	lda #$06 ;mosaic
	sta $4301 ;destination
	ldx #.loword(H_TABLE6)
	stx $4302 ;address
	lda #^H_TABLE6
	sta $4304 ;address
	
	lda #1 ;channel 1
	sta hdma_enable ;$420c
	rts

exit_f4:
	A8
;make sure mosaic is back to normal
	lda #$0f
	sta mosaic ;= $2106
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
	
	