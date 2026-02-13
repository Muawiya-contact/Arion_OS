#!/usr/bin/env bash
set -e

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
BUILD_DIR="$ROOT_DIR/build/x86_64"
ISO_DIR="$ROOT_DIR/iso"
STAGE_DIR="$BUILD_DIR/iso-root"

KERNEL_ELF="$BUILD_DIR/kernel/kernel.elf"

if [ ! -f "$KERNEL_ELF" ]; then
	echo "Kernel not built. Run 'make kernel' first."
	exit 1
fi

rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR/boot/grub"

cp "$KERNEL_ELF" "$STAGE_DIR/boot/kernel.elf"
cp "$ROOT_DIR/boot/grub/grub.cfg" "$STAGE_DIR/boot/grub/grub.cfg"

mkdir -p "$ISO_DIR"
grub-mkrescue -o "$ISO_DIR/Arion.iso" "$STAGE_DIR"
echo "ISO created at $ISO_DIR/Arion.iso"

