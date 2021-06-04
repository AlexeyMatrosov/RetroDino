
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
    .byte   $55					; valid cart indicator
    nop							; unused byte
	
cartridgeEntry:
    ; Clear screen
    li  COLOR_CLEAR_TO_BLUE
    lr  3, A
    pi  BIOS_CLEAR_SCREEN
    
    ; Init ISAR
    SET_TO_ISAR 31, DINO_Y_REG
    SET_TO_ISAR TIMING_DINO_ANIMATION, CLOCK_DINO_ANIMATION_REG
    SET_TO_ISAR TIMING_DINO_MOVE, CLOCK_DINO_MOVE_REG
    SET_TO_ISAR TIMING_FIELD, CLOCK_FIELD_REG
    SET_TO_ISAR TIMING_BIRD, CLOCK_BIRD_REG
    SET_TO_ISAR CACTUS_START_POSITION, CACTUS_X_REG
    SET_TO_ISAR 110, BIRD_X_REG
    SET_TO_ISAR SPRITE_CACTUS_FIRST, CACTUS_CURRENT_SPRITE_REG
    SET_TO_ISAR DINO_JUMP_STATE_RUN, DINO_JUMP_STATE_REG
    SET_TO_ISAR 0, DINO_JUMP_COUNTER_REG

    ; Draw game ground 
    pi  drawGround
	
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
	
	li SPRITE_CACTUS_CLEAR
	lr 1, A
    
    clr
	lr  2, A
	
	pi drawCactusInPosition
	
_endclearcheck:
	
	; Dino 
	SETISAR DINO_STATE_REG
	lr A, S
	ni %00000001
	lr 1, A			; Select Dino sprite
	
	pi drawDino
	
	; Draw cactus 0
	
	SETISAR CACTUS_CURRENT_SPRITE_REG
	lr A, S
	lr 1, A
	
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
	ci SPRITE_CACTUS_LAST
	bnz _cactusSpriteEnd
	
	li SPRITE_CACTUS_FIRST
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
    li COLLISION_ANIMATION_CYCLES
    SETISAR GAME_OVER_CYCLE_REG
    lr S, A   
__blipBorderInCycle:
    
    ; Empty sprite (Dino)
	li  SPRITE_DINO_CLEAR
	lr  1, A			
	pi  drawDino
    
    ; Empty sprite (Cactus)
	li  SPRITE_CACTUS_CLEAR
	lr  1, A			
	pi  drawCactus
    
    ; Border without background
    pi  drawCactusBorder
    pi  drawDinoBorder
    
    ; Delay
    li  COLLISION_ANIMATION_DELAY
    lr  5, A
    pi  BIOS_DELAY
    
	; Empty sprite (Dino)
	li  SPRITE_DINO_CLEAR
	lr  1, A			
	pi  drawDino
    
    ; Empty sprite (Cactus)
	li  SPRITE_CACTUS_CLEAR
	lr  1, A			
	pi  drawCactus
    
    ; Cactus without background
    SETISAR CACTUS_CURRENT_SPRITE_REG
	lr  A, S
	lr  1, A
	pi  drawCactusWithoutBackground
    
    ; Dino without background
    SETISAR DINO_STATE_REG
	lr  A, S
	ni  %00000001
	lr  1, A
    pi  drawDinoWithoutBackground
    
    ; Delay
    li  COLLISION_ANIMATION_DELAY
    lr  5, A
    pi  BIOS_DELAY
    
    SETISAR GAME_OVER_CYCLE_REG
    lr A, S
    lr 1, A
    ds 1
    lr A, 1
	lr S, A
    bnz __blipBorderInCycle
    
	jmp cartridgeEntry

;---------------------------------------------------------------------------
	include "world.asm"		 ; world creation functions
	include "drawing.asm"	 ; basic drawing functions
	include "sprites.asm"	 ; graphic data
	include "collisions.asm" ; helper for collision detections