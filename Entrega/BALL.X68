; ==============================================================================
; BALL MANAGEMENT (AGENT)
; BALPOSX (W)  (A0)
; BALPOSY (W) 2(A0)
; BALVELX (W) 4(A0)
; BALVELY (W) 6(A0)
; ==============================================================================
            
; ------------------------------------------------------------------------------
BALINIT
; INITIALIZE BALL.
; INPUT    : A0 POINTER TO THE INSTANCE VARIABLES 
; OUTPUT   : NONE
; MODIFIES : NONE
; ------------------------------------------------------------------------------
            MOVEM.L D0-A2,-(A7),-(A7)
            CLR D2
            JSR     UTLRAND
            LEA     .VELVEC,A1
            LEA     .POSVEC,A2
            AND.L   #$0000000C,D0
            MOVE.L  (A2,D0),(A0)
            
            
            MOVE.W D0,D1  
            CLR.L D0
            JSR     UTLRAND
            BTST #0, D0        ; Comprueba el quinto bit (bit 4) de D0.
            BNE .BitIsClear     ; Salta si el quinto bit es 0.
            MOVE.W D1,D2
            CMP #12,D2
            BEQ .BitIsClear
            ADDQ.W #4,D1
            
.BitIsClear  
            
            MOVE.L  (A1,D1),4(A0)
            
            
            MOVEM.L (A7)+,D0-A2

            RTS

.VELVEC     DC.W    BALVEL,-BALVEL      ;0
            DC.W    BALVEL,BALVEL       ;4
            DC.W    -BALVEL,-BALVEL     ;8
            DC.W    -BALVEL,BALVEL          ;12
.POSVEC     DC.W    0,160     ;0
            DC.W    0,320       ;4
            DC.W    SCRWIDTH,160      ;8
            DC.W    SCRWIDTH,320       ;12

            
; ------------------------------------------------------------------------------
BALUPD
; UPDATES THE BALL.
; INPUT    : A0 POINTER TO THE INSTANCE VARIABLES  
; OUTPUT   : NONE
; MODIFIES : NONE
; ------------------------------------------------------------------------------

            MOVEM.W D0-D7,-(A7)
            
            ; UPDATE BALL COORDINATES
            MOVE.W  (A0),D0
            MOVE.W  2(A0),D1
            
            ADD.W   4(A0),D0
            ADD.W   6(A0),D1
            
            
          ; CHECK HORIZONTAL COLLISIONS
            CMP.W   #SCRWIDTH-BALRAD,D0
            BGT     .COLRGT
            CMP.W   #BALRAD,D0
            BLT     .COLLFT
            
            ; CHECK VERTICAL COLLISIONS
.CHKVERT    CMP.W   #SCRHEIGH-BALRAD,D1
            BGT     .COLBOT
            CMP.W   #BALRAD,D1
            BLT     .COLTOP
            BRA     .SHIELDCOLISION
            
            ; RIGHT SIDE COLLISION
.COLRGT     NEG.W   4(A0)
            MOVE.W  #SCRWIDTH-BALRAD,D0
            BRA     .CHKVERT
            
            ; LEFT SIDE COLLISION
.COLLFT     NEG.W   4(A0)
            MOVE.W #BALRAD,D0
            BRA     .CHKVERT

            ; BOTTOM COLLISION
.COLBOT     NEG.W   6(A0)
            MOVE.W  #SCRHEIGH-BALRAD,D1
            BRA     .SHIELDCOLISION
            
            ; TOP COLLISION
.COLTOP      NEG.W   6(A0)
            MOVE.W  #BALRAD,D1
            BRA .SHIELDCOLISION
            
