
	processor F8
	
;===========================================================================
; Headers
;===========================================================================

	include	"headers/macros.h"
	include "headers/system_const.h"
	include "headers/game_const.h"
	
;===========================================================================
; Program Entry
;===========================================================================

	org $800
	
cartridgeStart:
	.byte	$55					; valid cart indicator
	nop							; unused byte
	
cartridgeEntry:
	li $c6						; $c6 - color palette, fill with gray.
								; $d0 -- fill with green? If yes we can delete "drawGround" (~30b)
	lr 3, A						; clear screen to grey
	pi BIOS_CLEAR_SCREEN
	
	li 31
	SETISAR DINO_Y_REG
	lr S, A
	
	li TIMING_DINO_ANIMATION
	SETISAR CLOCK_DINO_ANIMATION_REG
	lr S, A
	
	li TIMING_DINO_MOVE
	SETISAR CLOCK_DINO_MOVE_REG
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
	
	li DINO_JUMP_STATE_RUN
	SETISAR DINO_JUMP_STATE_REG
	lr S, A
	
	li 0
	SETISAR DINO_JUMP_COUNTER_REG
	lr S, A
	
	pi drawGround				; Draw game ground
	pi drawSky					; Draw game sky
	
mainloop:

	clr
	outs	0
	outs	1
	
	; INPUT
	SETISAR DINO_JUMP_STATE_REG
	lr A, S
	ci DINO_JUMP_STATE_RUN
	bnz _inputChecksEnd
	
	ins	1
	com							; un-invert port data
	ni	%00001000				; top
	bz _inputChecksEnd
	
	; Start jump
	li DINO_JUMP_STATE_UP
	lr S, A
	
_inputChecksEnd:
	
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
	
	; COLLISION CHECKS
	
	; Dino x position
	li DINO_X_POSITION
	lr 1, A
	
	; Dino y position
	SETISAR DINO_Y_REG
	lr A, S			
	lr 2, A
	
	; Dino width
	li DINO_SPRITE_WIDTH
	lr 3, A
	
	; Dino height
	li DINO_SPRITE_HEIGHT
	lr 4, A
	
	; Cactus x position
	SETISAR CACTUS_X_REG
	lr A, S
	lr 5, A
	
	; Cactus y position
	li CACTUS_Y_POSITION
	lr 6, A
	
	; Cactus width
	li CACTUS_SPRITE_WIDTH
	lr 7, A
	
	; Cactus height
	li CACTUS_SPRITE_HEIGHT
	lr 8, A
	
	pi checkCollision
	
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
	
	SETISAR DINO_JUMP_STATE_REG
	lr A, S
	ci DINO_JUMP_STATE_RUN
	bnz _processDinoAnimationClockEnd
	
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
	SETISAR CLOCK_DINO_MOVE_REG
	lr A, S
	lr 1, A
	
	ds 1
	lr A, 1
	lr S, A
	bnz _processDinoMoveClockEnd
	
	; Reset timing
	li TIMING_DINO_MOVE
	lr S, A
	
	; Update when timer is 0 && state != DINO_JUMP_STATE_RUN
	SETISAR DINO_JUMP_STATE_REG
	lr A, S
	ci DINO_JUMP_STATE_RUN
	bz _processDinoMoveClockEnd
	
	lr A, S
	ci DINO_JUMP_STATE_UP
	bnz __processDinoMoveShouldDown
	
	; Top movement
	SETISAR DINO_Y_REG
	lr A, S
	lr 1, A
	ds 1
	lr A, 1
	lr S, A
	
	SETISAR DINO_JUMP_COUNTER_REG
	lr A, S
	inc 
	lr S, A
	
	ci DINO_JUMP_HEIGHT
	bnz _processDinoMoveClockEnd
	
	SETISAR DINO_JUMP_STATE_REG
	li DINO_JUMP_STATE_DOWN
	lr S, A
	
	jmp _processDinoMoveClockEnd
	
__processDinoMoveShouldDown:
	; Bottom movement
	SETISAR DINO_Y_REG
	lr A, S
	inc
	lr S, A
	
	SETISAR DINO_JUMP_COUNTER_REG
	lr A, S
	lr 1, A
	ds 1
	lr A, 1
	lr S, A
	
	ci 0
	bnz _processDinoMoveClockEnd
	
	SETISAR DINO_JUMP_STATE_REG
	li DINO_JUMP_STATE_RUN
	lr S, A
	
_processDinoMoveClockEnd:
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
; Game over handler
;---------------------------------------------------------------------------
handleGameOver:
	WAIT_OF 20		; Wait around 2 seconds
	jmp cartridgeEntry

;---------------------------------------------------------------------------
	include "world.asm"		 ; world creation functions
	include "drawing.asm"	 ; basic drawing functions
	include "graphics.asm"	 ; graphic data
	include "collisions.asm" ; helper for collision detections