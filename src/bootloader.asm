; ============================================================
;  bootloader.asm
;  Arquitectura de Computadores — UPTC
;  Ingeniería de Sistemas y Computación
;
;  Descripción:
;    Bootloader almacenado en el sector 0 del disco.
;    Usa la interrupción 13h (función 42h) para leer el
;    kernel desde el sector 3 y cargarlo en la dirección
;    de memoria 0x8000. Luego transfiere la ejecución al kernel.
;
;  Compilar:
;    nasm bootloader.asm -f bin -o bootloader.bin
; ============================================================

bits 16
org 0x7C00          ; El BIOS carga el bootloader en 0x7C00

; ------------------------------------------------------------
;  Punto de entrada
; ------------------------------------------------------------
start:
    ; Limpiar registros de segmento
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00      ; Pila justo debajo del bootloader

    ; Mostrar mensaje de carga (opcional, ayuda a depurar)
    mov si, msg_loading
    call print_string

    mov cx, 125         ; Número de sectores a leer (suficiente para los 62+ KB del kernel)

.leer:
    push cx             ; Guardar el contador del bucle

    ; Preparar lectura extendida de disco (INT 13h, AH=42h)
    mov ah, 42h         ; Función: leer sectores (modo LBA)
    mov dl, 80h         ; Disco: 0x80 = primer disco duro
    mov si, dap         ; SI apunta al DAP (Disk Address Packet)
    int 13h

    ; Avanzar al siguiente sector LBA directamente en memoria
    inc dword [dap_lba]

    ; Avanzar la memoria 512 bytes (sumando 0x20 al segmento)
    mov ax, [dap_seg]
    add ax, 0x0020
    mov [dap_seg], ax

    pop cx              ; Recuperar el contador
    loop .leer          ; Repetir hasta leer todos los sectores

.ok:
    ; Saltar a la dirección donde se cargó el kernel (Segmento 0x0800, offset 0)
    jmp 0x0800:0x0000

; ------------------------------------------------------------
;  Procedimiento: imprimir cadena terminada en 0
;  Entrada: SI apunta a la cadena
; ------------------------------------------------------------
print_string:
    mov ah, 0Eh         ; Función BIOS: teletype output
.loop:
    lodsb               ; Carga byte de [SI] en AL, incrementa SI
    test al, al         ; ¿Fin de cadena?
    jz .done
    int 10h             ; Imprimir carácter en AL
    jmp .loop
.done:
    ret

align 4
; ------------------------------------------------------------
;  DAP — Disk Address Packet (estructura para INT 13h/42h)
; ------------------------------------------------------------
dap:
    db 10h              ; Tamaño del DAP (16 bytes)
    db 00h              ; Reservado (siempre 0)
    dw 1                ; Número de sectores a leer POR VUELTA (1 a la vez para no saturar)
dap_off:
    dw 0x0000           ; Offset siempre en 0
dap_seg:
    dw 0x0800           ; Segmento inicial (0x0800:0000 equivale a 0x8000 físico)
dap_lba:
    dq 3                ; LBA del sector inicial (sector 3 del disco)

; ------------------------------------------------------------
;  Datos
; ------------------------------------------------------------
msg_loading db 'Cargando kernel...', 0Dh, 0Ah, 0

; ------------------------------------------------------------
;  Relleno y firma de arranque
;  El sector de arranque debe tener exactamente 512 bytes.
;  Los últimos 2 bytes deben ser 0x55, 0xAA (firma BIOS).
; ------------------------------------------------------------
times 510-($-$$) db 0   ; Rellenar con ceros hasta el byte 510
dw 0xAA55               ; Firma del sector de arranque (little-endian)