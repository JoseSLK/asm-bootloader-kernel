#!/bin/bash

# ─────────────────────────────────────────
#  build.sh — Compilar y ejecutar en QEMU
#  Uso: ./build.sh
# ─────────────────────────────────────────

set -e  # detener si hay error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/src"
BIN="$SCRIPT_DIR/bin"

# Colores para mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # sin color

echo -e "${YELLOW}==> Creando carpeta bin/${NC}"
mkdir -p "$BIN"

# ── 1. Compilar bootloader ──────────────────────────────
echo -e "${YELLOW}==> Compilando bootloader...${NC}"
nasm "$SRC/bootloader.asm" -f bin -o "$BIN/bootloader.bin"
echo -e "${GREEN}    bootloader.bin OK ($(wc -c < "$BIN/bootloader.bin") bytes)${NC}"

# ── 2. Compilar kernel ─────────────────────────────────
echo -e "${YELLOW}==> Compilando kernel...${NC}"
nasm "$SRC/kernel.asm" -f bin -o "$BIN/kernel.bin"
KERNEL_SIZE=$(wc -c < "$BIN/kernel.bin")
KERNEL_SECTORS=$(( (KERNEL_SIZE + 511) / 512 ))
echo -e "${GREEN}    kernel.bin OK ($KERNEL_SIZE bytes / $KERNEL_SECTORS sectores)${NC}"

# ── 3. Armar imagen de disco ───────────────────────────
echo -e "${YELLOW}==> Armando Boot.img...${NC}"
dd if=/dev/zero    of="$BIN/Boot.img" bs=512 count=2880 status=none
dd if="$BIN/bootloader.bin" of="$BIN/Boot.img" bs=512 seek=0 conv=notrunc status=none
dd if="$BIN/kernel.bin"     of="$BIN/Boot.img" bs=512 seek=3 conv=notrunc status=none
echo -e "${GREEN}    Boot.img OK${NC}"

# ── 4. Iniciar QEMU ────────────────────────────────────
echo -e "${YELLOW}==> Iniciando QEMU...${NC}"
echo -e "    (Cierra la ventana de QEMU para volver a la terminal)"
qemu-system-i386 -hda "$BIN/Boot.img"