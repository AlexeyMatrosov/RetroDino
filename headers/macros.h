;-------------------------
; SETISAR {N}
; Original Author: Blackbird
; Sets the ISAR to a register number, using lisu and lisl

	MAC SETISAR
	lisu	[[{1}] >> 3]
	lisl	[[{1}] & %111]
	ENDM	   
    
;-------------------------
; SET_TO_ISAR {VALUE}, {ISAR_NUMBER}
; Load value to ISAR regiser

	MAC SET_TO_ISAR
    li {1}
	SETISAR {2}
	lr S, A
	ENDM