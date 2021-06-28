;hdma effect 5
;use a window to color a portion of the screen
;combining windows and color math (fixed color)

;2 separate hdma channels, for window


Set_F5:
	A8
	XY16

;Note: windows NOT active on main nor sub screens, 
;$2123-4, $212e-f
;but it IS active for color math...
	lda #$20 ;Window 1 active for color, not inverted
	sta $2125 ;WOBJSEL - window mask for obj and color
	lda #$10 ;prevent outside color window, clip never, 
			 ;add fixed color (not subscreen)
	sta $2130 ;CGWSEL - color addition select
	lda #$3f ;color math on all things, add, not half
	sta $2131 ;CGADSUB - color math designation
	lda #$8f ;blue at 50%
	sta $2132 ;COLDATA set the fixed color
	
;window_logic_bg = $212a-b ... keep it zero

;if we flip 2125 to inverted, the color portion will
;reverse, blue outside the box
;that also would happen if we change 2130 to 
;prevent inside


	stz $4300 ;1 register, write once
	lda #$26 ;2126 WH0
	sta $4301 ;destination
	ldx #.loword(H_TABLE7)
	stx $4302 ;address
	lda #^H_TABLE7
	sta $4304 ;address
	

	stz $4310 ;1 register, write once
	lda #$27 ;2127 WH1
	sta $4311 ;destination
	ldx #.loword(H_TABLE8)
	stx $4312 ;address
	lda #^H_TABLE8
	sta $4314 ;address
	
	lda #3 ;channels 1 and 2
	sta HDMAEN ;$420c
	
	rts
	
	
	
	
	
H_TABLE7:
.byte 40, $ff
.byte 120, $49
.byte 22, $49
.byte 1, $ff
.byte 0	



H_TABLE8:
.byte 40, 0
.byte 120, $b6
.byte 22, $b6
.byte 1, 0
.byte 0	

