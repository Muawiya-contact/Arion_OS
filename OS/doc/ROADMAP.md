# Arion Development Roadmap: 8 Phases to a Fully Functional OS

## Executive Summary

This roadmap outlines the construction of Arion—a teaching-oriented 64-bit operating system for x86_64 architecture. The project progresses through 8 phases from basic bootloader to a usable userland environment with a GUI.

---

## Phase 1: Project Foundation & Build Setup ✓

**Goal:** Establish a clean, reproducible build system and folder structure.

**Tasks:**

- Create all directories and placeholder files
- Setup cross-compilation toolchain (x86_64-elf-gcc)
- Implement top-level Makefile + sub-Makefiles (kernel, user, boot)
- Write scripts/run_qemu.sh and scripts/build_iso.sh
- Create initial BUILD.md and DESIGN.md

**Deliverables:**

- Skeleton repo with working build scripts
- Able to compile empty kernel and build ISO
- QEMU boots, prints a "Hello Arion" banner

**Verification:**

```bash
make iso && make run
# Output: "Hello Arion"
```

---

## Phase 2: Long Mode Transition & x86_64 Bootstrap ✓

**Status:** Complete  
**Estimated Duration:** 3-5 days

**Deliverables:**

- ✓ GDT (Global Descriptor Table) setup for 64-bit mode
- ✓ Page tables for identity mapping (first 2GB)
- ✓ Transition from 32-bit to 64-bit protected mode
- ✓ x86_64 kernel entry point (kernel_main)
- ✓ Stack setup in high memory

**Key Components:**

- ✓ `arch/x86_64/boot/entry.asm`: Multiboot header, CPUID/long mode checks, page table setup, GDT loading, long mode transition
- ✓ `kernel/core/kernel.c`: Enhanced 64-bit kernel entry with boot banner
- ✓ `kernel/Makefile`: Updated for 64-bit compilation (nasm, x86_64-elf-gcc)
- ✓ `kernel/linker.ld`: Updated with proper section alignment

**Implementation Details:**

- CPUID support detection
- Long mode capability verification
- 4-level paging (PML4 → PDPT → PD) with 2MB huge pages
- Identity mapping of first 2GB physical memory
- PAE (Physical Address Extension) enabled
- EFER.LME bit set for long mode
- Far jump to 64-bit code segment
- VGA text mode output working in 64-bit mode

**Testing:**

- ✓ Kernel prints "Arion Operating System [x86_64]" boot banner
- ✓ Successfully executes 64-bit code
- ✓ VGA text mode functional
- ✓ System halts gracefully with kernel_panic

**Verification:**

```bash
cd OS
make clean && make iso && make run
# Expected: Boot banner displayed in QEMU VGA console
```

---

## Phase 2: Bootloader & Kernel Entry (Legacy - Replaced by Above)

**Goal:** Make CPU start in BIOS and UEFI, load kernel, and initialize basic kernel structures.

**Tasks:**

- Implement boot/bios/stage2.asm (16-bit → 32-bit → 64-bit transition)
- Implement boot/uefi/efi_stub.c for UEFI boot
- Kernel entry point: kernel/core/init.c
- Basic console output (printk / printf) to serial
- Detect physical memory map from BIOS/UEFI

**Deliverables:**

- Kernel prints boot message to serial
- Runs on QEMU (BIOS & UEFI)
- Verified memory map is parsed

---

## Phase 3: Core Kernel & Process Management

**Goal:** Implement main kernel subsystems for basic OS functionality.

**Tasks:**

- Implement memory management (kmalloc, vmm, paging)
- Implement simple process abstraction (process.c, PCB, scheduling)
- Implement minimal scheduler (kernel/sched/scheduler.c)
- Implement kernel panic and assert handling

**Deliverables:**

- Kernel can create processes (even just dummy idle process)
- Paging and virtual memory initialized
- Serial console works; kernel panics display correctly

---

## Phase 4: Syscall Layer & Userland

**Goal:** Enable user programs to talk to kernel through system calls.

**Tasks:**

