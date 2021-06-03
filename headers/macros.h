;-------------------------
; SETISAR
; Original Author: Blackbird
; Sets the ISAR to a register number, using lisu and lisl

	MAC SETISAR
	lisu	[[{1}] >> 3]
	lisl	[[{1}] & %111]
	ENDM
	
;-------------------------
; WAIT_OF N
; Wait N * ~100ms, using r1, r2, r3

	MAC WAIT_OF
	li {1}
	lr 1, A
__cycleLevel1:
		li 34
		lr 2, A
__cycleLevel2:
			li $FF
			lr 3, A
__cycleLevel3:	
			ds 3
			bnz __cycleLevel3
		ds 2
		bnz __cycleLevel2
	ds 1
	bnz __cycleLevel1

	ENDM