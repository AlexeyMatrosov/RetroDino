
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

Y_START_POSITION = 25

X_REG			=	060		; #48
DINO_STATE_REG 	= 	061		; #49
	
	org $800
	
cartridgeStart:
	.byte	$55					; valid cart indicator
	nop							; unused byte
	
cartridgeEntry:
	li $c6						; $21 - b/w palette, fill with black. $c6 - color palette, fill with gray
	lr 3, A						; clear screen to grey
	pi BIOS_CLEAR_SCREEN
	
	li 30
	SETISAR X_REG
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
	SETISAR X_REG
	lr A, S
	inc
	lr S, A
	
	jmp _endloop	
	
_leftclicked:

	; Left clicked
	SETISAR X_REG
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
	
	pi draw_player
	pi small_delay
	
	jmp mainloop

draw_player:
	lr k, p
	
	li COLOR_GREEN
	lr 1, A			; Color
	SETISAR X_REG
	lr A, S			; Start X
	lr 2, A
	li Y_START_POSITION
	lr 3, A			; Start Y
	
	SETISAR DINO_STATE_REG
	lr A, S
	ni %00000001
	inc
	lr 4, A			; Select Dino sprite
	
	pi sprite.draw
	
	pk
	
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