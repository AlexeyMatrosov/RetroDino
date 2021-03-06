;------------------------
; BIOS Calls
;------------------------

BIOS_CLEAR_SCREEN   = $00d0         ; uses r31
BIOS_DELAY          = $008f         ; r5 -- delay value

;------------------------
; Colors
;------------------------

COLOR_RED           = $40
COLOR_GREEN         = $00
COLOR_BLUE          = $80
COLOR_BACKGROUND    = $c0
COLOR_NONE         = $ff

; is used for BIOS_CLEAR_SCREEN (into r3)
COLOR_CLEAR_TO_GRAY     = $d6
COLOR_CLEAR_TO_GREEN    = $c0
COLOR_CLEAR_TO_BLUE     = $93
COLOR_CLEAR_TO_BW       = $21