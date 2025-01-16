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

            MOVEM.W D0-D2,-(A7)
            
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
            BRA     .PLRCOLISION
            
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
            BRA     .PLRCOLISION
            
            ; TOP COLLISION
.COLTOP      NEG.W   6(A0)
            MOVE.W  #BALRAD,D1
            BRA .PLRCOLISION
            
.PLRCOLISION
            ; STORE BALL COORDINATES 
            MOVE.W  D0,(A0)
            MOVE.W  D1,2(A0)
            
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
            
            SUB.W   #BALRAD,D0
            SUB.W   #BALRAD,D1
            
            MOVE.W (PLRPOSX),D2
            MOVE.W (PLRPOSY),D3
            
            MOVE.W #BALRAD*2,D4
            MOVE.W #PLRWIDTH,D5
           
            MOVE.W #BALRAD*2,D6
            MOVE.W #PLRHEIGH,D7
            
            JSR     UTLCHCOL
            TST.B   D0
            BEQ     .DONE
            JSR     AGLKILL
           
            
            
            


            


            
.DONE
            MOVEM.W (A7)+,D0-D2
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
