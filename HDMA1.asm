;color gradient
;write palette address 0
;hdma effect 1
;change the #0 palette color (main background color)

;2 separate hdma channels


.segment "CODE"

set_f1:
	A8
	XY16
	stz pal_addr ;2121
	stz pal_data ;2122
	stz pal_data
	
	stz $4300 ;1 register, write once
	lda #$21 ;pal_addr
	sta $4301 ;destination
	ldx #.loword(H_TABLE1)
	stx $4302 ;address
	lda #^H_TABLE1
	sta $4304 ;address
	
	
	
	
	lda #2
	sta $4310 ;1 register, write twice
	lda #$22 ;pal_data
	sta $4311 ;destination
	ldx #.loword(H_TABLE2)
	stx $4312 ;address
	lda #^H_TABLE2
	sta $4314 ;address
	
	
	lda #3 ;channels 1 and 2
	sta hdma_enable ;$420c
	rts
	

exit_f1:
	A8
;make sure that background color is black	
	stz pal_addr ;2121
	stz pal_data ;2122
	stz pal_data
	rts
	
	
;palette address	
	
H_TABLE1:
.byte 10, 0
.byte 10, 0
.byte 10, 0
.byte 10, 0
.byte 10, 0
.byte 10, 0
.byte 10, 0
.byte 10, 0
.byte 10, 0
.byte 10, 0
.byte 10, 0
.byte 10, 0
.byte 10, 0
.byte 10, 0
.byte 10, 0
.byte 10, 0
.byte 10, 0
.byte 10, 0
.byte 10, 0
.byte 10, 0
.byte 10, 0
.byte 0

	
	

	
	
;palette color	
	
H_TABLE2:
.byte 10, 0, 0
.byte 10, 1, 0
.byte 10, 2, 0
.byte 10, 3, 0
.byte 10, 4, 0
.byte 10, 5, 0
.byte 10, 6, 0
.byte 10, 7, 0
.byte 10, 8, 0
.byte 10, 9, 0
.byte 10, 10, 0
.byte 10, 11, 0
.byte 10, 12, 0
.byte 10, 13, 0
.byte 10, 14, 0
.byte 10, 15, 0
.byte 10, 16, 0
.byte 10, 17, 0
.byte 10, 18, 0
.byte 10, 19, 0
.byte 10, 20, 0
.byte 0