- Implement kernel/syscall/syscall_table.c and dispatcher
- Centralize syscall numbers in include/uapi/unistd.h
- Implement basic syscalls: read, write, exit, fork, execve
- Build user/libc with syscall wrappers
- Build minimal shell in user/apps/shell.c

**Deliverables:**

- User programs can print to console
- Shell works inside QEMU
- Kernel safely dispatches syscalls

---

## Phase 5: Filesystem & Storage

**Goal:** Implement Virtual File System and simple FS drivers.

**Tasks:**

- Implement fs/vfs.c, fs/ramfs.c, fs/ext2.c (optional)
- Implement mounting logic and file descriptor layer
- Integrate with syscall_open, read, write, close
- Test with small user programs reading/writing files

**Deliverables:**

- User programs can open, read, write files
- RAMFS works in QEMU
- VFS layer supports multiple filesystem drivers

---

## Phase 6: Drivers & Input/Output

**Goal:** Support hardware abstraction and basic input/output.

**Tasks:**

- Implement PCI, virtio, display (framebuffer), input (keyboard)
- Driver registration model with driver_t and device_t
- Hook input devices to kernel and expose via syscalls (read from keyboard)
- Framebuffer output for kernel messages

**Deliverables:**

- User programs can interact with keyboard and display
- Framebuffer shows simple graphics (e.g., boot logo)
- Drivers can be extended for future devices

---

## Phase 7: GUI & Compositor

**Goal:** Implement a simple user-space GUI with basic windowing.

**Tasks:**

- Implement gui/compositor/compositor.c to manage windows
- Implement gui/widgets/ with drawing primitives
- Connect framebuffer driver to compositor
- Hook keyboard/mouse events to GUI
- Build minimal GUI apps (text editor, terminal)

**Deliverables:**

- GUI boots in userland
- Compositor manages multiple windows
- Input events routed correctly to applications

---

## Phase 8: Testing, CI, and Installer

**Goal:** Make the OS stable, testable, and distributable.

**Tasks:**

- Implement QEMU-based integration tests (tests/integration)
- Unit tests for kernel, libk, libc, filesystem
- Setup GitHub Actions CI for build + QEMU smoke tests
- Build bootable ISO and optional USB installer
- Add release docs (doc/RELEASE.md)

**Deliverables:**

- Fully bootable ISO tested on QEMU
- Verified syscalls, filesystem, GUI functionality
- Continuous Integration ensures future commits don't break builds

---

## Memory Management (Virtual & Physical)

**Estimated Duration:** 5-7 days  
**Deliverables:**

- Physical memory allocator (buddy system or bitmap)
- Virtual memory mapper (demand paging ready)
- Heap allocator (kmalloc/kfree)
- Memory-mapped I/O regions
- Early boot memory accounting

**Key Components:**

- `kernel/mm/kmalloc.c`: heap allocation
- `arch/x86_64/mm/paging.c`: page table manipulation
- `kernel/mm/mm.h`: memory manager interface
- Physical frame tracking structure

**Testing:**

- Allocate and free heap memory
- Verify page tables are consistent
- Map MMIO region (VGA, serial port)

---

## Phase 5: Process & Scheduler

**Estimated Duration:** 4-6 days  
**Deliverables:**

- Process control block (PCB) structure
- Context switching (register save/restore)
- Round-robin scheduler
- Timer interrupt integration
- Process creation and termination

**Key Components:**

- `include/kernel/process.h`: process structure
- `kernel/core/process.c`: process lifecycle
- `kernel/sched/scheduler.c`: scheduling algorithm
- Timer setup (PIT or APIC timer)

**Testing:**

- Create 2-3 kernel threads
- Context switch via timer interrupt
- Each thread prints its ID periodically

---

## Phase 6: System Calls & Userland Support

**Estimated Duration:** 5-7 days  
**Deliverables:**

- Syscall dispatcher (via INT 0x80 or SYSCALL instruction)
- Basic syscalls: write, exit, fork, exec
- User-space privilege level (ring 3)
- User stack and process isolation
- libc stubs for common functions

**Key Components:**

