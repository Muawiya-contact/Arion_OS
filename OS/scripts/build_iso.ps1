# PowerShell ISO build script
$ErrorActionPreference = "Stop"

$ROOT_DIR = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$BUILD_DIR = Join-Path $ROOT_DIR "build\x86_64"
$ISO_DIR = Join-Path $ROOT_DIR "iso"
$STAGE_DIR = Join-Path $BUILD_DIR "iso-root"

$KERNEL_ELF = Join-Path $BUILD_DIR "kernel\kernel.elf"

if (-not (Test-Path $KERNEL_ELF)) {
    Write-Error "Kernel not built. Run 'make kernel' first."
    exit 1
}

if (Test-Path $STAGE_DIR) {
    Remove-Item -Recurse -Force $STAGE_DIR
}

New-Item -ItemType Directory -Force -Path "$STAGE_DIR\boot\grub" | Out-Null

Copy-Item $KERNEL_ELF "$STAGE_DIR\boot\kernel.elf"
Copy-Item (Join-Path $ROOT_DIR "boot\grub\grub.cfg") "$STAGE_DIR\boot\grub\grub.cfg"

New-Item -ItemType Directory -Force -Path $ISO_DIR | Out-Null

grub-mkrescue -o (Join-Path $ISO_DIR "Arion.iso") $STAGE_DIR

Write-Host "ISO created at $(Join-Path $ISO_DIR 'Arion.iso')" -ForegroundColor Green

