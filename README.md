# Arion - A Learning-Focused x86_64 Operating System

## Overview

Arion is an educational operating system project demonstrating the design and implementation of a modern 64-bit OS for x86_64 architecture. Built from scratch with comprehensive documentation, it progresses through 8 phases from bootloader to a fully functional GUI-based system.

**Current Status:** Phase 1 Complete ✓  
**Target:** Phase 2 (Long Mode Transition)

## Repository Structure

```
Arion/
├── OS/                      # Main OS source code (see OS/README.md)
├── README.md               # This file
└── ProjectReport.md        # Complete documentation of all 8 phases
```

## Quick Start

```bash
cd OS
make iso && make run
```

**Expected Output:** "Hello Arion" printed to VGA in QEMU

See [OS/doc/BUILD.md](OS/doc/BUILD.md) for detailed setup instructions.

## Project Goals

1. **Educational:** Understand how modern operating systems work at the hardware level
2. **Reproducible:** Works on Linux, WSL, Windows, and multiple emulators
3. **Modular:** Easy to extend with new architectures (ARM64, RISC-V) and features
4. **Well-Documented:** Every phase has clear goals, tasks, and deliverables

## 8-Phase Development Plan

| Phase | Goal                                    | Status        |
| ----- | --------------------------------------- | ------------- |
| 1     | Project Foundation & Build Setup        | ✓ Complete    |
| 2     | Long Mode Transition & x86_64 Bootstrap | ✓ Complete    |
| 3     | Core Kernel & Process Management        | → In Progress |
| 4     | Syscall Layer & Userland                | Planned       |
| 5     | Filesystem & Storage                    | Planned       |
| 6     | Drivers & Input/Output                  | Planned       |
| 7     | GUI & Compositor                        | Planned       |
| 8     | Testing, CI, and Installer              | Planned       |

**Estimated Timeline:** 8-16 weeks (part-time)

## Key Files

- [OS/README.md](OS/README.md) - OS architecture and folder structure
- [OS/doc/ROADMAP.md](OS/doc/ROADMAP.md) - Detailed 8-phase plan with tasks and deliverables
- [OS/doc/BUILD.md](OS/doc/BUILD.md) - Build system and toolchain setup
- [OS/doc/WINDOWS_SETUP.md](OS/doc/WINDOWS_SETUP.md) - Windows development guide
- [OS/Makefile](OS/Makefile) - Top-level build orchestration

## What You'll Learn

- **Bootloaders:** BIOS/UEFI multiboot, real to protected to long mode
- **Memory Management:** Paging, virtual addressing, heap allocation
- **Concurrency:** Context switching, scheduling, process management
- **System Calls:** Userland/kernel boundary, privilege levels
- **Filesystems:** VFS abstraction, RAMFS, file I/O
- **Device Drivers:** Hardware abstraction, interrupt handling
- **GUI:** Framebuffer graphics, window management, input handling

## Technical Specifications

- **Target Architecture:** x86_64
- **Bootloader:** GRUB (multiboot)
- **Kernel:** Freestanding C
- **Build System:** Make + cross-compiler (x86_64-elf-gcc)
- **Testing:** QEMU, VirtualBox
- **CI/CD:** GitHub Actions (planned)

## Getting Started

1. **Clone & Setup:**

   ```bash
   git clone https://github.com/yourusername/Arion.git
   cd Arion/OS
   ```

2. **Check Requirements:**
   - Linux/WSL: See [OS/doc/BUILD.md](OS/doc/BUILD.md)
   - Windows: See [OS/doc/WINDOWS_SETUP.md](OS/doc/WINDOWS_SETUP.md)

3. **Build & Run:**

   ```bash
   make iso && make run
   ```

4. **Next Steps:**
   - Read [OS/doc/ROADMAP.md](OS/doc/ROADMAP.md) for Phase 2 tasks
   - Check individual phase implementation guides in `OS/doc/`

## Documentation

All documentation is in [OS/doc/](OS/doc/):

- **ROADMAP.md** - Complete 8-phase plan
- **BUILD.md** - Build system and toolchain
- **DESIGN.md** - Architecture and design notes
- **WINDOWS_SETUP.md** - Windows developer setup
- **API.md** - Kernel and user-space API

## Resources & References

- [OSDev.org](https://wiki.osdev.org/) - OS development wiki
- [Intel x86-64 ABI](https://github.com/hjl-tools/x86-psABI) - ABI specification
- [GRUB Multiboot](https://www.gnu.org/software/grub/manual/multiboot/) - Multiboot spec
- [Linux Kernel Docs](https://www.kernel.org/doc/html/latest/) - Reference implementation

## Contributing

This is primarily an educational project. Feel free to fork and extend with:

- Additional architectures (ARM64, RISC-V)
- Advanced scheduling algorithms
- Network stack implementation
- Filesystem drivers (EXT2, FAT32)
- Improved GUI capabilities

## License

See [OS/LICENSE](OS/LICENSE)

---

**Last Updated:** February 2026  
**Current Phase:** 2 ✓  
**Next Phase:** 3 (Core Kernel & Process Management)
