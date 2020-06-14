.p816
.smart

.include "easySNES.asm"
.include "init.asm"
.include "MUSIC/music.asm"






.segment "ZEROPAGE"

object1x: .res 1
object1y: .res 1

facing:	.res 1
.define FACE_LEFT 0
.define FACE_RIGHT 1

window1L:	.res 1
window1R:	.res 1
window12I:	.res 1
window2L:	.res 1
window2R:	.res 1
;window2I:	.res 1


.segment "CODE"

;enters here in forced blank
main:
.a16 ;just a standardized setting from init code
.i16
	phk ;push current bank, pull to data bank, to
	plb ;make sure the current bank's data is accessible
		;do this any time you jump to a different bank
		;and need to use data in that bank.


	A8 ;all these need a8
	
	SET_BG_MODE  1
	SET_BG_TILESIZE  BG_ALL_8x8
	SET_BG3_PRI  BG3_TOP
	;note, all the priority bits of bg3 map also have to be set
	;for bg3 tiles to be on top
	
	
	SET_BG1_TILE_ADDR $0000
	SET_BG2_TILE_ADDR $0000
	SET_BG3_TILE_ADDR $2000

	
	SET_BG1_MAP_ADDR $6000
;note, also copies the number $6000 to bg1_map_base for later use	
	SET_BG2_MAP_ADDR $6800
;note, also copies the number $6800 to bg2_map_base for later use	
	SET_BG3_MAP_ADDR $7000
;note, also copies the number $7000 to bg3_map_base for later use	


	SET_BG1_MAP_SIZE  MAP_32_32
	SET_BG2_MAP_SIZE  MAP_32_32
	SET_BG3_MAP_SIZE  MAP_32_32

	
	SET_OAM_SIZE  OAM_8_16
	SET_OAM_TILE_ADDR  $4000
	
	
;now load the tiles to the vram	
;+1 increment mode
	A8
	SET_VRAM_INC  V_INC_1 
	
	
;4bpp tiles for bg 1 and 2	
	AXY16
	lda #$0000
	sta vram_addr
	DMA_TO_VRAM  BGTILES4, $2000

	
;2bpp tiles for bg 3
	lda #$2000
	sta vram_addr
	DMA_TO_VRAM  BGTILES2, $1000
	

;4bpp tiles for sprites
	lda #$4000
	sta vram_addr
	DMA_TO_VRAM  SPRTILES, $2000

	
	
;now load the maps to the vram
	lda bg1_map_base ;see, we did need this!
	sta vram_addr
	DMA_TO_VRAM  BG1_MAP, $700
	

	
;	lda bg2_map_base
;	sta vram_addr
;	DMA_TO_VRAM  BG2_MAP, $700

	
	
	lda bg3_map_base
	sta vram_addr
;	DMA_TO_VRAM  BG3_MAP, $100
	lda #$2011
	ldx #$700
	jsl vram_fill2
	
	

	COPY_PAL_BG Test_Palette
	
; one row of sprite palette data
	COPY_PAL_ROW Sp_Palette,8


	
;nmi's should be off when loading data to the spc
	;a = address of song
	;x = bank of song
	AXY16
	lda #.loword(song1)
	ldx #^song1
	jsl spc_play_song
	;re enable nmi now
;	A8
;	lda r4200 ;enable NMI
;	sta $4200

	
	
	
	
	A8
	lda #ALL_ON_SCREEN ;enable main screen
	;alternate version
	;lda #(BG1_ON|BG2_ON|BG3_ON|SPR_ON)
	jsl set_main_screen
	
	lda #FULL_BRIGHT
	jsl pal_bright
	
	
;enable NMI and auto controller reads, IRQs off
	SET_INTERRUPT  NMI_ON|AUTO_JOY_ON
	
	
	A8	
	jsl ppu_on ; end forced blank

	
;some initial values for sprite positions.	
;	lda #$50
;	sta object1x
;	lda #$5c
;	sta object1y
;	lda #$ff
;	sta window2L
;	sta window2R
;	
;	lda #$0a ;1010
;	sta window12I
;2123 bg2 upper 4, bg1 lower 4
;d		win1 invert
; c		win1 active
;  b	win2 invert
;   a	win2 active
;2124 bg 4 upper 4, bg3 lower 4
;2125 color upper 4, oam lower 4

;2126 w1 L
;2127 w1 R
;2128 w2 L
;2129 w2 R
;if L > R window won't work

; NOTE !!!
; games just to FF L 00 R to leave inactive areas of window.
	
	
InfiniteLoop:	
	A8
	XY16
	jsl ppu_wait_nmi
	
