# Build

## Toolchain

This phase targets a 32-bit multiboot kernel built with an x86_64 cross toolchain.
Ensure the following tools are on PATH:

- x86_64-elf-gcc (with multilib support for `-m32`)
- x86_64-elf-ld
- nasm
- grub-mkrescue (from GRUB)
- qemu-system-i386

### Windows Setup

**Option 1: WSL (Recommended)**

1. Install WSL: `wsl --install`
2. Inside WSL: `sudo apt install build-essential nasm grub-pc-bin xorriso qemu-system-x86`
3. Build cross-compiler or download from [GitHub releases](https://github.com/lordmilko/i686-elf-tools/releases)

**Option 2: Native Windows**

1. Install [MSYS2](https://www.msys2.org/)
2. In MSYS2 terminal:
   ```bash
   pacman -S mingw-w64-x86_64-toolchain nasm grub xorriso qemu
   ```
3. Add MSYS2 bin to PATH: `C:\msys64\usr\bin` and `C:\msys64\mingw64\bin`
4. Build cross-compiler from source or download binaries

## Build & Run

### Linux/WSL/Git Bash

From the repo root:

1. Build kernel and ISO: `make iso`
2. Run in QEMU: `make run`

### Windows PowerShell

From the repo root:

1. Build kernel: `powershell -File scripts\build.ps1`
2. Build ISO: `powershell -File scripts\build_iso.ps1`
3. Run in QEMU: `powershell -File scripts\run_qemu.ps1`

Or use the all-in-one command:

```powershell
powershell -File scripts\build.ps1; powershell -File scripts\build_iso.ps1; powershell -File scripts\run_qemu.ps1
```

The emulator should display: "Hello Arion".

