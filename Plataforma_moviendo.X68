*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description: syc BIEN, dibuja rectangulo y que este mueva, cambia de direccion si choca,
;              double buffer 
*-----------------------------------------------------------
    ORG    $1000
SCRWIDTH    EQU     640
SCRHEIGH    EQU     480
CALTURA     EQU     20
CANCHURA    EQU     100
PLATAFORMAX DS.W    3
PLATAFORMAY DS.W    3
XCENTER     DS.W    1
YCENTER     DS.W    1
MOV1        DS.W    1
MOV2        DS.W    1
MOV3        DS.W    1

SCRINTCT    DS.B    1                       ; INTERRUPT COUNTER
            DS.W    0

START:                  ; first instruction of program
    
            ;INICIALIZA EL VECTOR DE POSICIONES DE PLATAFORMAS
            LEA.L   PLATAFORMAX, A0
            LEA.L   PLATAFORMAY, A1
            MOVE.W  #60, (A0)+
            MOVE.W  #50, (A1)+
            MOVE.W  #SCRWIDTH/2, (A0)+
            MOVE.W  #SCRHEIGH/2, (A1)+
            MOVE.W  #550, (A0)+
            MOVE.W  #400, (A1)+

            CLR.B   (SCRINTCT)
            MOVE.L  #1,D1
            MOVE.B  #33,D0
            TRAP    #15                     ; ENSURE WINDOWED MODE
            MOVE.L  #SCRWIDTH<<16|SCRHEIGH,D1
            TRAP    #15                     ; SET RESOLUTION TO 640X480
            MOVE.L  #DIBUJARC, ($80)         ; INSTALA TRAP 0 A DIBUJA
            MOVE.L  #DIBUJARPANTALLA, ($84)  ; INSTALA DBUFFER MANAJAR A TRAP 1

            ;DIBUJAR POR PRIMERA VEZ
            MOVE.W  #2, D0
.1STDRAW            
            MOVE.W  -(A0),D5
            MOVE.W  -(A1),D6
            TRAP    #0         
            DBRA    D0, .1STDRAW
            
            ;INICIALIZAR MOV
            MOVE.L  #1, MOV1
            MOVE.L  #1, MOV2
            MOVE.L  #2, MOV3
            

            ;HABILITAR DOUBLE BUFFER
            MOVE.B  #92,D0
            MOVE.B  #17,D1
            TRAP    #15

            ; INSTALAR INTERUPCIÓN DE TIEMPO REAL
            MOVE.L  #SCRISR, ($64)          ; Instalar vector de interrupción de pantalla (Timer ISR)
            MOVE.B  #32,D0
            MOVE.B  #6,D1
            MOVE.B  #$81,D2
            MOVE.L  #20,D3
            TRAP    #15
;-------------------------SYNC-------------------------------

.LOOP      


            TST.B   (SCRINTCT)              ; Verifica si ocurrió la interrupción
            BEQ     .LOOP                   ; Si no, sigue esperando
            CLR.B   (SCRINTCT)              ; Limpia la bandera de interrupción
;-----------------------------------------------------------
            ;ADD.W    (MOVIMIENTO),D5
            ; ;COMPARA SI CHOCA PARED :( CMP B,A
            ; ;SI A<B PUES NADA A DIBUJAR EN AUX
            ;CMP.W   #SCRWIDTH, D5
            ;BLO .AUX
            ;NEG.W   (MOVIMIENTO)
            ;ADD.W   (MOVIMIENTO),D5
            MOVE.W  #2, D0
            LEA.L   MOV1, A0
            LEA.L   PLATAFORMAX, A1
.COMPARE_COLLISION
            MOVE.W  (A1),D5
            ADD.W   (A0),D5
            CMP.W   #SCRWIDTH, D5
            BLO .AUX
            NEG.W   (A0)
            ADD.W   (A0),D5
            MOVE.W D5, (A1)+
            ADDA.W #2, A0
            DBRA    D0, .COMPARE_COLLISION
           
.AUX            

            MOVEA.L #0, A0
            
            MOVE.W  PLATAFORMAX(A0),D5
            MOVE.W  PLATAFORMAY(A0),D6
            TRAP    #0
            
            ADDQ.L  #2,A0

            MOVE.W  PLATAFORMAX(A0),D5
            MOVE.W  PLATAFORMAY(A0),D6
            TRAP    #0
            
            ADDQ.L  #2,A0

            MOVE.W  PLATAFORMAX(A0),D5
            MOVE.W  PLATAFORMAY(A0),D6
            TRAP    #0
            
            TRAP    #1                      ; DBUFFER D:
            BRA     .LOOP
            
            
            
            
            


SIMHALT             ; halt simulator
    
    ; ------------------------------------------------------------------------------

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
            
            MOVE.B  #81,D0                  ;-------- COLORES
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
            

SCRISR
; Screen Interrupt Service Routine (ISR)
; This routine is triggered by a screen refresh interrupt and will update the interrupt flag.
; -----------------------------------------------------------------------------
            ADDQ.B  #1,(SCRINTCT)           ; Increment the interrupt counter
            RTE
    END    START        ; last line of source
