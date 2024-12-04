*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description: syc mal, dibuja rectangulo y que este mueva, cambia de direccion si choca,
;              double buffer 
*-----------------------------------------------------------
    ORG    $1000
SCRWIDTH    EQU     640
SCRHEIGH    EQU     480
SQUARESZ    EQU     32
CALTURA     EQU     20
CANCHURA    EQU     100
XCENTER     DS.W    1
YCENTER     DS.W    1
MOVIMIENTO  DS.W    1
START:                  ; first instruction of program

            MOVE.L  #1,D1
            MOVE.B  #33,D0
            TRAP    #15                     ; ENSURE WINDOWED MODE
            MOVE.L  #SCRWIDTH<<16|SCRHEIGH,D1
            TRAP    #15                     ; SET RESOLUTION TO 640X480
            MOVE.L  #DIBUJARC, ($80)         ; INSTALA TRAP 0 A DIBUJA
            MOVE.L  #DIBUJARPANTALLA, ($84)  ; INSTALA DBUFFER MANAJAR A TRAP 1
            MOVE.W  #SCRHEIGH/2, D6
            MOVE.W  #SCRWIDTH/2, D5
            TRAP    #0
            
            ;HABILITAR DOUBLE BUFFER
            MOVE.B  #92,D0
            MOVE.B  #17,D1
            TRAP    #15
            
.LOOP      

            ; THE FOLLOWING SYNC STRATEGY IS ****WRONG****
            MOVE.B  #23,D0
            MOVE.L  #1,D1
            TRAP    #15
            
            ADD.W    (MOVIMIENTO),D5
            ;COMPARA SI CHOCA PARED :( CMP B,A
            ;SI A<B PUES NADA A DIBUJAR EN AUX
            CMP.W   #SCRWIDTH, D5
            BLO .AUX
            NEG.W   (MOVIMIENTO)
            ADD.W   (MOVIMIENTO),D5
           
.AUX            
            TRAP    #0                      ;DIBUJA RECTANGULO
            TRAP    #1                      ;DBUFFER D:
            BRA     .LOOP
            
     

            
            
    SIMHALT             ; halt simulator
    
    ; -----------------------------------------------------------------------------



DIBUJARC
; DIBUJAR UN RECTANGULO, altura 40, ancho 100
; Draw rectangle defined by (Left X, Upper Y, Right X, Lower Y).  
; where LX = D1.W, UY = D2.W, RX = D3.W, LY = D4.W 
; The rectangle is drawn using pen color and filled using fill color.
; Input    - XCENTER Y YCENTER EN D5.W Y D6.W
;            D7.W: HORIZONTAL BORDER
; Output   - None
; Modifies - Nothing
; -----------------------------------------------------------------------------

            MOVEM.L D0-D7, -(A7)
            
            MOVE.B  #81,D0                  ;--------COLORES
            MOVE.L  #$00800000,D1
            TRAP    #15
            MOVE.B  #80,D0                  
            MOVE.L  #$00FFFFFF,D1
            TRAP    #15                     
            
            
            MOVE.W  D6,D2            ;-------- COORDENADAS Y
            SUB.W   #CALTURA/2,D2
            MOVE.W  D2,D4
            ADD.W   #CALTURA,D4
            
            MOVE.W  D5,D1            ;-------- COORDENADAS X
            SUB.W   #CANCHURA/2,D1
            MOVE.W  D1,D3
            ADD.W   #CANCHURA,D3
            
            MOVE.B  #87,D0                  ;-------- DIBUJAR
            TRAP    #15
            
            MOVEM.L (A7)+,D0-D7   
            
            RTE   

; ------------------------------------------------------------------------------
DIBUJARPANTALLA
; UPDATES DOUBLE BUFFER
; INPUT    : NONE
; OUTPUT   : NONE
; MODIFIES : NONE
; ------------------------------------------------------------------------------
            MOVEM.W D0-D1,-(A7)
            ; SWITCH BUFFERS
            MOVE.B  #94,D0
            TRAP    #15
            
            ; CLEAR HIDDEN BUFFER
            MOVE.B  #11,D0
            MOVE.W  #$FF00,D1
            TRAP    #15
            MOVEM.W (A7)+,D0-D1
            RTE       
            
            
            
            

            
* Put variables and constants here

    END    START        ; last line of source

