#!/usr/bin/env sh
set -e

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ISO="$ROOT_DIR/iso/Arion.iso"

if [ ! -f "$ISO" ]; then
	echo "ISO not found. Run 'make iso' first."
	exit 1
fi

echo "Starting Arion in QEMU..."
qemu-system-x86_64 -cdrom "$ISO" -m 512M

