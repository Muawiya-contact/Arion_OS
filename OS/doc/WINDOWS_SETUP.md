# Arion Windows Setup Guide

## Quick Start (WSL - Recommended)

1. **Install WSL**

   ```powershell
   wsl --install
   ```

   Restart if prompted.

2. **Install build tools in WSL**

   ```bash
   sudo apt update
   sudo apt install build-essential nasm grub-pc-bin xorriso qemu-system-x86 wget
   ```

3. **Install cross-compiler**
   Download pre-built toolchain or build from source:

   ```bash
   cd ~
   wget https://github.com/lordmilko/i686-elf-tools/releases/download/7.1.0/cross-linux-x64.tar.xz
   tar xf cross-linux-x64.tar.xz
   export PATH="$HOME/cross/bin:$PATH"
   echo 'export PATH="$HOME/cross/bin:$PATH"' >> ~/.bashrc
   ```

4. **Navigate to project and build**
   ```bash
   cd /mnt/c/Users/4s\ bazzar/OneDrive/Desktop/Arion/OS
   make iso
   make run
   ```

## Alternative: Native Windows with MSYS2

1. **Install MSYS2** from https://www.msys2.org/

2. **Open MSYS2 MINGW64 terminal** and install tools:

   ```bash
   pacman -Syu
   pacman -S mingw-w64-x86_64-gcc nasm make grub xorriso qemu
   ```

3. **Add to Windows PATH**:
   - `C:\msys64\usr\bin`
   - `C:\msys64\mingw64\bin`

4. **Build cross-compiler** (complex, see https://wiki.osdev.org/GCC_Cross-Compiler)

## PowerShell Scripts (No Make Required)

If you prefer PowerShell without WSL/MSYS2:

```powershell
cd C:\Users\4s bazzar\OneDrive\Desktop\Arion\OS

# Build kernel
powershell -File scripts\build.ps1

# Create ISO
powershell -File scripts\build_iso.ps1

# Run in QEMU
powershell -File scripts\run_qemu.ps1
```

**Note:** You still need to install the toolchain (x86_64-elf-gcc, nasm, grub-mkrescue, qemu).

## Recommended: Use WSL

WSL is the easiest option for OS development on Windows. It provides a full Linux environment with access to your Windows files.

