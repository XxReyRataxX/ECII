; ==============================================================================
; GAME VARIABLES
; ==============================================================================


; --- GAME STATE RELATED VARIABLES --------------------------------------------

STACUR      DS.W    1                       ; CURRENT GAME STATE
STANEXT     DS.W    1                       ; NEXT GAME STATE

; --- BALL RELATED VARIABLES ---------------------------------------------------

BALPOSX     DS.W    1                       ; BALL X COORDINATE
BALPOSY     DS.W    1                       ; BALL Y COORDINATE
BALVELX     DS.W    1                       ; BALL X VELOCITY
BALVELY     DS.W    1                       ; BALL Y VELOCITY

; --- PLAYER RELATED VARIABLES ------------------------------------------------

PLRPOSX     DS.W    1                       ; PLAYER X POSITION (PIXELS)
PLRPOSY     DS.W    1                       ; PLAYER Y POSITION (PIXELS)
PLRENER     DS.W    1                       ; PLAYER ENERGY
PLRDMG      DS.B    1                       ; BIT0: UPD DAMAGE, BIT1 PLOT DMG
            DS.W    0
            
; --- ESCUDO RELATED VARIABLES ----------------------------------------------------

ESCPOSX     DS.W 1                          ;POSICION Y ESCUDO
ESCPOSY     DS.W 1                          ;POSICION Y ESCUDO

; --- SCOREBOARD RELATED VARIABLES ---------------------------------------------

TIMER       DS.W 1                          ;TIMER JUEGO
POINT       DS.W 1                          ;PUNTOS CONSEGUIDOS     



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
