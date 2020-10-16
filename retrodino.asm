
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

SMALL_DELAY 		= 10 
clear		=	$FF

X_REG	=	060		; #48
	
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
	
	pi draw_player
	
mainloop:

	clr
	outs	0
	outs	1
	ins	1
	com							; un-invert port data
	ni	%00000011				; only keep push/pull
	bz	_nottouched
	
	ni %00000010
	bnz _leftclicked
	
	pi clear_player
	
	SETISAR X_REG
	lr A, S
	inc
	lr S, A
	
	pi draw_player
	pi small_delay

	jmp _nottouched	
	
_leftclicked:
	
	pi clear_player
	
	SETISAR X_REG
	lr A, S
	lr 2, A
	ds 2
	lr A, 2
	lr S, A
	;ds S
	
	pi draw_player
	pi small_delay

	jmp _nottouched
_nottouched:
	
	jmp mainloop
	
	
	; Not used
	
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
	
	SETISAR X_REG
	lr A, S			; Start X
	lr 2, A
	li 20
	lr 3, A			; Start Y
	li 2
	lr 4, A			; "Jump" dino
	
	pi sprite.draw
	
clear_player:
	lr k, p
	
	li COLOR_BACKGROUND
	lr 1, A			; Color
	SETISAR X_REG
	lr A, S			; Start X
	lr 2, A
	li 20
	lr 3, A			; Start Y
	li 0
	lr 4, A			; "Clear" dino
	
	pi sprite.draw
	
	pk
	
draw_player:
	lr k, p
	
	li COLOR_GREEN
	lr 1, A			; Color
	SETISAR X_REG
	lr A, S			; Start X
	lr 2, A
	li 20
	lr 3, A			; Start Y
	li 1
	lr 4, A			; "Default" dino
	
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
	include "drawing.inc"	; basic drawing functions
	
	include "graphics.inc"	; graphic data