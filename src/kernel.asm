; ============================================================
;  kernel.asm
;  Arquitectura de Computadores — UPTC
;  Ingeniería de Sistemas y Computación
;
;  Integrantes:
;    - Jose Luis Salamanca Lopez
;    - Nicolas Samuel Tinjaca Topia
;
;  Descripción:
;    Kernel básico cargado por el bootloader desde el sector 3.
;    Presenta encabezado institucional, menú principal y
;    navegación entre opciones.
;
;  Compilar:
;    nasm kernel.asm -f bin -o kernel.bin
; ============================================================

bits 16
org 0x0000              ; AHORA ARRANCAMOS EN CERO PARA APROVECHAR TODO EL SEGMENTO

; ------------------------------------------------------------
;  Punto de entrada
; ------------------------------------------------------------
jmp start

; ============================================================
;  PROCEDIMIENTOS GENERALES
; ============================================================

; ------------------------------------------------------------
;  print_str: Imprime cadena terminada en 0
;  Entrada: SI → dirección de la cadena
; ------------------------------------------------------------
print_str:
    mov ah, 0Eh
.loop:
    lodsb
    test al, al
    jz .done
    int 10h
    jmp .loop
.done:
    ret

; ------------------------------------------------------------
;  print_char: Imprime un carácter
;  Entrada: AL → carácter
; ------------------------------------------------------------
print_char:
    mov ah, 0Eh
    int 10h
    ret

; ------------------------------------------------------------
;  nueva_linea: Imprime salto de línea (CR + LF)
; ------------------------------------------------------------
nueva_linea:
    mov ah, 0Eh
    mov al, 0Dh         ; CR
    int 10h
    mov al, 0Ah         ; LF
    int 10h
    ret

; ------------------------------------------------------------
;  leer_tecla: Espera una tecla y la retorna en AL
; ------------------------------------------------------------
leer_tecla:
    mov ah, 00h
    int 16h             ; BIOS: leer tecla — resultado en AL
    ret

; ------------------------------------------------------------
;  limpiar_pantalla: Limpia la pantalla y ubica cursor en (0,0)
; ------------------------------------------------------------
limpiar_pantalla:
    mov ax, 0003h       ; Modo texto 80x25, 16 colores — también limpia
    int 10h
    ret

; ------------------------------------------------------------
;  print_linea_horizontal: Imprime una línea de '=' (70 chars)
; ------------------------------------------------------------
print_linea_horizontal:
    mov cx, 70
    mov al, '='
.loop:
    call print_char
    loop .loop
    call nueva_linea
    ret

; ============================================================
;  INICIO DEL KERNEL
; ============================================================
start:
    ; Configurar los segmentos para alinearlos con la nueva base del bootloader
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0xFFFF      ; Pila segura al tope de los 64KB libres

    call limpiar_pantalla

; ------------------------------------------------------------
;  Encabezado institucional
; ------------------------------------------------------------
encabezado:
    call print_linea_horizontal

    mov si, msg_asignatura
    call print_str
    call nueva_linea

    mov si, msg_programa
    call print_str
    call nueva_linea

    call print_linea_horizontal

    mov si, msg_integrante1
    call print_str
    call nueva_linea

    mov si, msg_integrante2
    call print_str
    call nueva_linea

    call print_linea_horizontal
    call nueva_linea

; ------------------------------------------------------------
;  Menú principal
; ------------------------------------------------------------
menu_principal:
    mov si, msg_menu_titulo
    call print_str
    call nueva_linea

    mov si, msg_sep_menu
    call print_str
    call nueva_linea

    mov si, msg_op1
    call print_str
    call nueva_linea

    mov si, msg_op2
    call print_str
    call nueva_linea

    mov si, msg_op3
    call print_str
    call nueva_linea

    call nueva_linea
    mov si, msg_seleccione
    call print_str

; ------------------------------------------------------------
;  Leer opción del usuario
; ------------------------------------------------------------
leer_opcion:
    call leer_tecla

    cmp al, '1'
    je opcion_1

    cmp al, '2'
    je opcion_2

    cmp al, '3'
    je opcion_3

    ; Tecla inválida — volver a esperar sin limpiar
    jmp leer_opcion

; ============================================================
;  OPCIÓN 1 — Calcular área de figura geométrica
; ============================================================
opcion_1:
    call limpiar_pantalla
    call print_linea_horizontal

    mov si, msg_titulo_area
    call print_str
    call nueva_linea

    call print_linea_horizontal
    call nueva_linea

    ; Submenú: elegir figura
    mov si, msg_subfig1
    call print_str
    call nueva_linea

    mov si, msg_subfig2
    call print_str
    call nueva_linea

    call nueva_linea
    mov si, msg_seleccione_fig
    call print_str

