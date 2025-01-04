*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
            INCLUDE "P.X68"
            
SCRWIDTH    EQU     640
SCRHEIGH    EQU     480
SQUARESZ    EQU     32
CALTURA     EQU     20
CANCHURA    EQU     100
XCENTER     DS.W    1
YCENTER     DS.W    1
MOVIMIENTO  DS.W    1
SCRINTCT    DS.B    1                       ; INTERRUPT COUNTER
            DS.W    0
START:                  ; first instruction of program

; --- INITIALIZATION -----------------------------------------------------------
    ORI.W   #$0700,SR             ;DISABLE ALL INT
    JSR     SYSINIT
    JSR     PINIT
    TRAP #1

.BUCLE
; --- UPDATE -------------------------------------------------------------------

    JSR     PUPDATE

; --- SYNC ---------------------------------------------------------------------

.WINT       TST.B   (SCRINTCT)
            BEQ     .WINT
            CLR.B   (SCRINTCT)


; --- PLOT ---------------------------------------------------------------------

    TRAP #0
    TRAP #1
    BRA .BUCLE
* Put program code here

    SIMHALT             ; halt simulator

SYSINIT
; INITIALIZE SYSTEM.
; INPUT    : NONE
; OUTPUT   : NONE
; MODIFIES : NONE
; ------------------------------------------------------------------------------
            MOVE.L  #SCRTIM,($64)
            MOVE.L  #SCRPLOT,($80)
            MOVE.L  #PPLOT, ($84)         ; INSTALA TRAP 1 A DIBUJAR PLATAFORMA

            JSR     SCRINIT

            
            MOVE.W  SR,-(A7)
            ANDI.W  #$D8FF,(A7)
            RTE
            
            
; ------------------------------------------------------------------------------
SCRPLOT
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
; ------------------------------------------------------------------------------
SCRTIM
; TIMED INTERRUPT SERVICE ROUTINE
; INPUT    : NONE
; OUTPUT   : NONE
; MODIFIES : NONE
; ------------------------------------------------------------------------------
            ADDQ.B  #1,(SCRINTCT)
            RTE

SCRINIT
; INIT SCREEN. SET SCREEN RESOLUTION, SET WINDOWED MODE, CLEAR SCREEN,
; ENABLE DOUBLE BUFFER, ENABLE TIMED INTERRUPT.
; INPUT    : NONE
; OUTPUT   : NONE
; MODIFIES : NONE
; ------------------------------------------------------------------------------

            MOVEM.L D0-D1,-(A7)

            ; SET SCREEN RESOLUTION
            MOVE.B  #33,D0
            MOVE.L  #SCRWIDTH<<16|SCRHEIGH,D1
            TRAP    #15
            
            ; SET WINDOWED MODE
            MOVE.L  #1,D1
            TRAP    #15
            
            ; CLEAR SCREEN
            MOVE.B  #11,D0
            MOVE.W  #$FF00,D1
            TRAP    #15
            
            ; ENABLE DOUBLE BUFFER
            MOVE.B  #92,D0
            MOVE.B  #17,D1
            TRAP    #15
            
            ; ENABLE TIMED INTERRUPT
            MOVE.B  #32,D0
            MOVE.B  #6,D1
            MOVE.B  #$81,D2
            MOVE.L  #20,D3
            TRAP    #15
            
            ; CLEAR INTERRUPT COUNTER
            CLR.B   (SCRINTCT)
            
            MOVEM.L (A7)+,D0-D1
            
            RTS 
            
; ------------------------------------------------------------------------------
DIBUJARC
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

; ------------------------------------------------------------------------------
    END    START        ; last line of source
*~Font name~Fixedsys~
*~Font size~9~
*~Tab type~1~
*~Tab size~4~

*~Font name~Fixedsys~
*~Font size~9~
*~Tab type~1~
*~Tab size~4~