.SHIELDCOLISION
            
            
            MOVE.W  D0,(A0)
            MOVE.W  D1,2(A0)
            
            SUB.W   #BALRAD,D0
            SUB.W   #BALRAD,D1
            MOVE.W D0,(BALPRV1)
            MOVE.W D1,(BALPRV2) ;guardar por si después miramos la del player
            
            ;MIRAMOS SI EL ESCUDO ESTÁ ACTIVO, para eso, dos comprobaciones
            ;1 (está el espacio presionado)?
            ;2(estamos en el tiempo disponible para la activación del mismo)?
            MOVE.B  #19,D0
            MOVE.L  #KBDSHIELD<<24,D1
            TRAP #15
            BTST #24,D1
            
            BEQ .PLRCOLISION ;No estamos presionando espacio, miramos si
            ;la bola toca al jugador
            
            ;¡HEMOS PRESIONADO ESPACIO!
            MOVE.W (SHIELDTIMEEN),D6
            MOVE.W (VTIMER),D7
            CMP D7,D6
            BLE .PLRCOLISION ;No estamos en el tiempo indicado
            
            CLR.L D6
            CLR.L D7           
             
            MOVE.W (BALPRV1),D0
            MOVE.W (BALPRV2),D1
            MOVE.W (PLRPOSX),D2
            SUB.W #15,D2
            
            MOVE.W (PLRPOSY),D3
            SUB.W #15,D3
       
            
            MOVE.W #BALRAD*2,D4
            MOVE.W #SHIELDATA,D5
            
            MOVE.W #BALRAD*2,D6
            MOVE.W #SHIELDATA,D7
            
            JSR     UTLCHCOL
            TST.B   D0
            BEQ     .DONE
            JSR     AGLKILL
            BRA .DONE
            
            
            


.PLRCOLISION
           
            
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
            
            MOVE.W   (BALPRV1),D0
            MOVE.W   (BALPRV2),D1
            
            MOVE.W (PLRPOSX),D2
            MOVE.W (PLRPOSY),D3
            
            MOVE.W #BALRAD*2,D4
            MOVE.W #PLRWIDTH,D5
           
            MOVE.W #BALRAD*2,D6
            MOVE.W #PLRHEIGH,D7
            
            JSR     UTLCHCOL
            TST.B   D0
            BEQ     .DONE
            ;GAME OVER
            ;DESHABILITAMOS EL DOUBLE BUFFER
            MOVE.W #16,D1
            MOVE.W #92,D0
            TRAP #15
            
            ;Clear Screen : Set D1.W to $FF00
            MOVE.W #11,D0
            MOVE.W #$FF00,D1
            TRAP #15
            
            
            MOVE.L #$00000000,D1
            MOVE.W #81,D0        ; SET FILL COLOR
            TRAP #15
            
            			
	MOVE.L #$000000FF,D1
            MOVE.W #80,D0        ; SET PEN COLOR
            TRAP #15

            
            LEA GAMEOVER1,A1
            MOVE.W #14,D0
            TRAP #15
           
            
            
            
            LEA GAMEOVER2,A1
            
            MOVE.W #14,D0
            TRAP #15
            
            LEA GAMEOVER3,A1
            MOVE.W #14,D0
            TRAP #15
            
            LEA GAMEOVER4,A1
            MOVE.W #14,D0
            TRAP #15
            
            LEA GAMEOVER5,A1
            MOVE.W #14,D0
            TRAP #15
            

            SIMHALT            
           
            
            
            


            


            
.DONE
            MOVEM.W (A7)+,D0-D7
            RTS

            
; ------------------------------------------------------------------------------
BALPLOT
; PLOT THE BALL.
; INPUT    : A0 POINTER TO THE INSTANCE VARIABLES 
; OUTPUT   : NONE
; MODIFIES : NONE
; ------------------------------------------------------------------------------
           MOVEM.L D0-D4,-(A7)
            ; UPDATE BALL COORDINATES
            
            ; UPDATE BALL COORDINATES
            
            
            ; SET PEN COLOR
            MOVE.B  #80,D0
            MOVE.L  #$00FF0000,D1
            TRAP    #15
            
            ; SET FILL COLOR
            MOVE.B  #81,D0
            MOVE.L  #$00FF0000,D1
            TRAP    #15
            
            ; DEFINE COORDINATES
            MOVE.W  (A0),D1
            SUB.W   #BALRAD,D1
            MOVE.W  2(A0),D2
            SUB.W   #BALRAD,D2
            MOVE.W  D1,D3
            ADD.W   #2*BALRAD,D3
            MOVE.W  D2,D4
            ADD.W   #2*BALRAD,D4
            
            ; DRAW CIRCLE
            MOVE.B  #88,D0
            TRAP    #15
            
            MOVEM.L (A7)+,D0-D4

            RTS





*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