.leer_fig:
    call leer_tecla
    cmp al, '1'
    je .hexagono
    cmp al, '2'
    je .heptagono
    jmp .leer_fig

; ----------------------------------------------------------
;  Hexágono regular
; ----------------------------------------------------------
.hexagono:
    call nueva_linea
    call nueva_linea
    mov si, msg_nombre_hex
    call print_str
    call nueva_linea
    mov si, msg_formula
    call print_str
    call nueva_linea
    call nueva_linea

    ; Leer Perímetro
    mov si, msg_pedir_P
    call print_str
    call leer_numero        ; resultado en [val_entero] y [val_decimal]
    call nueva_linea

    ; Guardar P en escala x10
    mov ax, [val_entero]
    mov bx, 10
    mul bx                  ; AX = parte_entera * 10
    add ax, [val_decimal]   ; AX = P escalado (x10)
    mov [param_P], ax

    ; Leer Apotema
    mov si, msg_pedir_a
    call print_str
    call leer_numero
    call nueva_linea

    ; Guardar a en escala x10
    mov ax, [val_entero]
    mov bx, 10
    mul bx
    add ax, [val_decimal]
    mov [param_a], ax

    jmp .calcular

; ----------------------------------------------------------
;  Heptágono regular
; ----------------------------------------------------------
.heptagono:
    call nueva_linea
    call nueva_linea
    mov si, msg_nombre_hep
    call print_str
    call nueva_linea
    mov si, msg_formula
    call print_str
    call nueva_linea
    call nueva_linea

    ; Leer Perímetro
    mov si, msg_pedir_P
    call print_str
    call leer_numero
    call nueva_linea

    mov ax, [val_entero]
    mov bx, 10
    mul bx
    add ax, [val_decimal]
    mov [param_P], ax

    ; Leer Apotema
    mov si, msg_pedir_a
    call print_str
    call leer_numero
    call nueva_linea

    mov ax, [val_entero]
    mov bx, 10
    mul bx
    add ax, [val_decimal]
    mov [param_a], ax

; ----------------------------------------------------------
;  Cálculo: A = (P * a) / 2
;  P y a están en escala x10, así que P*a queda en x100.
;  Al dividir por 2 el resultado sigue en x100.
;  Para mostrar: parte_entera = resultado / 100
;                parte_decimal = resultado % 100
; ----------------------------------------------------------
.calcular:
    mov ax, [param_P]
    mov bx, [param_a]
    mul bx              ; DX:AX = P_escalado * a_escalado  (x100)

    ; El resultado puede exceder 16 bits si P y a son grandes.
    ; Con máximo 99.9 x 99.9 → 9980 * 9980 ≈ 99.6M → necesita 32 bits.
    ; Usamos DX:AX y dividimos entre 2 con shifts.
    ; DX:AX / 2:
    shr dx, 1           ; desplazar DX a la derecha (bit saliente va a CF)
    rcr ax, 1           ; rotar AX con el carry de DX → división de 32 bits / 2

    ; Ahora DX:AX contiene el área en escala x100.
    ; Guardar parte alta en [area_hi] y baja en [area_lo]
    mov [area_hi], dx
    mov [area_lo], ax

    ; Calcular parte entera: DX:AX / 100
    ; div 100 → cociente en AX, resto en DX
    mov dx, [area_hi]
    mov ax, [area_lo]
    mov bx, 100
    div bx              ; AX = parte entera del área, DX = resto (centésimas)
    mov [resultado_entero], ax
    mov [resultado_decimal], dx

; ----------------------------------------------------------
;  Mostrar resultado
; ----------------------------------------------------------
.mostrar:
    call nueva_linea
    mov si, msg_resultado
    call print_str

    ; Imprimir parte entera
    mov ax, [resultado_entero]
    call print_numero

    ; Imprimir punto decimal
    mov al, '.'
    call print_char

    ; Imprimir parte decimal (siempre 2 dígitos, con cero adelante si < 10)
    mov ax, [resultado_decimal]
    cmp ax, 10
    jge .sin_cero
    mov al, '0'         ; cero adelante si decimal < 10
    call print_char
.sin_cero:
    call print_numero

    call nueva_linea
    call nueva_linea

    ; Preguntar si calcular otra figura o volver
    mov si, msg_otra_o_volver
    call print_str

.esperar_resp:
    call leer_tecla
    cmp al, '1'
    je opcion_1
    cmp al, '2'
    je .salir_area
    jmp .esperar_resp

.salir_area:
    call limpiar_pantalla
    jmp menu_principal

