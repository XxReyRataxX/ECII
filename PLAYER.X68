*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
; ==============================================================================
; SYSTEM VARIABLES
; ==============================================================================
PLRWIDTH    EQU     30                      ; PLAYER WIDTH (PIXELS)
PLRHEIGH    EQU     30                      ; PLAYER HEIGHT (PIXELS)


          
; --- KEYBOARD RELATED VARIABLES -----------------------------------------------
KBDTRAP     EQU     0                       ; KEYBOARD UPDATE TRAP

KBDVAL      DS.B    1                       ; KEY STATE
KBDEDGE     DS.B    1                       ; KEY EDGE

KBDDOWN     EQU     'S'
KBDRIGHT    EQU     'D'
KBDUP       EQU     'W'
KBDLEFT     EQU     'A'
KBDESC      EQU     $20                     ; SPACE KEY (ESCUDO)
; --- TIMED INTERRUPT RELATED VARIABLES ----------------------------------------

SCRINTCT    DS.B    1                       ; INTERRUPT COUNTER
            DS.W    0

; --- GAME STATE RELATED VARIABLES --------------------------------------------

STACUR      DS.W    1                       ; CURRENT GAME STATE
STANEXT     DS.W    1                       ; NEXT GAME STATE

; --- BALL RELATED VARIABLES ---------------------------------------------------

BALPOSX     DS.W    1                       ; BALL X COORDINATE
BALPOSY     DS.W    1                       ; BALL Y COORDINATE
BALVELX     DS.W    1                       ; BALL X VELOCITY
BALVELY     DS.W    1                       ; BALL Y VELOCITY

; --- PLAYER RELATED VARIABLES ------------------------------------------------

PLRPOSX     DS.W    1                       ; PLAYER X POSITION (PIXELS)
PLRPOSY     DS.W    1                       ; PLAYER Y POSITION (PIXELS)
PLRENER     DS.W    1                       ; PLAYER ENERGY
PLRDMG      DS.B    1                       ; BIT0: UPD DAMAGE, BIT1 PLOT DMG
            DS.W    0
PLRSPEED    EQU     3    
            
; --- ESCUDO RELATED VARIABLES ----------------------------------------------------

ESCPOSX     DS.W 1                          ;POSICION Y ESCUDO
ESCPOSY     DS.W 1                          ;POSICION Y ESCUDO

; --- SCREEN RELATED VARIABLES ---------------------------------------------
SCRWIDTH    EQU     640                     ; SCREEN WIDTH (PIXELS)
SCRHEIGH    EQU     480                     ; SCREEN HEIGHT (PIXELS)
SCRIRQ      EQU     1                       ; SCREEN INTERRUPT NUMBER
TIMER       DS.W 1                          ;TIMER JUEGO
POINT       DS.W 1                          ;PUNTOS CONSEGUIDOS     
SCRTRAP     EQU     1
START:                  ; first instruction of program
           
            JSR SCRINIT
           JSR KBDINIT 

           JSR PLRINIT
            CLR D2
.LOOP       TRAP    #KBDTRAP                ; READ KEYBOARD
            JSR     PLRUPD

            JSR     DIBUJAR
.WINT       TST.B   (SCRINTCT)              ; WAIT FOR INTERRUPT
            BEQ     .WINT
            CLR.B   (SCRINTCT)  
            TRAP    #SCRTRAP                ; SHOW GRAPHICS                
            
            BRA .LOOP
    SIMHALT             ; halt simulator
SCRISR
; SCREEN TIMER ISR. INCREASES THE INTERRUPT COUNTER AND UPDATES DOUBLE BUFFER.
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            ADDQ.B  #1,(SCRINTCT)           ; UPDATE INT FLAG/COUNTER
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
            
            ANDI.W  #$F8FF,SR               ; ENABLE INTS            
            RTS 
