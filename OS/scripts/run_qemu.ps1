# PowerShell QEMU run script
$ErrorActionPreference = "Stop"

$ROOT_DIR = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ISO = Join-Path $ROOT_DIR "iso\Arion.iso"

if (-not (Test-Path $ISO)) {
    Write-Error "ISO not found. Run build script first."
    exit 1
}

qemu-system-i386 -cdrom $ISO -m 256M

