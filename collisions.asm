;===========================================================================
; Collision detections
;===========================================================================

; r1 = x position of first rectangle
; r2 = y position of first rectangle
; r3 = width of first rectangle
; r4 = height of first rectangle
; r5 = x position of second rectangle
; r6 = y position of second rectangle
; r7 = width of second rectangle
; r8 = height of second rectangle
checkCollision:
	; obj1.x + obj1.width >= obj2.x
	lr A, 1
	as 3
	com
	inc
	inc     ; Decrease second rectangle size (simplification of the game)
	as 5
	ni	%10000000
	bz __noCollision
	
	; obj1.x <= obj2.x + obj2.width)
	lr A, 5
	as 7
	com
	inc
	inc     ; Decrease second rectangle size (simplification of the game)
	as 1
	ni	%10000000
	bz __noCollision
	
	; (obj1.y + obj1.height >= obj2.y
	lr A, 2
	as 4
	com
	inc
	inc     ; Decrease second rectangle size (simplification of the game)
	as 6
	ni	%10000000
	bz __noCollision
	
	; obj1.y <= obj2.y + obj2.height
	lr A, 6
	as 8
	com
	inc
	inc     ; Decrease second rectangle size (simplification of the game)
	as 2
	ni	%10000000
	bz __noCollision
	
	jmp handleGameOver

__noCollision:
	pop