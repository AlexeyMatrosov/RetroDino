
	processor F8
	
BIOS_CLEAR_SCREEN   = $00d0        ; uses r31
	
COLOR_RED 			= $40
COLOR_GREEN 		= $00
COLOR_BLUE 			= $80
COLOR_BACKGROUND	= $c0

clear		=	$FF
	
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
	include "drawing.inc"	; basic drawing functions
	
	include "graphics.inc"	; graphic data