
	processor F8
	
BIOS_CLEAR_SCREEN   = $00d0        ; uses r31
	
COLOR_RED 			= $40
COLOR_GREEN 		= $00
COLOR_BLUE 			= $80
COLOR_BACKGROUND	= $c0

clear		=	$FF

SPRITE_HEIGHT = 8
	
	org $800
	
cartridgeStart:
	.byte	$55					; valid cart indicator
	nop							; unused byte
	
cartridgeEntry:
	li $c6						; $21 - b/w palette, fill with black. $c6 - color palette, fill with gray
	lr 3, A						; clear screen to grey
	pi BIOS_CLEAR_SCREEN
	
	
	
	li COLOR_BACKGROUND
	lr 1, A			; Color
	li 20
	lr 2, A			; Start X
	li 20
	lr 3, A			; Start Y
	li 0
	lr 4, A			; "Clear" dino
	
	pi sprite.draw
	
	li COLOR_GREEN
	lr 1, A			; Color
	li 20
	lr 2, A			; Start X
	li 20
	lr 3, A			; Start Y
	li 1
	lr 4, A			; "Default" dino
	
	pi sprite.draw
	
	li COLOR_RED
	lr 1, A			; Color
	li 40
	lr 2, A			; Start X
	li 20
	lr 3, A			; Start Y
	li 2
	lr 4, A			; "Jump" dino
	
	pi sprite.draw


;---------------------------------------------------------------------------
; Draw Sprite 
;---------------------------------------------------------------------------
; draw a 8 x SPRITE_HEIGHT sprite from a data pointer
; r1 = color
; r2 = x (to screen)
; r3 = y (to screen)
; r4 = sprite number

sprite.draw:
	; blit reference:
	; r1 = color 1 (off)
	; r2 = color 2 (on)
	; r3 = x position
	; r4 = y position
	; r5 = width
	; r6 = height

	; get the tile address
	dci	sprites
	; add the offset
	lr	A, 4
	inc							; make sure we hit 0
	lr	0, A
	lis	2						; two bytes for each sprite
sprite.draw.addressLoop:
	ds	0
	bz	sprite.draw.addressLoop.end
	adc
	br	sprite.draw.addressLoop
sprite.draw.addressLoop.end:
	; load the address for this sprite's number
	lm
	lr	Qu, A
	lm
	lr	Ql, A
	lr	DC, Q
	
	; load the sprite size (8 x SPRITE_HEIGHT)
	lis	8
	lr	5, A
	lis	SPRITE_HEIGHT
	lr	6, A
	; load the position
	lr	A, 3
	lr	4, A
	lr	A, 2
	lr	3, A
	; load the colors
	lr	A, 1
	lr	2, A
	li	clear
	lr	1, A

	; draw the sprite
	jmp	blit

;===========================================================================
; Sprite Data
;===========================================================================

;---------------------------------------------------------------------------
; Sprite Array
;---------------------------------------------------------------------------

sprites:

	.word	gfx.clearSprite					; sprite 0
	
	.word	gfx.dino.default				; sprite 1
	.word	gfx.dino.jump					; sprite 2

;---------------------------------------------------------------------------
; Clear Sprite
;---------------------------------------------------------------------------

gfx.clearSprite:
	; 8x8 block to clear a drawn sprite
	.byte	%11111111
	.byte	%11111111
	.byte	%11111111
	.byte	%11111111
	.byte	%11111111
	.byte	%11111111
	.byte	%11111111
	.byte	%11111111

;---------------------------------------------------------------------------
; Dino Sprites
;---------------------------------------------------------------------------

gfx.dino:
	; Dino sprites

gfx.dino.default:
	.byte	%00011000
	.byte	%00011100
	.byte	%00010000
	.byte	%00111000
	.byte	%01010100
	.byte	%00010000
	.byte	%00101000
	.byte	%01000100
gfx.dino.jump:
	.byte	%00011000
	.byte	%00011100
	.byte	%10010010
	.byte	%01111100
	.byte	%00010000
	.byte	%00010000
	.byte	%00101000
	.byte	%01000100
	
	
;---------------;
; Blit Function ;
;---------------;
; this function blits a graphic based on parameters set in r1-r6,
; and the graphic data pointed to by DC0, onto the screen
;
; originally from cart 26, modified and annotated
; uses r1-r9, K, Q
;
; r1 = color 1 (off)
; r2 = color 2 (on)
; r3 = x position
; r4 = y position
; r5 = width
; r6 = height (and vertical counter)
;
; r7 = horizontal counter
; r8 = graphics byte
; r9 = bit counter
;
; DC = pointer to graphics

blit:
	; adjust the x coordinate
	lis	4
	as	3
	lr	3, A
	; adjust the y coordinate
	lis	4
	as	4
	lr	4, A

	lis	1
	lr	9, A						; load #1 into r9 so it'll be reset when we start
	lr	A, 4						; load the y offset
	com							; invert it
blit.row:
	outs	5						; load accumulator into port 5 (row)

	; check vertical counter
	ds	6						; decrease r6 (vertical counter)
	bnc	blit.exit					; if it rolls over exit

	; load the width into the horizontal counter
	lr	A, 5
	lr	7, A

	lr	A, 3						; load the x position
	com							; complement it
blit.column:
	outs	4						; use the accumulator as our initial column
	; check to see if this byte is finished
	ds	9						; decrease r9 (bit counter)
	bnz	blit.drawBit					; if we aren't done with this byte, branch

blit.getByte:
	; get the next graphics byte and set related registers
	lis	8
	lr	9, A						; load #8 into r9 (bit counter)
	lm
	lr	8, A						; load a graphics byte into r8

blit.drawBit:
	; shift graphics byte
	lr	A, 8						; load r8 (graphics byte)
	as	8						; shift left one (with carry)
	lr	8, A						; save it

	; check color to use
	lr	A, 2						; load color 1
	bc	blit.savePixel					; if this bit is on, draw the color
	lr	A, 1						; load color 2
blit.savePixel:
	inc
	bc	blit.checkColumn				; branch if the color is "clear"
	outs	1						; output A in p1 (color)

blit.transferData:
	; transfer the pixel data
	li	$60
	outs	0
	li	$40
	outs	0


	; and delay a little bit
; =============================================================================
; 
; The original delay was 35.5 cycles:
;
;	Acumulator was $C0
;
;blit.savePixelDelay:
; 	ai	$60
;	bnz	blit.savePixelDelay				; small delay
;
;
;	 9 cycle delay works on old NTSC system
;	 8 is to little.  (tested by e5frog)
;
;
;	jmp	blit.savePixelDelay				; 5.5 cycles
;blit.savePixelDelay:
;	br	blit.checkColumn				; 3.5 cycles
;
;
;	 PAL system works at a higher clock rate than NTSC-ones and requires longer delay
;        12.5 cycles is sufficient, 12 is too little


	lis	2
blit.savePixelDelay:
	ai	$ff
	bnz	blit.savePixelDelay

blit.checkColumn:
	ds	7						; decrease r7 (horizontal counter)
	bz	blit.checkRow					; if it's 0, branch

	ins	4						; get p4 (column)
	ai	$ff						; add 1 (complemented)
	br	blit.column					; branch

blit.checkRow:
	ins	5						; get p5 (row)
	ai	$ff						; add 1 (complemented)
	br	blit.row					; branch

blit.exit:
	; return from the subroutine
	pop