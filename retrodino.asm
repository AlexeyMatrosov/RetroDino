
	processor F8
	
;===========================================================================
; VES Header
;===========================================================================

	include	"ves.h"	
	
BIOS_CLEAR_SCREEN   = $00d0        ; uses r31
	
COLOR_RED 			= $40
COLOR_GREEN 		= $00
COLOR_BLUE 			= $80
COLOR_BACKGROUND	= $c0

SMALL_DELAY 		= 30 
clear		=	$FF

DINO_Y_REG			=	060		; #48
DINO_STATE_REG 		= 	061		; #49
	
	org $800
	
cartridgeStart:
	.byte	$55					; valid cart indicator
	nop							; unused byte
	
cartridgeEntry:
	li $c6						; $c6 - color palette, fill with gray.
								; $d0 -- fill with green? If yes we can delete "drawGround" (~30b)
	lr 3, A						; clear screen to grey
	pi BIOS_CLEAR_SCREEN
	
	li 24
	SETISAR DINO_Y_REG
	lr S, A
	
	pi drawGround				; Draw game ground
	pi drawSky					; Draw game sky
	
mainloop:

	clr
	outs	0
	outs	1
	ins	1
	com							; un-invert port data
	ni	%00000011				; only keep push/pull
	bz	_endloop
	
	ni %00000010
	bnz _leftclicked
	
	; Right clicked
	SETISAR DINO_Y_REG
	lr A, S
	inc
	lr S, A
	
	jmp _endloop	
	
_leftclicked:

	; Left clicked
	SETISAR DINO_Y_REG
	lr A, S
	lr 2, A
	ds 2
	lr A, 2
	lr S, A

	jmp _endloop
	
_endloop:
	
	SETISAR DINO_STATE_REG
	lr A, S
	inc
	lr S, A
	
	; Draw Dino
	
	SETISAR DINO_Y_REG
	lr A, S			
	lr 1, A			; Dino y
	
	SETISAR DINO_STATE_REG
	lr A, S
	ni %00000001
	lr 2, A			; Select Dino sprite
	
	pi drawDino
	
	; Draw cactus 0
	
	li 60
	lr 1, A
	
	li 2
	lr 2, A
	
	pi drawCactus
	
	; Draw cactus 1
	
	li 75
	lr 1, A
	
	li 3
	lr 2, A
	
	pi drawCactus
	
	; Draw cactus 2
	
	li 90
	lr 1, A
	
	li 4
	lr 2, A
	
	pi drawCactus
	
	; Draw bird
	
	li 70
	lr 1, A
	
	li 5
	lr 2, A
	
	pi drawBird
	
	pi small_delay
	
	jmp mainloop
	
; uses r8, A
small_delay:
	li SMALL_DELAY
	lr 8, A

_small_delay.next:
	
	li 128
_small_delay:	
	ai	$ff
	bnz	_small_delay
	
	ds 8
	bnz _small_delay.next
	
	pop

;---------------------------------------------------------------------------
	include "world.inc"		; world creation functions

	include "drawing.inc"	; basic drawing functions
	
	include "graphics.inc"	; graphic data