# Arion

Arion is a learning-focused operating system project targeting x86_64 architecture.

## Quick Start

```bash
cd OS
make iso && make run
```

See [BUILD.md](doc/BUILD.md) and [WINDOWS_SETUP.md](doc/WINDOWS_SETUP.md) for detailed setup.

## Project Structure

```
OS/
├── arch/                          # Architecture-specific code
│   ├── x86_64/                    # x86_64 (primary target)
│   │   ├── boot/                  # Bootloader code
│   │   ├── cpu/                   # GDT, TSS, CPU setup
│   │   ├── irq/                   # Interrupt handling
│   │   └── mm/                    # Paging, memory management
│   ├── arm64/                     # ARM64 (future)
│   └── riscv/                     # RISC-V (future)
│
├── boot/                          # Bootloader
│   ├── grub/                      # GRUB multiboot config
│   ├── bios/                      # BIOS-specific code
│   ├── uefi/                      # UEFI support (future)
│   └── common/                    # Common boot routines
│
├── kernel/                        # Kernel core
│   ├── core/                      # Main kernel (kernel.c, init.c, panic.c)
│   ├── sched/                     # Scheduler
│   ├── syscall/                   # System call interface
│   ├── mm/                        # Memory management
│   ├── drivers/                   # Kernel-internal drivers
│   ├── linker.ld                  # Kernel linker script
│   └── Makefile                   # Kernel build
│
├── libk/                          # Kernel library
│   ├── string.c                   # String utilities
│   ├── printf.c                   # VGA text output
│   └── memory.c                   # Memory utilities
│
├── include/                       # Global headers
│   ├── kernel/                    # Kernel internal (process.h, memory.h, sched.h, panic.h)
│   ├── arch/x86_64/               # Architecture (cpu.h, gdt.h, paging.h)
│   ├── libk/                      # Kernel lib (string.h, stdio.h)
│   └── uapi/                      # User ABI (unistd.h, fcntl.h)
│
├── drivers/                       # Device drivers
│   ├── display/                   # Framebuffer
│   ├── input/                     # Keyboard, mouse
│   ├── pci/                       # PCI bus
│   └── virtio/                    # VirtIO devices
│
├── fs/                            # Filesystem
│   ├── vfs.c                      # Virtual file system
│   ├── ramfs.c                    # RAM filesystem
│   ├── ext2.c                     # EXT2 (future)
│   └── fat32.c                    # FAT32 (future)
│
├── net/                           # Network stack
│   ├── socket.c                   # Socket layer
│   ├── tcp.c                      # TCP protocol
│   ├── udp.c                      # UDP protocol
│   └── netdev.c                   # Network device
│
├── user/                          # Userland
│   ├── libc/                      # User C library
│   └── apps/                      # User applications (shell, echo, hello)
│
├── gui/                           # GUI (Phase 8)
│   ├── compositor/                # Window manager
│   └── widgets/                   # UI elements
│
├── mm/                            # Top-level memory API
├── tools/                         # Build tools (mkfs, iso packer)
├── scripts/                       # Build & run scripts
├── tests/                         # Unit & integration tests
├── config/                        # Configuration headers
├── doc/                           # Documentation
│   ├── BUILD.md                   # Build instructions
│   ├── DESIGN.md                  # Architecture notes
│   ├── ROADMAP.md                 # 8-phase development plan
│   ├── API.md                     # API documentation
│   └── WINDOWS_SETUP.md           # Windows dev guide
│
├── .github/workflows/             # CI/CD
├── Makefile                       # Top-level build
├── .gitignore
├── LICENSE
└── README.md                      # This file
```

## Key Features (Phase 1)

- ✓ Multiboot GRUB bootloader
- ✓ 32-bit freestanding kernel
- ✓ VGA text output (printf to 0xB8000)
- ✓ Cross-platform build (Linux, WSL, Windows)
- ✓ Automated ISO and QEMU scripts

## Documentation

- [BUILD.md](doc/BUILD.md) - Setup and build instructions
- [WINDOWS_SETUP.md](doc/WINDOWS_SETUP.md) - Windows developer guide
- [ROADMAP.md](doc/ROADMAP.md) - 8-phase development plan
- [DESIGN.md](doc/DESIGN.md) - Architecture and design notes
- [API.md](doc/API.md) - Kernel and user-space API

