;-------------------------
; SETISAR
; Original Author: Blackbird
; Sets the ISAR to a register number, using lisu and lisl

	MAC SETISAR
	lisu	[[{1}] >> 3]
	lisl	[[{1}] & %111]
	ENDM