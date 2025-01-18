; ==============================================================================
; PLATAFORMA MANAGEMENT


; ==============================================================================
            
; ------------------------------------------------------------------------------
PINIT
; INITIALIZE PLATAFORMA.
; INPUT    : NONE 
; OUTPUT   : NONE
; MODIFIES : XCENTER, YCENTER, MOVIMIENTO
; ------------------------------------------------------------------------------
    MOVE.W  #SCRHEIGH/2, (YCENTER)          ;INICIALIZAR COORDENADAS DE PLATAFORMA
    MOVE.W  #SCRWIDTH/2, (XCENTER)
    MOVE.W  #1, MOVIMIENTO
    RTS

PUPDATE
; UPDATE PLATAFORMA COORDENADES, SI CHOCA CONTRA PARED, NEGAR A MOVIMIENTO PARA ACTUALIZAR LA COORDENADA
; INPUT    : NONE
; OUTPUT   : NONE
; MODIFIES : XCENTER
; ------------------------------------------------------------------------------
    
    MOVEM.W D0-D1,-(A7)

    MOVE.W (XCENTER), D5
    ADD.W    (MOVIMIENTO),D5
    ; COMPARA SI CHOCA PARED :( CMP B,A
    ; SI A<B PUES NADA A DIBUJAR EN AUX
    CMP.W   #SCRWIDTH, D5
    BLO .UPAUX
    NEG.W   (MOVIMIENTO)
    ADD.W   (MOVIMIENTO),D5

.UPAUX
    MOVE.W  D5, (XCENTER)
    
    MOVEM.W (A7)+,D0-D1

    RTS

PPLOT
; DIBUJAR UN RECTANGULO, altura 40, ancho 100
; Draw rectangle defined by (Left X, Upper Y, Right X, Lower Y).  
; where LX = D1.W, UY = D2.W, RX = D3.W, LY = D4.W 
; The rectangle is drawn using pen color and filled using fill color.
; Input    - XCENTER Y YCENTER
; Output   - None
; Modifies - Nothing
; -----------------------------------------------------------------------------

            MOVEM.L D0-D7, -(A7)
            
            MOVE.B  #81,D0                  ;-------- COLORES
            MOVE.L  #$00800000,D1
            TRAP    #15
            MOVE.B  #80,D0                  
            MOVE.L  #$00FFFFFF,D1
            TRAP    #15                     
            
            
            MOVE.W  (YCENTER),D2            ;-------- COORDENADAS Y
            SUB.W   #CALTURA/2,D2
            MOVE.W  D2,D4
            ADD.W   #CALTURA,D4
            
            MOVE.W  (XCENTER),D1            ;-------- COORDENADAS X
            SUB.W   #CANCHURA/2,D1
            MOVE.W  D1,D3
            ADD.W   #CANCHURA,D3
            
            MOVE.B  #87,D0                  ;-------- DIBUJAR
            TRAP    #15
            
            MOVEM.L (A7)+,D0-D7   
            
            RTE  
*~Font name~Fixedsys~
*~Font size~9~
*~Tab type~1~
*~Tab size~4~
