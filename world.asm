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

; r1 = y (to screen)
; r2 = sprite number
drawDino:
	lr 	k, p
	
	; Variables
	
	lr A, 1
	lr 3, A					; Set y position
	
	lr A, 2
	lr 4, A					; Set sprite number
	
	; Consts
	
	li 	COLOR_BLUE
	lr 	1, A				; Set color
	
	li 	DINO_X_POSITION
	lr 	2, A				; Set x position
	
	li 	DINO_SPRITE_WIDTH
	lr 	5, A				; Set sprite width
	
	li	DINO_SPRITE_HEIGHT
	lr	6, A				; Set sprite height
	
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

; r1 = x (to screen)
; r2 = sprite number
drawCactus:
	lr k, p
	
	; Variables
	
	lr A, 2
	lr 4, A					; Set sprite number
	
	lr A, 1
	lr 2, A					; Set x position
	
	; Consts
	
	li 	COLOR_GREEN
	lr 	1, A				; Set color
	
	li 	CACTUS_Y_POSITION
	lr 	3, A				; Set x position
	
	li	CACTUS_SPRITE_WIDTH
	lr	5, A				; Set sprite width
	
	li	CACTUS_SPRITE_HEIGHT
	lr	6, A				; Set sprite height
	
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