- `kernel/syscall/dispatch.c`: syscall handler
- `kernel/syscall/syscall_table.c`: syscall table
- `user/libc/syscall.c`: user-facing syscall wrappers
- User program linker script

**Testing:**

- Simple user program: `printf("Hello from userland\n"); exit(0);`
- Context switch between kernel and user mode

---

## Phase 7: Filesystem & Storage

**Estimated Duration:** 6-8 days  
**Deliverables:**

- VFS (Virtual File System) abstraction
- RAMFS implementation (in-memory filesystem)
- Basic file operations: open, read, write, close
- Directory navigation
- Initial ramdisk (initrd) support

**Key Components:**

- `fs/vfs.c`: VFS interface
- `fs/ramfs.c`: RAM-based filesystem
- Inode and dentry structures
- File descriptor table per process

**Testing:**

- Create, read, write files in RAMFS
- Directory listing
- Load and execute binaries from filesystem

---

## Phase 8: GUI & Advanced I/O

**Estimated Duration:** 7-10 days  
**Deliverables:**

- Framebuffer driver
- Input device handling (keyboard, mouse)
- Simple GUI compositor (window manager)
- Graphics rendering library
- Shell with basic command execution

**Key Components:**

- `drivers/display/framebuffer.c`: graphics output
- `drivers/input/keyboard.c`: keyboard driver
- `gui/compositor/compositor.c`: window management
- `gui/widgets/draw.c`: UI drawing primitives
- `user/apps/shell.c`: command interpreter

**Testing:**

- Boot to desktop
- Keyboard input → shell command execution
- Output display via framebuffer

---

## Implementation Notes

### Cross-Compilation

All phases use a x86_64-elf cross-compiler targeting:

- **32-bit Stage 1** (Phase 1): Multiboot-compliant 32-bit kernel
- **64-bit Stage 2** (Phase 2+): 64-bit long mode with higher-half mapping

### Testing & Emulation

- **Emulator:** QEMU i386/x86_64
- **VirtualBox:** Supported via ISO image
- **Hardware:** Bootable USB (GRUB legacy or EFI future)

### Code Quality

- Minimal dependencies (freestanding environment)
- Modular architecture (easy to extend to ARM64, RISC-V)
- Comprehensive comments for educational value

### Documentation

Each phase includes:

- Implementation guide (doc/PHASE_N.md)
- API documentation (include/\*/\*.h)
- Test cases and verification steps

---

## Success Criteria

| Phase | Success             | Verification                     |
| ----- | ------------------- | -------------------------------- |
| 1     | Boot prints "Hello" | VGA output in QEMU               |
| 2     | 64-bit execution    | CPU executes 64-bit instructions |
| 3     | Exception handling  | Catch page faults gracefully     |
| 4     | Dynamic allocation  | kmalloc/kfree work correctly     |
| 5     | Multitasking        | Multiple threads context-switch  |
| 6     | User programs       | Ring 3 binaries execute syscalls |
| 7     | Persistent files    | Read/write files on RAMFS        |
| 8     | Interactive shell   | User types commands → results    |

---

## Estimated Total Timeline

- **Minimum:** 4-6 weeks (solo developer, full-time)
- **Realistic:** 8-12 weeks (part-time, 10 hrs/week)
- **Learning-focused:** 12-16 weeks (deep dive on each component)

---

## Future Extensions (Post-Phase 8)

- EXT2/FAT32 filesystem drivers
- Network stack (TCP/IP)
- PCI device enumeration
- ACPI support
- Multi-core (SMP)
- 32-bit ARM64 port
- RISC-V port

---

## Resources & References

- [OSDev.org](https://wiki.osdev.org/)
- [Intel x86-64 ABI](https://github.com/hjl-tools/x86-psABI)
- [GRUB Multiboot Specification](https://www.gnu.org/software/grub/manual/multiboot/)
- [The Linux Kernel Documentation](https://www.kernel.org/doc/html/latest/)

---

**Current Phase:** 1 ✓  
**Next Phase:** 2 (Long Mode Transition)  
**Last Updated:** February 2026
