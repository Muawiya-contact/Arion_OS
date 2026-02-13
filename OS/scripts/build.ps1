# PowerShell build script for kernel
$ErrorActionPreference = "Stop"

$ROOT_DIR = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$BUILD_DIR = Join-Path $ROOT_DIR "build\x86_64\kernel"

$CC = "x86_64-elf-gcc"
$LD = "x86_64-elf-ld"
$AS = "nasm"

$CFLAGS = @(
    "-std=gnu11",
    "-ffreestanding",
    "-O2",
    "-Wall",
    "-Wextra",
    "-m32",
    "-fno-pic",
    "-fno-stack-protector",
    "-nostdlib",
    "-I$ROOT_DIR\include"
)

$LDFLAGS = @(
    "-T", "$ROOT_DIR\kernel\linker.ld",
    "-nostdlib",
    "-m", "elf_i386"
)

$ASFLAGS = @("-f", "elf32")

Write-Host "Building kernel..." -ForegroundColor Cyan

# Find all C source files
$KERNEL_C = Get-ChildItem -Path "$ROOT_DIR\kernel" -Filter *.c -Recurse
$LIBK_C = Get-ChildItem -Path "$ROOT_DIR\libk" -Filter *.c -Recurse
$ARCH_ASM = "$ROOT_DIR\arch\x86_64\boot\entry.asm"

$OBJS = @()

# Compile kernel C files
foreach ($file in $KERNEL_C) {
    $rel = $file.FullName.Substring($ROOT_DIR.Length + 1)
    $obj = Join-Path $BUILD_DIR ($rel -replace '\.c$', '.o')
    $objDir = Split-Path -Parent $obj
    
    if (-not (Test-Path $objDir)) {
        New-Item -ItemType Directory -Force -Path $objDir | Out-Null
    }
    
    Write-Host "  CC $rel" -ForegroundColor Gray
    & $CC @CFLAGS -c $file.FullName -o $obj
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    $OBJS += $obj
}

# Compile libk C files
foreach ($file in $LIBK_C) {
    $rel = $file.FullName.Substring($ROOT_DIR.Length + 1)
    $obj = Join-Path $BUILD_DIR ($rel -replace '\.c$', '.o')
    $objDir = Split-Path -Parent $obj
    
    if (-not (Test-Path $objDir)) {
        New-Item -ItemType Directory -Force -Path $objDir | Out-Null
    }
    
    Write-Host "  CC $rel" -ForegroundColor Gray
    & $CC @CFLAGS -c $file.FullName -o $obj
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    $OBJS += $obj
}

# Assemble entry.asm
$asmObj = Join-Path $BUILD_DIR "arch\x86_64\boot\entry.o"
$asmObjDir = Split-Path -Parent $asmObj
if (-not (Test-Path $asmObjDir)) {
    New-Item -ItemType Directory -Force -Path $asmObjDir | Out-Null
}

Write-Host "  AS arch\x86_64\boot\entry.asm" -ForegroundColor Gray
& $AS @ASFLAGS $ARCH_ASM -o $asmObj
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
$OBJS += $asmObj

# Link
$TARGET = Join-Path $BUILD_DIR "kernel.elf"
Write-Host "  LD kernel.elf" -ForegroundColor Gray
& $LD @LDFLAGS -o $TARGET $OBJS
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "Kernel built successfully: $TARGET" -ForegroundColor Green
