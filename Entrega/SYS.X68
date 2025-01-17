SCRISR
; SCREEN TIMER ISR. INCREASES THE INTERRUPT COUNTER AND UPDATES DOUBLE BUFFER.
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            ADDQ.B  #1,(SCRINTCT)           ; UPDATE INT FLAG/COUNTER
            ADDQ.B  #1,(SCRCYCCT)           ; UPDATE CYCLE COUNTER
            RTE
SCRINIT
            ORI.W   #$0700,SR               ; DISABLE ALL INT
            MOVE.L  #SCRUPD,($80+SCRTRAP*4) ; INSTALL TRAP
            MOVE.L  #SCRWIDTH<<16|SCRHEIGH,D1 ; SET RESOLUTION
            MOVE.B  #33,D0
            TRAP    #15
            MOVE.L  #1,D1                   ; SET WINDOWED MODE
            TRAP    #15
            MOVE.W  #$FF00,D1               ; CLEAR VISIBLE BUFFER
            MOVE.B  #11,D0
            TRAP    #15
            MOVE.B  #17,D1                  ; ENABLE DOUBLE BUFFER
            MOVE.B  #92,D0
            TRAP    #15
            MOVE.W  #$FF00,D1               ; CLEAR HIDDEN BUFFER
            MOVE.B  #11,D0
            TRAP    #15
            MOVE.L  #SCRISR,($64)       ; 60+SCRIRQ*4)  ; SET EXCEPTION VECTOR
            MOVE.B  #5,D1                   ; ENABLE EXCEPTION PROCESSING
            MOVE.B  #32,D0
            TRAP    #15
           ; ENABLE TIMED INTERRUPT
            MOVE.B  #32,D0
            MOVE.B  #6,D1
            MOVE.B  #$81,D2
            MOVE.L  #20,D3
            TRAP    #15
            
            
            CLR.B   (SCRINTCT)              ; PREPARE INTERRUPT FLAG
            CLR.B   (SCRCYCCT) 
            ANDI.W  #$F8FF,SR               ; ENABLE INTS            
            RTS 
* Put variables and constants here

KBDINIT     
    ; INITIALIZES THE SYSTEM VARIABLES KBDSYS AND KBDVAL
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            CLR.B   (KBDVAL)                    ; INIT VARS
            CLR.B   (KBDEDGE)
            
            MOVE.L  #KBDREAD, ($80+KBDTRAP*4)    ; INSTALL
            RTS

KBDREAD
; TRAP SERVICE ROUTINE.
; UPDATES THE SYSTEM VARIABLES KBDEDGE AND KBDVAL ACCORDING TO THE BITFIELD
; DESCRIBED IN SYSCONST. KBDVAL HOLDS THE CURRENT VALUES AND KBDEFGE HOLDS
; RISING EDGES FROM PREVIOUS CALL TO THE CURRENT ONE.
; INPUT    - NONE
; OUTPUT   - (KBDVAL) AND (KBDEDGE)
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D0-D7,-(A7)
            MOVE.B  #19,D0
            MOVE.L  #KBDDOWN<<24+KBDRIGHT<<16+KBDUP<<8+KBDLEFT,D1
            TRAP    #15
            BSR     .STORE                  ; STORE KEY UP,DOWN,LEFT AND RIGTH.
            MOVE.B  (KBDVAL),D0             ; COMPUTE EDGE.
            NOT.B   D0                      ; EDGE=NOT(PREVIOUS) AND CURRENT.
            AND.B   D2,D0
            MOVE.B  D2,(KBDVAL)             ; STORE VALUES (PRESS AND EDGE)
            MOVE.B  D0,(KBDEDGE)
            ;SHIELD
            
            MOVE.B  #19,D0
            MOVE.L  #KBDSHIELD<<24,D1
            TRAP #15
            BTST #24,D1

            
            BNE .SHIELDPLOT
.RETURN
            MOVEM.L (A7)+,D0-D7
            RTE

.STORE      MOVE.W  #3,D3                   ; TRANSLATES THE 8-BIT ENCODING
.LOOP       LSL.L   #8,D1                   ; OF TRAP #15 TASK 19 INTO A 1-BIT
            ROXL.B  #1,D2                   ; PER KEYPRESS ENCODING
            DBRA.W  D3,.LOOP
            RTS
           
           



            

.SHIELDPLOT

            MOVE.W (SHIELDINICIO),D1
            CMP #0,(SHIELDINICIO)
            BEQ .DIB2 ;para obtener datos iniciales
            
             CMP #0,(SHIELDENA) 
            BEQ  .CHECKTIMER2
            
            ;SE ACABÓ LA ACTIVACIÓN DEL ESCUDO(4S)
            ;ESTÁ ACTIVADO EL COOLDOOWN??????
            
.CHECKLIST           
             MOVE.W (VTIMER),D3
            MOVE.W (SHIELDCOOLDOWN),D4
            
            SUB.W (SHIELDCOOLDOWN),D3

            CMP #0,D3
            BGE .ENABLE            
            CLR.W (SHIELDENA)
            BRA .RETURN
.DIB2
             
          
            MOVE.W (VTIMER),D7
            ADD.W #4,D7
            MOVE.W D7,(SHIELDTIMEEN)
            ADD.W #4,D7
            MOVE.W D7,(SHIELDCOOLDOWN)
            
            MOVE.W #1,(SHIELDINICIO)
            
            CLR.W D7
            
            
            