;adjust the window, first thing
	WDM_BREAK
	A8
	lda #$0a ;window12I
	sta $2123 ;bg 1 and 2
	sta $2124 ;bg 3 and 4
	stz $2126 ;w1 L
	stz $2127 ;w1 R
	lda #$ff
	sta $2128 ;w2 L
	sta $2129 ;w2 R
	lda #7 ;1,2,3
	sta $212e ;window main
	sta $212f ;window sub (not needed)
	
	stz $4300 ;mode 0, note $40 for indirect mode
	lda #$27 ;window 1 right
	sta $4301 ;destination
	lda #^H_TABLE
	sta $4304 ;bank address
	A16
	lda #.loword(H_TABLE)
	sta $4302 ;address
	A8
	lda #1
	sta $420c ;hdma enable
	
	
	jsl pad_poll
	jsl oam_clear
;	jsl reset_vram_system 



	

	
;move the windows	
	A16
	XY8
	lda pad1
	and #KEY_B
	beq @skip_b
	ldx window1R
	beq @skip_b
	dex
	stx window1R
	
@skip_b:	
	lda pad1
	and #KEY_A
	beq @skip_a
	ldx window1R
	cpx #$ff
	beq @skip_a
	inx
	stx window1R
	
@skip_a:
	lda pad1
	and #KEY_Y
	beq @skip_y
	ldx window2L
	beq @skip_y
	dex
	stx window2L
	
@skip_y:	
	lda pad1
	and #KEY_X
	beq @skip_x
	ldx window2L
	cpx #$ff
	beq @skip_x
	inx
	stx window2L
	
@skip_x:
	lda pad1_new
	and #KEY_SELECT
	beq @skip_sel
	A8
	lda window12I
	eor #1
	sta window12I
	A16
	
@skip_sel:
	lda pad1_new
	and #KEY_START
	beq @skip_st
	A8
	lda window12I
	eor #4
	sta window12I
	A16
	
@skip_st:

	

	
	A8
	lda window12I
	and #1
	beq @skip_I1
	
	lda #$10
	sta spr_x
	lda #$30
	sta spr_y
	lda #(SPR_SIZE_LG)
	sta spr_h ; small
	AXY16
	lda #.loword(Metasprite_L)
	ldx #^Metasprite_L
	jsl oam_meta_spr
	A8
	
@skip_I1:
	
	lda window12I
	and #4
	beq @skip_I2
	
	lda #$e0
	sta spr_x
	lda #$30
	sta spr_y
	lda #(SPR_SIZE_LG)
	sta spr_h ; small
	AXY16
	lda #.loword(Metasprite_L)
	ldx #^Metasprite_L
	jsl oam_meta_spr
	A8
	
@skip_I2:	

	AXY16
	
;---------
	
	jmp InfiniteLoop
	
H_TABLE:
.byte 50, 0
.byte $90 ;multiline
.byte 2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32
.byte 0,0	
	

Metasprite_L:
;relative x, relative y, tile #, attributes
.byte   $00, $00, $01, SPR_PAL_0|SPR_PRIOR_2|SPR_H_FLIP	
.byte   $f8, $10, $22, SPR_PAL_0|SPR_PRIOR_2|SPR_H_FLIP
.byte   $08, $10, $20, SPR_PAL_0|SPR_PRIOR_2|SPR_H_FLIP
.byte 128 ;end of set

Metasprite_R:
;relative x, relative y, tile #, attributes
.byte   $00, $00, $01, SPR_PAL_0|SPR_PRIOR_2	
.byte   $f8, $10, $20, SPR_PAL_0|SPR_PRIOR_2
.byte   $08, $10, $22, SPR_PAL_0|SPR_PRIOR_2
.byte 128 ;end of set
	
	
.include "header.asm"





.segment "RODATA1"

BGTILES4:
.incbin "PCX/Hello.chr"



SPRTILES:
.incbin "M1TE/SPR_TEST.chr"



.segment "RODATA2"

BGTILES2:
.incbin "M1TE/ALPHA2.chr"


;each of these are 1792 bytes ($700)
BG1_MAP:
;$700
.incbin "PCX/Hello.map"


BG2_MAP:
;$700
;.incbin "M1TE/BG_TEST2.map"


BG3_MAP:
;$100
.incbin "PCX/BG3.map"




.segment "RODATA3"
Test_Palette:
.incbin "PCX/hello.pal"
Sp_Palette: 
;1 row
.incbin "M1TE/SPR_TEST.pal"





.segment "RODATA7"
music_code:
.incbin "MUSIC/spc700.bin"

song1:
.incbin "MUSIC/music_1.bin"
;song2:
;.incbin "MUSIC/music_2.bin"




