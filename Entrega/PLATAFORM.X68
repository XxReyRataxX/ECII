; ==============================================================================
; PLATAFORMA MANAGEMENT
;X CENTER: (A0)
;Y CENTER: 2(A0)
;MOVX:     4(A0)
;MOVY:     6(A0)
; ==============================================================================
            
; ------------------------------------------------------------------------------
PINIT
; INITIALIZE PLATAFORMA.
; INPUT    : NONE 
; OUTPUT   : NONE
; MODIFIES : XCENTER, YCENTER, MOVIMIENTO
; ------------------------------------------------------------------------------
    MOVE.W  #100, (A0)          ;INICIALIZAR COORDENADAS DE PLATAFORMA
    MOVE.W  #350, 2(A0)
    MOVE.W  #1, 4(A0)
    MOVE.W  #1, 6(A0)
    RTS
; ------------------------------------------------------------------------------
PINIT1
; INITIALIZE PLATAFORMA.
; INPUT    : NONE 
; OUTPUT   : NONE
; MODIFIES : XCENTER, YCENTER, MOVIMIENTO
; ------------------------------------------------------------------------------
    MOVE.W  #100, (A0)          ;INICIALIZAR COORDENADAS DE PLATAFORMA
    MOVE.W  #250, 2(A0)
    MOVE.W  #1, 4(A0)
    MOVE.W  #1, 6(A0)
    RTS
PUPDATE
; UPDATE PLATAFORMA COORDENADES, SI CHOCA CONTRA PARED, NEGAR A MOVIMIENTO PARA ACTUALIZAR LA COORDENADA
; INPUT    : NONE
; OUTPUT   : NONE
; MODIFIES : XCENTER
; ------------------------------------------------------------------------------
    
    MOVEM.W D0-D5,-(A7)

    MOVE.W (A0),D0
    MOVE.W  2(A0),D1
    
    ADD.W   4(A0),D0
    
    ; COMPARA SI CHOCA PARED :( CMP B,A
    ; SI A<B PUES NADA A DIBUJAR EN AUX
    CMP.W   #SCRWIDTH, D0
    BLO .UPAUX
    NEG.W   4(A0)
    ADD.W   4(A0),D0
    BRA .F
.UPAUX
    MOVE.W  D0, (A0) 
.F          
            ;MIRAMOS SI HAY COLISIONES EN LA PARTE SUPERIOR
                        
            ; CHECKS COLLISION
; INPUT    - D0.W X0 COORDINATE
;            D1.W Y0 COORDINATE
;            D2.W X1 COORDINATE
;            D3.W Y1 COORDINATE
;            D4.W WIDTH 0
;            D5.W WIDTH 1
;            D6.W HEIGHT 0
;            D7.W HEIGHT 1
; OUTPUT   - D0.B=FF - COLLISION, =0 - NO COLLISION

            SUB.W #CALTURA/2,D1
            SUB.W #CANCHURA/2,D0
            
            MOVE.W (PLRPOSX),D2
            MOVE.W (PLRPOSY),D3
            ADD.W   #PLRHEIGH,D3
            MOVE.W #CANCHURA,D4
            MOVE.W #PLRWIDTH,D5
           
            MOVE.W #10,D6
            MOVE.W #5,D7
            
            JSR     UTLCHCOL
            
            
            CMP.B   #$FF,D0
            BNE .FIN
            MOVE.W  2(A0),(PLRPOSY)
            SUB.W   #CALTURA/2,(PLRPOSY)
            SUB.W   #PLRHEIGH,(PLRPOSY)
            MOVE.W  #GRAVEDAD,(VGRAVEDAD)
            BRA     .FIN
            
    
.FIN   
    
    MOVEM.W (A7)+,D0-D5

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
            MOVE.B  #80,D0                  
            MOVE.L  #$00FFFFFF,D1
            TRAP    #15
            MOVE.B  #81,D0                  ;-------- COLORES
            MOVE.L  #$00800000,D1
            TRAP    #15
                                 
            
            
            MOVE.W  2(A0),D2            ;-------- COORDENADAS Y
            SUB.W   #CALTURA/2,D2
            MOVE.W  D2,D4
            ADD.W   #CALTURA,D4
            
            MOVE.W  (A0),D1            ;-------- COORDENADAS X
            SUB.W   #CANCHURA/2,D1
            MOVE.W  D1,D3
            ADD.W   #CANCHURA,D3
            
            MOVE.B  #87,D0                  ;-------- DIBUJAR
            TRAP    #15
            
            MOVEM.L (A7)+,D0-D7   
            
            RTS 


