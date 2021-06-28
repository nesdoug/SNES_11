; example 11 SNES code

.p816
.smart



.include "regs.asm"
.include "variables.asm"
.include "macros.asm"
.include "init.asm"
.include "unrle.asm"
.include "HDMA1.asm"
.include "HDMA2.asm"
.include "HDMA3.asm"
.include "HDMA4.asm"
.include "HDMA5.asm"






.segment "CODE"

; enters here in forced blank
Main:
.a16 ; the setting from init code
.i16
	phk
	plb
	

	
; COPY PALETTES to PAL_BUFFER	
;	BLOCK_MOVE  length, src_addr, dst_addr
	BLOCK_MOVE  256, BG_Palette, PAL_BUFFER
	A8 ;block move will put AXY16. Undo that.
	
; DMA from PAL_BUFFER to CGRAM
	jsr DMA_Palette ; in init.asm
	
	
; DMA from Tiles to VRAM	
	lda #V_INC_1 ; the value $80
	sta VMAIN ; $2115 = set the increment mode +1


	ldx #$0000
	stx VMADDL ; set an address in the vram of $0000
	
; decompress
	UNPACK_TO_VRAM Tiles

	
	
	
; DMA from Tilemap to VRAM	
	ldx #$6000
	stx VMADDL ; set an address in the vram of $6000
	
; decompress
	UNPACK_TO_VRAM Tilemap

	
	


	lda #1 ; mode 1, tilesize 8x8 all
	sta BGMODE ; $2105
	
	stz BG12NBA ; $210b BG 1 and 2 TILES at VRAM address $0000
	
	lda #$60 ; bg1 map at VRAM address $6000
	sta BG1SC ; $2107

	lda #BG1_ON ; just layer 1
	sta TM ; $212c
	
	lda #NMI_ON|AUTO_JOY_ON
	sta NMITIMEN ;$4200
	
	lda #FULL_BRIGHT ; $0f = turn the screen on (end forced blank)
	sta INIDISP ; $2100
	
	
	
	
	
	;copy the indirect hdma table for effect 3	
	jsr Copy_F3


Infinite_Loop:	
	A8
	XY16
	jsr Wait_NMI ;wait for the beginning of v-blank
	inc frame_count
	
	;which_effect
	lda change_mode
	beq No_Change
;we need to change effects now
	
	stz change_mode
	
	jsr Back_To_Normal
	;undo all possible effects
	;then set a new effect
	
	lda which_effect
	inc a
	cmp #6 ;too far, only 0-5 allowed
	bcc @ok
	lda #0
@ok:	
	sta which_effect
	A16
	and #$00ff ;make sure upper byte clear
	asl a ;x2
	tax
	lda Jump_Table, x
	sta Ind_Jump
	pea Return-1 ;save return address to the stack
				 ;so RTS works to come back
	jmp (Ind_Jump)
;we should definitely be in v-blank
;when changing HDMA settings
	
Return:	
No_Change:
	A8
	XY16
	
	
	
	lda which_effect
	cmp #3
	bne @skip
;if mode = 3, shuffle that scroll table	
	jsr Shuffle_F3
@skip:
	
	jsr Pad_Poll ;read controllers
	
	A16
	lda pad1_new
	and #(KEY_B|KEY_Y|KEY_A|KEY_X) ;any button
	beq @no_buttons
	A8
	inc change_mode ;was zero, now 1... wait till top of next frame
@no_buttons:

	jmp Infinite_Loop
	
	
	
Back_To_Normal:
	php
	
Exit_F1:
	A8
;make sure that background color is black	
	stz CGADD ;2121
	stz CGDATA ;2122
	stz CGDATA
	
Exit_F2:
;make sure windows are off	
	stz TMW ;$212e
	stz W12SEL ;$2123
	
Exit_F3:
;make sure H scroll is back to normal	
	stz BG1HOFS ;= $210d
	stz BG1HOFS ;write twice register
	
Exit_F4:
;make sure mosaic is back to normal
	lda #$0f
	sta MOSAIC ;= $2106	
	
Exit_F5:	
;windows off
	stz WOBJSEL ;$2125
;turn off color math	
	lda #$30
	sta CGWSEL ; $2130
	stz CGADSUB ; $2131
;turn off fixed color	
	lda #$e0
	sta COLDATA ; $2132
	
	plp
	rts
	
	
	
Jump_Table:
.addr No_Effect
.addr Set_F1
.addr Set_F2
.addr Set_F3
.addr Set_F4
.addr Set_F5



No_Effect:
	stz HDMAEN ;$420c
	rts
	
	
Wait_NMI:
.a8
.i16
;should work fine regardless of size of A
	lda in_nmi ;load A register with previous in_nmi
@check_again:	
	WAI ;wait for an interrupt
	cmp in_nmi	;compare A to current in_nmi
				;wait for it to change
				;make sure it was an nmi interrupt
	beq @check_again
	rts	
	
	
Pad_Poll:
.a8
.i16
	php
	A8
@wait:
; wait till auto-controller reads are done
	lda $4212
	lsr a
	bcs @wait
	
	A16
	lda pad1
	sta temp1 ; save last frame
	lda $4218 ; controller 1
	sta pad1
	eor temp1
	and pad1
	sta pad1_new
	
	lda pad2
	sta temp1 ; save last frame
	lda $421a ; controller 2
	sta pad2
	eor temp1
	and pad2
	sta pad2_new
	plp
	rts	
	
	
	
;jsl here	
DMA_VRAM:
.a16
.i16
; do during forced blank	
; first set VRAM_Addr and VRAM_Inc
; a = source
; x = source bank
; y = length in bytes
	php
	rep #$30 ;axy16
	sta $4302 ; source and 4303
	sep #$20 ;a8
	txa
	sta $4304 ; bank
	lda #$18
	sta $4301 ; destination, vram data
	sty $4305 ; length, and 4306
	lda #1
	sta $4300 ; transfer mode, 2 registers, write once = 2 bytes
	sta $420b ; start dma, channel 0
	plp
	rtl		
	

.include "header.asm"	


.segment "RODATA1"

BG_Palette:
; 256 bytes
.incbin "ImageConverter/Background.pal"

Tiles:
; 4bpp tileset
.incbin "ImageConverter/AllTiles.rle"



Tilemap:
.incbin "ImageConverter/FullMap.rle"