* Put variables and constants here
KBDREAD
; TRAP SERVICE ROUTINE.
; UPDATES THE SYSTEM VARIABLES KBDEDGE AND KBDVAL ACCORDING TO THE BITFIELD
; DESCRIBED IN SYSCONST. KBDVAL HOLDS THE CURRENT VALUES AND KBDEFGE HOLDS
; RISING EDGES FROM PREVIOUS CALL TO THE CURRENT ONE.
; INPUT    - NONE
; OUTPUT   - (KBDVAL) AND (KBDEDGE)
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVEM.L D0-D3,-(A7)
            MOVE.B  #19,D0
            MOVE.L  #KBDDOWN<<24+KBDRIGHT<<16+KBDUP<<8+KBDLEFT,D1
            TRAP    #15
            BSR     .STORE                  ; STORE KEY UP,DOWN,LEFT AND RIGTH.
            MOVE.B  (KBDVAL),D0             ; COMPUTE EDGE.
            NOT.B   D0                      ; EDGE=NOT(PREVIOUS) AND CURRENT.
            AND.B   D2,D0
            MOVE.B  D2,(KBDVAL)             ; STORE VALUES (PRESS AND EDGE)
            MOVE.B  D0,(KBDEDGE)
            MOVEM.L (A7)+,D0-D3
            RTE

.STORE      MOVE.W  #3,D3                   ; TRANSLATES THE 8-BIT ENCODING
.LOOP       LSL.L   #8,D1                   ; OF TRAP #15 TASK 19 INTO A 1-BIT
            ROXL.B  #1,D2                   ; PER KEYPRESS ENCODING
            DBRA.W  D3,.LOOP
            RTS
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
PLRINIT            
;Personaje 
;----------------------------------------------------------------------------            
            MOVE.W  #PLRWIDTH/2,(PLRPOSX)
            MOVE.W  #(SCRHEIGH-PLRHEIGH)/2,(PLRPOSY)
            RTS
            
PLRUPD
; UPDATES THE PLAYER MOTION
; INPUT    - NONE (ACCESSES KBDVAL AND KBDEDGE)
; OUTPUT   - NONE (MODIFIES PLAYER DATA)
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVE.W  D1,-(A7)
            
            MOVE.B  (KBDVAL),D1             ; PERFORM MOTION AND CHECK BOUNDS.
            CMP.W #1,D2
            BEQ     NADA
            ADD.W   #1,(PLRPOSY)
NADA
            ROR.B   #1,D1
            BCC     .CHKUP
            SUB.W   #PLRSPEED,(PLRPOSX)
            TST.W   (PLRPOSX)
            BGE     .CHKUP
            CLR.W   (PLRPOSX)
.CHKUP      ROR.B   #1,D1
            BCC     .CHKRT
            MOVE.W   #1,D2
            SUB.W   #PLRSPEED,(PLRPOSY) 
            
            TST.W   (PLRPOSY)
            BGE     .CHKRT
            CLR.W   (PLRPOSY)
.CHKRT      ROR.B   #1,D1
            BCC     .CHKDN
            ADD.W   #PLRSPEED,(PLRPOSX)
            CMP.W   #SCRWIDTH-PLRWIDTH,(PLRPOSX)
            BLE     .CHKDN
            MOVE.W  #SCRWIDTH-PLRWIDTH,(PLRPOSX)
.CHKDN      ROR.B   #1,D1
            BCC     .MDONE
            ADD.W   #PLRSPEED,(PLRPOSY)
            CMP.W   #SCRHEIGH-PLRHEIGH,(PLRPOSY)
            BLE     .MDONE
            MOVE.W  #SCRHEIGH-PLRHEIGH,(PLRPOSY)
.MDONE      
            
            
            MOVE.W  (A7)+,D1
            RTS
DIBUJAR
            MOVE.B #80,D0
            MOVE.L #$0000FF00,D1
            TRAP #15
            MOVE.W  (PLRPOSX),D1            ; PLOT THE PLAYER
            MOVE.W  (PLRPOSY),D2
            MOVE.W  D1,D3
            MOVE.W  D2,D4
            ADD.W   #PLRWIDTH,D3
            ADD.W   #PLRHEIGH,D4
            MOVE.B  #87,D0
            TRAP    #15
            RTS
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
    END    START        ; last line of source






