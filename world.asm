;===========================================================================
; Functions for World creation
;===========================================================================


;---------------------------------------------------------------------------
; Draw ground
;---------------------------------------------------------------------------
drawGround:
	lr k, p
	
	li GROUND_START_Y
	lr 5, A

_drawGround:
	lr A, 5
	lr 3, A

	li 0
	lr 1, A
	
	li 125
	lr 2, A
	
	pi point.draw
	
	li 0
	lr 1, A
	
	li 126
	lr 2, A
	
	pi point.draw
	
    lr A, 5
    inc
	lr 5, A
    ci GROUND_END_Y
	bnz _drawGround
	
	pk
	
;---------------------------------------------------------------------------
; Draw Dino sprite
;---------------------------------------------------------------------------

; r1 = sprite number
drawDino:
    ; Move sprite number to r4
    lr  A, 1
    lr  4, A
    
    ; Set background color (clear)
    li 	COLOR_BACKGROUND
	lr  7, A

	jmp _drawDinoSprite
    
; r1 = sprite number
drawDinoWithoutBackground:
    ; Move sprite number to r4
    lr  A, 1
    lr  4, A

    ; Set background color (clear)
    li 	COLOR_NONE
	lr  7, A

	jmp _drawDinoSprite
    
drawDinoBorder:
    ; Set sprite
    li  SPRITE_DINO_BORDER
    lr 4, A

    ; Set background color (clear)
    li 	COLOR_NONE
	lr  7, A

	jmp _drawDinoSprite
    
; r1 = color
; r4 = sprite number
_drawDinoSprite:
	lr 	k, p
    
    ; Set color
    li 	COLOR_BLUE
	lr  1, A
	
    ; Set x position (const)
	li 	DINO_X_POSITION
	lr 	2, A				
    
    ; Set y position (variable)
    SETISAR DINO_Y_REG
    lr  A, S			
    lr  3, A
	
    ; Set sprite width (const)
	li 	DINO_SPRITE_WIDTH
	lr 	5, A
	
    ; Set sprite height (const)
	li	DINO_SPRITE_HEIGHT
	lr	6, A
	
	; r1 = color
	; r2 = x (to screen)
	; r3 = y (to screen)
	; r4 = sprite number
	; r5 = width
	; r6 = height
	pi 	sprite.draw
	
	pk

;---------------------------------------------------------------------------
; Draw Cactus sprite
;---------------------------------------------------------------------------

; r1 = sprite number
drawCactus:

    ; Set x position (variable)
    SETISAR CACTUS_X_REG
	lr  A, S
	lr  2, A

    ; Move sprite number to r4
    lr  A, 1
    lr  4, A
    
    ; Set background color (clear)
    li 	COLOR_BACKGROUND
	lr  7, A

	jmp _drawCactusSprite
    
; r1 = sprite number
; r2 = x position
drawCactusInPosition:
    ; Move sprite number to r4
    lr  A, 1
    lr  4, A
    
    ; Set background color (clear)
    li 	COLOR_BACKGROUND
	lr  7, A

	jmp _drawCactusSprite
    
; r1 = sprite number
drawCactusWithoutBackground:

    ; Set x position (variable)
    SETISAR CACTUS_X_REG
	lr  A, S
	lr  2, A

    ; Move sprite number to r4
    lr  A, 1
    lr  4, A

    ; Set background color (clear)
    li 	COLOR_NONE
	lr  7, A

	jmp _drawCactusSprite
    
drawCactusBorder:

    ; Set x position (variable)
    SETISAR CACTUS_X_REG
	lr  A, S
	lr  2, A
    
    ; Set sprite
    li  SPRITE_CACTUS_BORDER
    lr  4, A

    ; Set background color (clear)
    li 	COLOR_NONE
	lr  7, A

	jmp _drawCactusSprite

; r1 = color
; r4 = sprite number
_drawCactusSprite:
	lr  k, p
    
    ; Set color
    li 	COLOR_GREEN
	lr  1, A
	
    ; Set y position (const)
	li 	CACTUS_Y_POSITION
	lr 	3, A
	
    ; Set sprite width (const)
	li	CACTUS_SPRITE_WIDTH
	lr	5, A
	
    ; Set sprite height (const)
	li	CACTUS_SPRITE_HEIGHT
	lr	6, A
	
	; r1 = color
	; r2 = x (to screen)
	; r3 = y (to screen)
	; r4 = sprite number
	; r5 = width
	; r6 = height
	pi 	sprite.draw
	
	pk

;---------------------------------------------------------------------------
; Draw Bird sprite
;---------------------------------------------------------------------------

; r1 = x (to screen)
; r2 = sprite number
drawBird:
	lr k, p
	
	; Variables
	
	lr A, 2
	lr 4, A					; Set sprite number
	
	lr A, 1
	lr 2, A					; Set x position
	
	; Consts
	
	li 	COLOR_BLUE
	lr 	1, A				; Set color
	
	li 	BIRD_Y_POSITION
	lr 	3, A				; Set x position
	
	li	BIRD_SPRITE_WIDTH
	lr	5, A				; Set sprite width
	
	li	BIRD_SPRITE_HEIGHT
	lr	6, A				; Set sprite height
	
	; r1 = color
	; r2 = x (to screen)
	; r3 = y (to screen)
	; r4 = sprite number
	; r5 = width
	; r6 = height
	pi 	sprite.draw
	
	pk