.DIB

                              
            CLR.L D1
            MOVE.L #$0000FF00,D1
            MOVE.W #80,D0        ; SET PEN COLOR
            TRAP #15
            MOVE.W (PLRPOSX),D5
            MOVE.W (PLRPOSY),D6
            ADD.W #15,D5 
            ADD.W #15,D6
            
         
            SUB.W #30,D5
            MOVE.W D5,D1
  
            ADD.W #60,D5
            MOVE.W D5,D3
            
            SUB.W #30,D6
            MOVE.W D6,D2
            ADD.W #60,D6
            
            MOVE.W D6,D4
            MOVE.W #91,D0
            TRAP #15
            
            
            BRA .RETURN

.CHECKTIMER2:
            MOVE.W (SHIELDTIMEEN),D4
            MOVE.W (VTIMER),D3
            
            SUB.W D3,D4
           
            CMP  #0,D4
            BLE .FIN1
            
           
            
            
            BRA .DIB
            

.FIN1:
            
            MOVE.W #1,(SHIELDENA)
            BRA .RETURN


.ENABLE:
            CLR.W (SHIELDINICIO)
            CLR.W (SHIELDENA)
            BRA .RETURN
                                  
           
MOUSEINIT     
    ; INITIALIZES THE SYSTEM VARIABLES KBDSYS AND KBDVAL
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            CLR.W   (MOUSEPOSX)                    ; INIT VARS
            CLR.W   (MOUSEPOSY)
            CLR.W   (ENATP)
            CLR.W   (LASTENA)
	
            MOVE.L  #REVISION, ($80+MOUSETRAP*4)    ; INSTALL
            RTS
            
REVISION:
            MOVEM.L D0-D7,-(A7)

	; READ CURRENT STATE OF MOUSE AND CHANGE MOUSE COORDINATES
	MOVE.B  #61,D0
	MOVE.B  #00,D1
	
	TRAP    #15
            MOVE.W  D1,(MOUSEPOSX)
            

            
	

            SWAP    D1            ; Intercambia los 16 bits superiores e inferiores de D1

            MOVE.W  D1,(MOUSEPOSY)
            SWAP    D1
	

	; IF LEFT CLICK PRESSED AND IT'S INSIDE THE BUTTON ADD 1
	BTST    #0,D0
	
            BEQ     NOT_PRESSED
            CMP.W   #0,(ENATP)
            BNE CHECKTIMER

PRESSED:
             MOVE.W (VTIMER),(LASTENA)
            MOVE.W (MOUSEPOSX),(PLRPOSX)
            MOVE.W (MOUSEPOSY),(PLRPOSY)
            MOVE.W #1,(ENATP)
            
            BRA NOT_PRESSED
            

CHECKTIMER:
            MOVE.W (VTIMER),D3
            SUB.W (LASTENA),D3
            
            CMP #6,D3
            BLT NOT_PRESSED
            CLR.W (ENATP)
            
         
NOT_PRESSED:          
	MOVEM.L  (A7)+,D0-D7
	RTE
	
           
; -----------------------------------------------------------------------------
SCRUPD
; TRAP SERVICE ROUTINE IN CHARGE OF VISUALIZING CURRENT FRAME AND CLEARING
; BUFFER FOR THE NEXT ONE.
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVEM.W D0-D1,-(A7)
            MOVE.B  #94,D0                  ; UPDATE DOUBLE BUFFER
            TRAP    #15
            MOVE.W  #$FF00,D1               ; CLEAR HIDDEN BUFFER
            MOVE.B  #11,D0
            TRAP    #15
            MOVEM.W (A7)+,D0-D1
            RTE
FILLOAD
; LOADS AN FILE FROM DISK TO MEMORY
; INPUT    : A0 - DESTINATION ADDR. WITH ENOUGH SPACE AVAILABLE.
;            A1 - POINTER TO FILE NAME
; OUTPUT   : NONE
; MODIFIES : NONE
; NOTE     : THE READ DATA LOOP READS 1 BYTE AT A TIME TO ENSURE ALL FILES CAN
;            BE LOADED. HOWEVER, IF THE FILE SIZE IS KNOWN BEFOREHAND, NO LOOP
;            WOULD BE NECESSARY AND A SINGLE CALL TO TRAP #15 TASK 53 WOULD READ
;            THE WHOLE FILE AS LONG AS THE FILE SIZE IS PLACED INTO D2.L.
; NOTE     : THE ZERO-TERMINATOR (JUST BEFORE CLOSE THE FILE) IS A REQUIREMENT
;            FOR TEXT-FILES IF THE TEXT IS TO BE PRINTED. FOR OTHER USES, IT
;            CAN BE REMOVED.
; ------------------------------------------------------------------------------
            MOVEM.L D0-D2/A1,-(A7)          ; SAVE REGISTERS
            ; CLOSE ALL FILES
            MOVE.B  #50,D0
            TRAP    #15
            ; OPEN FILE (ASSUMES A1 POINTS TO FILENAME)
            MOVE.B  #51,D0
            TRAP    #15                     ; D1.L:=FILE HANDLER
            ; READ DATA
            MOVE.L  A0,A1                   ; A1 MUST BE THE BUFFER ADDRESS
            MOVE.B  #53,D0                  ; READ DATA TASK
            MOVE.L  #4096,D2                   ; BYTES TO READ (ONE BY ONE)
            TRAP    #15
                               ; PUT A ZERO-TERMINATOR.
            ; CLOSE THE FILE
            MOVE.B  #56,D0
            TRAP    #15
            MOVEM.L (A7)+,D0-D2/A1          ; RESTORE REGISTERS
            RTS






