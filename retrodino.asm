
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

CACTUS_CLEAR_FLAG_REG	= 052	; #42
CACTUS_CURRENT_SPRITE_REG	= 053	;#43

DINO_Y_REG			=	060		; #48
DINO_STATE_REG 		= 	061		; #49


CLOCK_DINO_ANIMATION_REG 	= 062		; #50
CLOCK_DINO_MOVE_REG			= 063		; #51
CLOCK_FIELD_REG				= 064		; #52
CLOCK_BIRD_REG				= 065		; #53

; Set real data
TIMING_DINO_ANIMATION	= 2
TIMING_DINO_MOVE		= 10
TIMING_FIELD			= 1
TIMING_BIRD				= 1

CACTUS_START_POSITION 		= 110
CACTUS_SPRITE_INDEX_START 	= 3
CACTUS_SPRITE_INDEX_END 	= 6
	
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
	
	li CACTUS_START_POSITION
	SETISAR CACTUS_X_REG
	lr S, A
	
	li 110
	SETISAR BIRD_X_REG
	lr S, A
	
	li CACTUS_SPRITE_INDEX_START
	SETISAR CACTUS_CURRENT_SPRITE_REG
	lr S, A
	
	pi drawGround				; Draw game ground
	pi drawSky					; Draw game sky
	
mainloop:

	clr
	outs	0
	outs	1
	
	; LOGIC
	pi processDinoAnimationClock
	pi processDinoMoveClock
	pi processFieldClock
	pi processBirdClock
	
	; DRAWING
	
	; Clear cactus if need
	SETISAR CACTUS_CLEAR_FLAG_REG
	lr A, S
	ci 1
	bnz _endclearcheck
	
	clr
	lr S, A
	
	lr 1, A
	
	li 2
	lr 2, A
	
	pi drawCactus
	
_endclearcheck:
	
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
	
	SETISAR CACTUS_CURRENT_SPRITE_REG
	lr A, S
	lr 2, A
	
	pi drawCactus
	
	; Draw bird
	
	SETISAR BIRD_X_REG
	lr A, S
	lr 1, A
	
	li 6
	lr 2, A
	
	;pi drawBird
	
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
	
	; Check if cactus is out of screen
	lr A, 1
	ci $fa
	bnz _cactusUpdateEnd
	
	SETISAR CACTUS_CLEAR_FLAG_REG
	li 1
	lr S, A
	
	SETISAR CACTUS_CURRENT_SPRITE_REG
	lr A, S
	inc
	lr S, A
	ci CACTUS_SPRITE_INDEX_END
	bnz _cactusSpriteEnd
	
	li CACTUS_SPRITE_INDEX_START
	lr S, A
	
_cactusSpriteEnd:
	
	li CACTUS_START_POSITION
	lr 1, A
	
_cactusUpdateEnd:
	SETISAR CACTUS_X_REG
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