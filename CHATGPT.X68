; Programa en Easy68K para mover un cuadrado con 'a', 'd' y hacer que salte con 'w'

    ORG     $1000          ; Comienzo del programa en memoria

START:
    CLR     D0             ; D0 será la posición X
    MOVE.B  #5, D1         ; D1 será la posición Y inicial (en el "suelo")
    MOVE.B  #0, D2         ; D2 es la velocidad vertical para el salto (0 = en el suelo)

MAIN_LOOP:
    ; Mostrar la posición actual del cuadrado
    JSR     DISPLAY_PLAYER

    ; Esperar entrada del usuario
    JSR     WAIT_INPUT

    ; Comprobar si se presionó 'a' (izquierda), 'd' (derecha) o 'w' (salto)
    CMP.B   #'a', D3
    BEQ     MOVE_LEFT
    CMP.B   #'d', D3
    BEQ     MOVE_RIGHT
    CMP.B   #'w', D3
    BEQ     JUMP

    ; Si D2 es distinto de cero, significa que estamos en el aire, y aplicamos "gravedad"
    CMP.B   #0, D2
    BEQ     MAIN_LOOP       ; Si D2 es cero, estamos en el suelo y no aplicamos gravedad

    ; Actualizar la posición en Y según la velocidad
    ADD.B   D2, D1
    ADD.B   #1, D2          ; Simulación de gravedad

    ; Si estamos en el suelo, reiniciamos la velocidad vertical
    CMP.B   #5, D1          ; 5 es la posición del "suelo"
    BNE     MAIN_LOOP
    MOVE.B  #0, D2          ; Detener la caída en el suelo
    MOVE.B  #5, D1          ; Asegurar que no pase del suelo

    BRA     MAIN_LOOP

MOVE_LEFT:
    SUB.B   #1, D0          ; Mover a la izquierda
    BRA     MAIN_LOOP

MOVE_RIGHT:
    ADD.B   #1, D0          ; Mover a la derecha
    BRA     MAIN_LOOP

JUMP:
    ; Solo saltar si estamos en el suelo (D1 = 5 y D2 = 0)
    CMP.B   #0, D2
    BNE     MAIN_LOOP       ; Si estamos en el aire, ignoramos 'w' para evitar doble salto
    MOVE.B  #-3, D2         ; Asignar velocidad de salto (negativo para ir hacia arriba)
    BRA     MAIN_LOOP
            
WAIT_INPUT:
    ; Leer un carácter del teclado
    TRAP    #15             ; Interrupción para leer un carácter
    MOVE.B  D1, D3          ; Guardar el carácter en D3
    RTS

DISPLAY_PLAYER:
    ; Limpia la pantalla y muestra la posición del jugador
    TRAP    #14             ; Limpiar pantalla
    MOVE.B  D0, -(A7)       ; Guardar la posición X en la pila
    MOVE.B  D1, -(A7)       ; Guardar la posición Y en la pila
    ; TRAP para dibujar en pantalla (puede variar)
    TRAP    #13             ; Llamada ficticia, define según tu implementación gráfica
    ADDQ.L  #2, A7          ; Restaurar la pila (2 bytes)
    
    RTS
   
    END START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
