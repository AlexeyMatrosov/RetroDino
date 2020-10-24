
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

clear		=	$FF

CACTUS_X_REG		= 	050		; #40
BIRD_X_REG			= 	051		; #41
DINO_Y_REG			=	060		; #48
DINO_STATE_REG 		= 	061		; #49


CLOCK_DINO_ANIMATION_REG 	= 062		; #50
CLOCK_DINO_MOVE_REG			= 063		; #51
CLOCK_FIELD_REG				= 064		; #52
CLOCK_BIRD_REG				= 065		; #53

; Set real data
TIMING_DINO_ANIMATION	= 3
TIMING_DINO_MOVE		= 10
TIMING_FIELD			= 2
TIMING_BIRD				= 1
	
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
	
	li TIMING_DINO_ANIMATION
	SETISAR CLOCK_DINO_ANIMATION_REG
	lr S, A
	
	li TIMING_FIELD
	SETISAR CLOCK_FIELD_REG
	lr S, A
	
	li TIMING_BIRD
	SETISAR CLOCK_BIRD_REG
	lr S, A
	
	li 110
	SETISAR CACTUS_X_REG
	lr S, A
	
	li 110
	SETISAR BIRD_X_REG
	lr S, A
	
	pi drawGround				; Draw game ground
	pi drawSky					; Draw game sky
	
mainloop:

	clr
	outs	0
	outs	1
	
	; DRAWING
	
	; Dino 
	SETISAR DINO_Y_REG
	lr A, S			
	lr 1, A			; Dino y
	
	SETISAR DINO_STATE_REG
	lr A, S
	ni %00000001
	lr 2, A			; Select Dino sprite
	
	pi drawDino
	
	; Draw cactus 0
	
	SETISAR CACTUS_X_REG
	lr A, S
	lr 1, A
	
	li 2
	lr 2, A
	
	pi drawCactus
	
	; Draw bird
	
	SETISAR BIRD_X_REG
	lr A, S
	lr 1, A
	
	li 5
	lr 2, A
	
	;pi drawBird
	
	; LOGIC
	pi processDinoAnimationClock
	pi processDinoMoveClock
	pi processFieldClock
	pi processBirdClock
	
	;ins	1
	;com							; un-invert port data
	;ni	%00000011				; only keep push/pull
	;bz	_endloop
	
	;ni %00000010
	;bnz _leftclicked
	
	; Right clicked
	;SETISAR DINO_Y_REG
	;lr A, S
	;inc
	;lr S, A
	
	;jmp _endloop	
	
_leftclicked:

	; Left clicked
	;SETISAR DINO_Y_REG
	;lr A, S
	;lr 2, A
	;ds 2
	;lr A, 2
	;lr S, A

	;jmp _endloop
	
_endloop:

	jmp mainloop

;---------------------------------------------------------------------------
; Handle Dino animation
;---------------------------------------------------------------------------
processDinoAnimationClock:
	SETISAR CLOCK_DINO_ANIMATION_REG
	lr A, S
	lr 1, A
	
	ds 1
	lr A, 1
	lr S, A
	bnz _processDinoAnimationClockEnd
	
	; Reset timing
	li TIMING_DINO_ANIMATION
	lr S, A
	
	; Update when timer is 0
	SETISAR DINO_STATE_REG
	lr A, S
	inc
	lr S, A
	
_processDinoAnimationClockEnd:
	pop
	
;---------------------------------------------------------------------------
; Handle Dino moves
;---------------------------------------------------------------------------
processDinoMoveClock:

	pop
	
;---------------------------------------------------------------------------
; Handle Field updates
;---------------------------------------------------------------------------
processFieldClock:
	SETISAR CLOCK_FIELD_REG
	lr A, S
	lr 1, A
	
	ds 1
	lr A, 1
	lr S, A
	bnz _processFieldClockEnd
	
	; Reset timing
	li TIMING_FIELD
	lr S, A
	
	; Update when timer is 0
	SETISAR CACTUS_X_REG
	lr A, S
	lr 1, A
	ds 1
	lr A, 1
	lr S, A
	
_processFieldClockEnd:
	pop
	
processBirdClock:
	SETISAR CLOCK_BIRD_REG
	lr A, S
	lr 1, A
	
	ds 1
	lr A, 1
	lr S, A
	bnz _processBirdClockEnd
	
	; Reset timing
	li TIMING_BIRD
	lr S, A
	
	; Update when timer is 0
	SETISAR BIRD_X_REG
	lr A, S
	lr 1, A
	ds 1
	lr A, 1
	lr S, A
	
_processBirdClockEnd:
	pop

;---------------------------------------------------------------------------
	include "world.inc"		; world creation functions

	include "drawing.inc"	; basic drawing functions
	
	include "graphics.inc"	; graphic data