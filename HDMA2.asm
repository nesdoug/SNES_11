;hdma effect 2
;change the window 1 register

;2 separate hdma channels

;Note if left window is > right, it won't show.


.segment "CODE"

Set_F2:
	A8
	XY16
	lda #1 ;windows active on layer 1 on main screen
	sta TMW ;$212e
	lda #2 ;window 1 active on layer 1
	sta W12SEL ;$2123

	
;window_logic_bg = $212a ... keep it zero

	stz $4300 ;1 register, write once
	lda #$26 ;2126 WH0
	sta $4301 ;destination
	ldx #.loword(H_TABLE3)
	stx $4302 ;address
	lda #^H_TABLE3
	sta $4304 ;address
	

	stz $4310 ;1 register, write once
	lda #$27 ;2127 WH1
	sta $4311 ;destination
	ldx #.loword(H_TABLE4)
	stx $4312 ;address
	lda #^H_TABLE4
	sta $4314 ;address
	
	lda #3 ;channels 1 and 2
	sta HDMAEN ;$420c
	rts
	


	
	
;NOTE, if the # of scanlines has the upper bit $80 set
;it indicates a number of single scanline waits	
	
;left side of the window	
H_TABLE3:
.byte 60, $ff ;if left is > right, it won't show.
.byte $c0 ;64 lines of single entries
.byte $7f
.byte $7e
.byte $7d
.byte $7c
.byte $7b
.byte $7a
.byte $79
.byte $78
.byte $77
.byte $76
.byte $75
.byte $74
.byte $73
.byte $72
.byte $71
.byte $70
.byte $6f
.byte $6e
.byte $6d
.byte $6c
.byte $6b
.byte $6a
.byte $69
.byte $68
.byte $67
.byte $66
.byte $65
.byte $64
.byte $63
.byte $62
.byte $61
.byte $60

.byte $61
.byte $62
.byte $63
.byte $64
.byte $65
.byte $66
.byte $67
.byte $68
.byte $69
.byte $6a
.byte $6b
.byte $6c
.byte $6d
.byte $6e
.byte $6f
.byte $70
.byte $71
.byte $72
.byte $73
.byte $74
.byte $75
.byte $76
.byte $77
.byte $78
.byte $79
.byte $7a
.byte $7b
.byte $7c
.byte $7d
.byte $7e
.byte $7f
.byte $ff
.byte 0



;right side of the window
H_TABLE4:
.byte 60, $00
.byte $c0 ;64 lines of single entries
.byte $81
.byte $82
.byte $83
.byte $84
.byte $85
.byte $86
.byte $87
.byte $88
.byte $89
.byte $8a
.byte $8b
.byte $8c
.byte $8d
.byte $8e
.byte $8f
.byte $90
.byte $91
.byte $92
.byte $93
.byte $94
.byte $95
.byte $96
.byte $97
.byte $98
.byte $99
.byte $9a
.byte $9b
.byte $9c
.byte $9d
.byte $9e
.byte $9f
.byte $a0

.byte $9f
.byte $9e
.byte $9d
.byte $9c
.byte $9b
.byte $9a
.byte $99
.byte $98
.byte $97
.byte $96
.byte $95
.byte $94
.byte $93
.byte $92
.byte $91
.byte $90
.byte $8f
.byte $8e
.byte $8d
.byte $8c
.byte $8b
.byte $8a
.byte $89
.byte $88
.byte $87
.byte $86
.byte $85
.byte $84
.byte $83
.byte $82
.byte $81
.byte $00
.byte 0	
	
	
	