; ============================================================
;  PROCEDIMIENTO: leer_numero
;  Lee un número del teclado con formato XX.X
;    - Máximo 2 dígitos enteros, 1 dígito decimal
;    - Muestra cada carácter al escribirlo (eco)
;    - Termina con Enter
;  Resultado: [val_entero] y [val_decimal] actualizados
;
;  Estado de [fase_lectura]:
;    0 = leyendo parte entera
;    1 = se escribió el punto, esperando decimal
;    2 = decimal ya leído, ignorar más entrada
; ============================================================
leer_numero:
    mov word [val_entero],    0
    mov word [val_decimal],   0
    mov byte [fase_lectura],  0
    mov byte [digitos_enteros], 0

.loop:
    mov ah, 00h
    int 16h                     ; leer tecla → AL = carácter ASCII

    ; ── Enter: terminar ──────────────────────────────────
    cmp al, 0Dh
    je .done

    ; ── Punto decimal ────────────────────────────────────
    cmp al, '.'
    je .procesar_punto

    ; ── Solo aceptar dígitos '0'-'9' ─────────────────────
    cmp al, '0'
    jb .loop
    cmp al, '9'
    ja .loop

    ; ── Es un dígito — ¿en qué fase estamos? ─────────────
    cmp byte [fase_lectura], 0
    je .dígito_entero

    cmp byte [fase_lectura], 1
    je .dígito_decimal

    ; fase = 2: ya leímos el decimal, ignorar
    jmp .loop

; ── Procesar dígito de parte entera ──────────────────────
.dígito_entero:
    cmp byte [digitos_enteros], 2
    jge .loop                   ; máximo 2 dígitos enteros

    ; Guardar AL antes de operar
    mov cl, al                  ; CL = carácter ASCII del dígito

    ; val_entero = val_entero * 10 + dígito
    mov ax, [val_entero]
    mov bx, 10
    mul bx                      ; AX = val_entero * 10  (DX no importa aquí)
    mov bl, cl
    sub bl, '0'                 ; BL = valor numérico
    xor bh, bh
    add ax, bx
    mov [val_entero], ax

    inc byte [digitos_enteros]

    ; Eco
    mov al, cl
    mov ah, 0Eh
    int 10h
    jmp .loop

; ── Procesar dígito decimal ───────────────────────────────
.dígito_decimal:
    mov cl, al                  ; guardar carácter

    sub al, '0'
    xor ah, ah
    mov [val_decimal], ax       ; guardar valor numérico

    mov byte [fase_lectura], 2  ; bloquear más entrada

    ; Eco
    mov al, cl
    mov ah, 0Eh
    int 10h
    jmp .loop

; ── Procesar punto ────────────────────────────────────────
.procesar_punto:
    cmp byte [fase_lectura], 0      ; solo válido si estamos en fase entera
    jne .loop
    cmp byte [digitos_enteros], 0   ; no aceptar punto sin dígitos antes
    je .loop

    mov byte [fase_lectura], 1      ; pasar a fase decimal

    ; Eco del punto
    mov ah, 0Eh
    int 10h                         ; AL ya tiene '.'
    jmp .loop

.done:
    ret

; ============================================================
;  PROCEDIMIENTO: print_numero
;  Imprime AX como número decimal sin signo.
;  Preserva BX. Usa la pila para invertir dígitos.
; ============================================================
print_numero:
    push bx
    push cx
    push dx

    xor cx, cx              ; contador de dígitos apilados
    mov bx, 10

    ; Caso especial: AX = 0
    test ax, ax
    jnz .descomponer
    mov ah, 0Eh
    mov al, '0'
    int 10h
    jmp .fin_print

.descomponer:
    test ax, ax
    jz .imprimir
    xor dx, dx
    div bx                  ; AX = cociente, DX = resto (dígito)
    push dx
    inc cx
    jmp .descomponer

.imprimir:
    pop dx
    mov ah, 0Eh
    mov al, dl
    add al, '0'
    int 10h
    loop .imprimir

.fin_print:
    pop dx
    pop cx
    pop bx
    ret

; ============================================================
;  OPCIÓN 2 — Imprimir imagen de los integrantes
; ============================================================
opcion_2:
    ; 1. Cambiar al modo de video VGA 13h (320x200, 256 colores)
    mov ax, 0013h
    int 10h

    ; 2. Enviar la paleta personalizada a los puertos DAC
    mov dx, 03C8h       ; Puerto de índice DAC
    xor al, al          ; Empezar en el índice 0
    out dx, al

    mov dx, 03C9h       ; Puerto de datos DAC
    mov si, imagePalette ; Paleta generada por el script de Python
    mov cx, 768         ; 256 colores * 3 canales (RGB)
