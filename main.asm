; example 11 SNES code

.p816
.smart

.segment "ZEROPAGE"
temp1: .res 2
temp2: .res 2
temp3: .res 2
temp4: .res 2
temp5: .res 2
temp6: .res 2
pad1: .res 2
pad1_new: .res 2
pad2: .res 2
pad2_new: .res 2
in_nmi: .res 2
which_effect: .res 1
change_mode: .res 1
frame_count: .res 1



.include "defines.asm"
.include "macros.asm"
.include "init.asm"
.include "unrle.asm"
.include "HDMA1.asm"
.include "HDMA2.asm"
.include "HDMA3.asm"
.include "HDMA4.asm"






.segment "CODE"

; enters here in forced blank
main:
.a16 ; just a standardized setting from init code
.i16
	phk
	plb
	

	
; DMA from BG_Palette to CGRAM
	A8
	stz $2121 ; $2121 cg address = zero
	
	stz $4300 ; transfer mode 0 = 1 register write once
	lda #$22  ; $2122
	sta $4301 ; destination, pal data
	ldx #.loword(BG_Palette)
	stx $4302 ; source
	lda #^BG_Palette
	sta $4304 ; bank
	ldx #256
	stx $4305 ; length
	lda #1
	sta $420b ; start dma, channel 0
	
	
; DMA from Tiles to VRAM	
	lda #V_INC_1 ; the value $80
	sta vram_inc ; $2115 = set the increment mode +1
	ldx #$0000
	stx vram_addr ; set an address in the vram of $0000
	
	lda #1
	sta $4300 ; transfer mode, 2 registers 1 write
			  ; $2118 and $2119 are a pair Low/High
	lda #$18  ; $2118
	sta $4301 ; destination, vram data

; decompress first
	AXY16
	lda #.loword(Tiles)
	ldx #^Tiles
	jsl unrle ; unpacks to 7f0000 UNPACK_ADR
	; returns y = length
	; ax = unpack address (x is bank)
	sta $4302 ; source
	txa
	A8
	sta $4304 ; bank
	sty $4305 ; length
	lda #1
	sta $420b ; start dma, channel 0
	
	
	
; DMA from Tilemap to VRAM	
	ldx #$6000
	stx vram_addr ; set an address in the vram of $6000
	
; decompress first
	AXY16
	lda #.loword(Tilemap)
	ldx #^Tilemap
	jsl unrle ; unpacks to 7f0000 UNPACK_ADR
	; returns y = length
	; ax = unpack address (x is bank)
	sta $4302 ; source
	txa
	A8
	sta $4304 ; bank
	sty $4305 ; length
	lda #1
	sta $420b ; start dma, channel 0
	
;copy the indirect hdma table for effect 3	
	jsr copy_f3

	lda #1 ; mode 1, tilesize 8x8 all
	sta bg_size_mode ; $2105
	stz bg12_tiles ; $210b BG 1 and 2 TILES at VRAM address $0000
	lda #$60 ; bg1 map at VRAM address $6000
	sta tilemap1 ; $2107

	lda #BG1_ON ; just layer 1
	sta main_screen ; $212c
	
	lda #NMI_ON|AUTO_JOY_ON
	sta $4200
	
	lda #FULL_BRIGHT ; $0f = turn the screen on (end forced blank)
	sta fb_bright ; $2100


InfiniteLoop:	
	A8
	XY16
	jsr wait_nmi ;wait for the beginning of v-blank
	;turn hdma off by default, then re-enable later
	stz hdma_enable ;$420c
	inc frame_count
	
	;which_effect
	lda change_mode
	beq @no_change
	stz change_mode
	
	lda which_effect
	beq @inc_mode ;0 = no effect to cancel
@1:
	cmp #1
	bne @2
	jsr exit_f1
	bra @inc_mode
@2:	
	cmp #2
	bne @3
	jsr exit_f2
	bra @inc_mode
@3:	
	cmp #3
	bne @4
	jsr exit_f3
	bra @inc_mode	
@4:	
	jsr exit_f4
	
@inc_mode:
	lda which_effect
	inc a
	cmp #5
	bcc @ok ;0-4 ok
	lda #0
@ok:
	sta which_effect

@no_change:


Set_HDMA:
;set up the hdma per mode
	lda which_effect
	beq @no_effect ;0 = no effect
@1:
	cmp #1
	bne @2
	jsr set_f1
	bra @no_effect
@2:
	cmp #2
	bne @3
	jsr set_f2
	bra @no_effect	
@3:
	cmp #3
	bne @4
	jsr set_f3
	bra @no_effect	
@4:	
	jsr set_f4
	
@no_effect:	
	jsr pad_poll ;read controllers
	
	A16
	lda pad1_new
	and #(KEY_B|KEY_Y|KEY_A|KEY_X) ;any button
	beq @no_buttons
	A8
	inc change_mode
@no_buttons:
	;A16 not needed
	jmp InfiniteLoop
	
	
wait_nmi:
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
	
	
pad_poll:
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






