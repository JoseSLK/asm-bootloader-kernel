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
org 0x8000              ; El bootloader carga el kernel aquí

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

    ; TODO: implementar submenú y cálculo de área
    ;       (Hexágono regular y Heptágono regular)

    mov si, msg_wip
    call print_str
    call nueva_linea
    call nueva_linea

    mov si, msg_volver
    call print_str
    call leer_tecla

    call limpiar_pantalla
    jmp menu_principal

; ============================================================
;  OPCIÓN 2 — Imprimir imagen de los integrantes
; ============================================================
opcion_2:
    call limpiar_pantalla
    call print_linea_horizontal

    mov si, msg_titulo_imagen
    call print_str
    call nueva_linea

    call print_linea_horizontal
    call nueva_linea

    ; TODO: implementar impresión de imagen en modo gráfico

    mov si, msg_wip
    call print_str
    call nueva_linea
    call nueva_linea

    mov si, msg_volver
    call print_str
    call leer_tecla

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

; -- Mensajes generales --
msg_wip             db '  [En desarrollo...]', 0
msg_volver          db '  Presione cualquier tecla para volver al menu...', 0
msg_salida          db '     Sistema finalizado. Hasta luego!', 0