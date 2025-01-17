*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
             INCLUDE "CONSTS.X68"
            INCLUDE "VARS.X68"
             INCLUDE "SYS.X68"
             INCLUDE "PLY.X68"
             INCLUDE "BALL.X68"
            INCLUDE "DMMCONST.X68"
            INCLUDE "DMMVARS.X68"
            
            INCLUDE "DMMCODE.X68"
            INCLUDE "UTLCODE.X68"
            INCLUDE "AGL.X68"
START:                  ; first instruction of program
           CLR.L VTIMER
           JSR DMMINIT
           JSR UTLINIT
           JSR SCRINIT
           JSR KBDINIT
           ;JSR BALINIT
           MOVE.W #10,(SEGUNDOS)
           JSR PLRINIT
           JSR MOUSEINIT
           LEA BALINIT,A1
           LEA BALUPD, A2
           LEA BALPLOT,A3
           
           MOVE.W #1,D0
           JSR  AGLADD
           
           CLR (SHIELDENA)
           CLR (LASTSHIELDENA) ;e
           CLR (SHIELDINICIO) 

           
           CLR.L D2
.LOOP       
            TRAP   #MOUSETRAP
	TRAP   #KBDTRAP                ; READ KEYBOARD
	JSR     AGLUPD
            JSR     PLRUPD
            
            JSR     AGLPLOT
            JSR     DIBUJAR
            MOVE.W (SEGUNDOS),D4
            MOVE.W  (VTIMER),D5
            CMP     D4,D5
            BNE     .WINT
            LEA BALINIT,A1
            LEA BALUPD, A2
            LEA BALPLOT,A3
            MOVE.W #1,D0
            JSR      AGLADD
            ADD.W   #10,(SEGUNDOS)
          
           
           
            
.WINT       TST.B   (SCRINTCT)              ; WAIT FOR INTERRUPT
            BEQ     .WINT
            CLR.B   (SCRINTCT)
            CLR.L D6
            MOVE.B (SCRCYCCT),D6
            CMP #50,D6
            BNE .YA
            ADDQ.W #1,(VTIMER)
            CLR.B   (SCRCYCCT)
.YA           
            TRAP    #SCRTRAP                ; SHOW GRAPHICS                
            
            BRA .LOOP
    SIMHALT             ; halt simulator

           

    END    START        ; last line of source













