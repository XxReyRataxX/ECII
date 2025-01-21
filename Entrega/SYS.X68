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
           CLR.L D5
           CLR.L D6
           CLR.L D4
           MOVE.W   #1,(ENFPS)
            MOVE.W   #0,(FPSAN)
           MOVE.W #1000,D5
           MOVE.W #FPS,D4
            MOVE.B  #32,D0
            MOVE.B  #6,D1
            MOVE.B  #$81,D2
            DIVU.W  #FPS, D5         ; Divide D0 por D1 (D0 = cociente y resto)
            MOVE.W D5,D6
            MOVE.L D6,D3
            TRAP    #15
            CLR.L D6
             MOVE.L  D5, D6         ; Copia D0 para extraer el resto
            ANDI.L  #$00FF, D6     ; MÃ¡scara para obtener el resto (20)
            MULU.W  #1000, D6      ; Multiplicar el resto por 1000

            DIVU.W  D4,D6          ; D4 = parte decimal (2857)
            MOVE.W  D6,(ERROR)

            
            
            CLR.B   (SCRINTCT)              ; PREPARE INTERRUPT FLAG
            CLR.B   (SCRCYCCT) 
            ANDI.W  #$F8FF,SR               ; ENABLE INTS            
            RTS
FPSUPD
            MOVEM.W D0-D6,-(A7)
            MOVE.L (FPSIN),D3
            MOVE.L  (FPSAC),D4
            SUB.L   D3,D4
           
            CMP.W   #0,D4
            BEQ     .FF
            CMP.W   #0,D4
            BGE     .ND
            NEG.L D4
.ND

            MULS    #10, D4
            CLR.L D6
            CLR.L D5
            MOVE.B  (SCRCYCCT),D6
.AA         SUB.L   D6,D4
            CMP.L   #0,D4
            BLT     .TN
            ADDQ.W  #1,D5
            BRA .AA
.TN         CLR.L D3
            CLR.L D4
            CMP.W   #0,D5
            BEQ     .FF
            MOVE.L  #1000,D3
.CA         SUB.L     D5,D3
            CMP.L   #0,D3
            BLT     .SN
            ADDQ.W  #1,D4
            BRA .CA
.SN         
                
            
            MOVE.W  D4,(FPSAN)
       
     
            BRA .TRAP
.FF         MOVE.W #100,(FPSAN)
.TRAP       

            MOVEM.W (A7)+,D0-D6
            RTS 
* Put variables and constants here
SCRPLOT
            
	MOVEM.L D0-D7,-(A7)
	
	MOVE.L #$00FF0000,D1
            MOVE.W #81,D0        ; SET FILL COLOR
            TRAP #15
            
	LEA TIMER,A1
	CLR.L D1
            CLR.L D0
            MOVE.W (VTIMER),D4
            MOVE.W (VTIMER),D1
            MOVE.B #17,D0
            TRAP #15 ;TIMER
            

            
            MOVE.L #$00FFFFFF,D1
            MOVE.W #80,D0        ; SET PEN COLOR
            TRAP #15
            
            LEA SHIELD,A1
	
            MOVE.B #14,D0
            TRAP #15
            ;indicador de shield o tp para ROJO
            MOVE.L #0,D3
            MOVE.W (SHIELDTIMEEN),D5
            CMP D5,D4
            BGT .POSIBLEROJO
            
            CMP D5,D4
            BEQ .ROJO
            BRA .VERDE
            
            
           
            
       
            
.VERDE           
            
            MOVE.L #$0000FF00,D1
            MOVE.W #81,D0        ; SET FILL COLOR
            TRAP #15
            ;Dibujamos cuadrado
            CMP #0,D3
            BEQ .CHECKPOINT
            BRA .CHECKPOINT2

            
.POSIBLEROJO
            MOVE.L #0,D3
            MOVE.W (SHIELDCOOLDOWN),D5
            CMP D4,D5
            BGT .ROJO
            BRA .VERDE
            
.CHECKPOINT
            MOVE.W #65,D1
            MOVE.W #15,D2
            MOVE.W #80,D3
            MOVE.W #30,D4
            MOVE.W #87,D0
            TRAP #15
            
            
            MOVE.L #$00FF0000,D1
            MOVE.W #81,D0        ; SET FILL COLOR
            TRAP #15
            
            
            ;HAREMOS PRINT DEL TELEPORT
            LEA TELEPORT,A1
	
            MOVE.B #14,D0
            TRAP #15
            
            CLR.L D2
            MOVE.W (ENATP),D2
            
            MOVE.L #$0000FF00,D1
            MOVE.W #81,D0        ; SET FILL COLOR
            TRAP #15
            
            MOVE.L #1,D3
            MOVE.W (VTIMER),D4
            MOVE.W (TIMEENABLE),D5
            CMP D4,D5
            BGE .ROJO
            BRA .VERDE
            
.CHECKPOINT2
            MOVE.W #75,D1
            MOVE.W #30,D2
            MOVE.W #90,D3
            MOVE.W #45,D4
            MOVE.W #87,D0
            TRAP #15
           
            ;TENEMOS EL CUADRADO DIBUJADO
            
            MOVE.L #$00FF0000,D1
            MOVE.W #81,D0        ; SET FILL COLOR
            TRAP #15
            
            LEA TXTFPS,A1
            CLR.L D1
            
            MOVE.W #FPS,D1
            MOVE.B #17,D0
            TRAP #15
            
            

			
	MOVEM.L (A7)+,D0-D7
            RTS


.ROJO

            MOVE.L #$000000FF,D1
            MOVE.W #81,D0        ; SET FILL COLOR
            TRAP #15
            
            CMP #0,D3
            BEQ .CHECKPOINT
            BRA .CHECKPOINT2
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
            
            ;SE ACABÃ“ LA ACTIVACIÃ“N DEL ESCUDO(4S)
            ;ESTÃ ACTIVADO EL COOLDOOWN??????
            
.CHECKLIST           
             MOVE.W (VTIMER),D3
            MOVE.W (SHIELDCOOLDOWN),D4
            
            SUB.W (SHIELDCOOLDOWN),D3

            CMP #0,D3
            BGE .ENABLE            
            
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
             MOVE.W (VTIMER),D2
             ADD.W #6,D2
             MOVE.W D2,(TIMEENABLE)
            MOVE.W (MOUSEPOSX),(PLRPOSX)
            MOVE.W (MOUSEPOSY),(PLRPOSY)
            MOVE.W #1,(ENATP)
            
            BRA NOT_PRESSED
            

CHECKTIMER:
            MOVE.W (TIMEENABLE),D4
            MOVE.W (VTIMER),D3
            
            CMP D3,D4
            BGE NOT_PRESSED
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
            MOVEM.W D0-D6/A1,-(A7)
            LEA TXT2FPS,A1
            CLR.L D1
            MOVE.W (FPSAN),D1
            MOVE.B #17,D0
            TRAP #15
            CLR.L D0
            CLR.L D1
            MOVE.B  #94,D0                  ; UPDATE DOUBLE BUFFER
            TRAP    #15
            MOVE.W  #$FF00,D1               ; CLEAR HIDDEN BUFFER
            MOVE.B  #11,D0
            TRAP    #15
            MOVEM.W (A7)+,D0-D6/A1
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










*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