.cargar_paleta:
    lodsb               ; Carga byte y avanza
    out dx, al          ; Envía al puerto
    loop .cargar_paleta

    ; 3. Dibujar la matriz en la memoria de video (Segmento 0xA000)
    mov ax, 0xA000
    mov es, ax
    xor di, di          ; Destino (0,0 de la pantalla)
    mov si, imageData   ; Píxeles generados por Python

    mov dx, 200         ; Altura: 200 filas
.bucle_filas:
    mov cx, 300         ; Ancho de la imagen: 300 píxeles
    rep movsb           ; Copiar la fila entera

    ; Compensar la diferencia de resolución (pantalla 320 vs imagen 300)
    add di, 20          ; Saltar 20 píxeles para pasar a la siguiente fila real
    dec dx
    jnz .bucle_filas

    ; 4. Esperar a que el usuario presione una tecla para salir de la imagen
.wait_key:
    mov ah, 00h
    int 16h

    ; 5. Restaurar el modo de texto original (Modo 03h)
    mov ax, 0003h
    int 10h

    ; IMPORTANTE: Restaurar el segmento ES al del kernel antes de volver
    mov ax, cs
    mov es, ax

    ; 6. Volver al menú principal
    call limpiar_pantalla
    jmp menu_principal

; ============================================================
;  OPCIÓN 3 — Salir
; ============================================================
opcion_3:
    call limpiar_pantalla
    call print_linea_horizontal

    mov si, msg_salida
    call print_str
    call nueva_linea

    call print_linea_horizontal

.halt:
    hlt                 ; Detener el procesador
    jmp .halt           ; Por si el procesador sale del halt

; ============================================================
;  DATOS — Cadenas de texto
; ============================================================

; -- Encabezado --
msg_asignatura      db '     ARQUITECTURA DE COMPUTADORES', 0
msg_programa        db '     INGENIERIA DE SISTEMAS Y COMPUTACION - UPTC', 0
msg_integrante1     db '     Integrante: Jose Luis Salamanca Lopez', 0
msg_integrante2     db '     Integrante: Nicolas Samuel Tinjaca Topia', 0

; -- Menú --
msg_menu_titulo     db '                   MENU PRINCIPAL', 0
msg_sep_menu        db '  ------------------------------------------------', 0
msg_op1             db '  1. Calcular area de una figura geometrica', 0
msg_op2             db '  2. Imprimir imagen de los integrantes', 0
msg_op3             db '  3. Salir', 0
msg_seleccione      db '  Seleccione una opcion: ', 0

; -- Títulos de secciones --
msg_titulo_area     db '     CALCULO DE AREA - FIGURA GEOMETRICA', 0
msg_titulo_imagen   db '     IMAGEN DE LOS INTEGRANTES', 0

; -- Submenú figuras --
msg_subfig1         db '  1. Hexagono regular', 0
msg_subfig2         db '  2. Heptagono regular', 0
msg_seleccione_fig  db '  Seleccione la figura: ', 0

; -- Nombres de figuras --
msg_nombre_hex      db '  >> Hexagono regular', 0
msg_nombre_hep      db '  >> Heptagono regular', 0
msg_formula         db '     Formula: A = (P * a) / 2', 0

; -- Entrada de datos --
msg_pedir_P         db '  Ingrese el Perimetro  (ej: 24.5): ', 0
msg_pedir_a         db '  Ingrese la Apotema    (ej:  8.3): ', 0

; -- Resultado --
msg_resultado       db '  Area = ', 0
msg_otra_o_volver   db '  1. Calcular otra figura   2. Volver al menu: ', 0

; -- Mensajes generales --
msg_wip             db '  [En desarrollo...]', 0
msg_volver          db '  Presione cualquier tecla para volver al menu...', 0
msg_salida          db '     Sistema finalizado. Hasta luego!', 0

; ============================================================
;  VARIABLES — Cálculo de área
; ============================================================
val_entero          dw 0    ; parte entera del número leído
val_decimal         dw 0    ; dígito decimal del número leído
fase_lectura        db 0    ; 0=entera, 1=punto visto, 2=decimal leído
digitos_enteros     db 0    ; cantidad de dígitos enteros ingresados

param_P             dw 0    ; Perímetro escalado x10
param_a             dw 0    ; Apotema escalada x10

area_hi             dw 0    ; parte alta del resultado x100 (32 bits)
area_lo             dw 0    ; parte baja del resultado x100

resultado_entero    dw 0    ; parte entera del área final
resultado_decimal   dw 0    ; parte decimal del área final (centésimas)

; ============================================================
;  INCLUSIÓN DE IMAGEN
; ============================================================
; Asegúrate de que este archivo imageData.asm esté en la misma
; carpeta que este kernel.asm
%include "src/imageData.asm"