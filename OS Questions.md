# OS Development — Questions & Answers

> Study notes compiled while building Arion OS
> Reference: *The Little Book About OS Development* — Erik Helin, Adam Renberg (2015)
> Project: Arion OS | Powered by Coding Moves ✦

---

## Chapters 1–4 — Foundations

**Q1. What is an OS in terms of "bare metal" development?**
Bare metal means running code directly on hardware with no underlying OS. You control everything — memory, CPU, devices — yourself. The OS is the first program the hardware runs after the bootloader.

---

**Q2. Why use UNIX/Linux for OS development?**
Linux gives you access to GCC, NASM, QEMU, and other tools needed to cross-compile and test an OS. It also behaves predictably with low-level toolchains unlike Windows.

---

**Q3. Why use C and Assembly for OS development?**
Assembly gives direct CPU control (registers, interrupts, memory). C gives structure and readability without a runtime dependency. Most OS kernels mix both — Assembly for boot/interrupt code, C for logic.

---

**Q4. Can we host an OS like a website — version releases, instant updates?**
Not exactly. An OS must be installed on hardware or a VM. However, updates can be pushed via package managers (like `pkgman` in Haiku/Arion). It is not instant like a website but can be automated.

---

**Q5. What is a Kernel — is it a file, object, or what?**
The kernel is a compiled binary (ELF file) loaded into memory by the bootloader. Once loaded, it runs directly on the CPU. It manages memory, processes, drivers, and hardware access.

---

**Q6. What is a Virtual Machine and how does it allocate resources?**
A VM is software that emulates hardware. It gives a guest OS its own virtual CPU, RAM, and disk using the host's real hardware. Tools like VirtualBox use hypervisors to manage this sharing.

---

**Q7. What is the difference between BIOS and GRUB?**
BIOS is firmware built into the motherboard — it runs first, does hardware checks, then hands control to a bootloader. GRUB is that bootloader — it loads your OS kernel from disk into memory and jumps to it.

---

**Q8. What is an OS ISO and its purpose?**
An ISO is a disk image file — it contains the bootloader, kernel, and filesystem in one file. You can burn it to a USB or CD to boot a real machine, or load it in a VM.

---

**Q9. What is a device driver — is it a piece of code?**
Yes. A driver is C/Assembly code that talks to specific hardware (keyboard, screen, disk) using I/O ports or memory-mapped I/O. It abstracts hardware details so the rest of the OS doesn't need to know them.

---

**Q10. Why can't apps from one OS run on another?**
Each OS has a different system call interface, binary format (ELF vs PE), and C runtime. A Windows `.exe` uses Windows API calls that don't exist on Linux. Example in assembly:
```asm
; Linux system call to exit
mov eax, 1       ; syscall number for exit (Linux)
mov ebx, 0       ; exit code
int 0x80         ; software interrupt — Linux handles this

; On Windows this would be a different API entirely
; int 0x80 means nothing on Windows
```

---

**Q11. What is USER mode vs KERNEL mode?**
Kernel mode (Ring 0) has full hardware access. User mode (Ring 3) is restricted — apps cannot directly access hardware or other processes' memory. The CPU enforces this using privilege levels in the GDT.

---

## Chapter 5 — Segmentation

**Q12. What is a memory segment and why does x86 use them?**
A segment is a region of memory defined by a base address and a limit. x86 uses segments to control which code can access which memory, and at what privilege level.

---

**Q13. What is the GDT and why must its first entry always be null?**
The Global Descriptor Table is an array of segment descriptors. The first entry (index 0) is always a null descriptor — the CPU requires this by design. Using it causes a fault, protecting against uninitialized segment registers.

---

**Q14. Why do we need separate code and data segment descriptors?**
The CPU does not allow a segment to be both executable and writable at the same time. So we need one segment for code (execute/read) and one for data (read/write).

---

**Q15. What is DPL and how does it control memory access?**
DPL (Descriptor Privilege Level) sets the minimum privilege level needed to use a segment. DPL=0 means only kernel code can use it. DPL=3 allows user mode programs to use it.

---

**Q16. What is a "far jump" and why do we need it to load `cs`?**
A far jump specifies both a segment selector and an address. It is the only way to change the `cs` (code segment) register, which determines the current privilege level.

---

**Q17. If both segmentation and paging provide virtual memory, why prefer paging?**
Segmentation requires contiguous physical memory and is hard to grow. Paging maps fixed-size pages anywhere in physical memory, handles fragmentation better, and is standard in modern OSes.

---

## Chapter 6 — Interrupts & Input

**Q18. What is an interrupt and what are the three things that can trigger one?**
An interrupt stops the CPU's current work to handle an event. Three triggers: hardware (keyboard, timer), CPU exceptions (divide by zero, page fault), and software interrupts (`int` instruction — used for system calls).

---

**Q19. What is the IDT and how does it relate to the GDT?**
The IDT (Interrupt Descriptor Table) maps interrupt numbers (0–255) to handler functions. Each entry contains a code segment selector (pointing into the GDT) and the address of the handler.

---

**Q20. Why does the CPU not push the interrupt number onto the stack?**
The CPU has no way to know which handler is running — it just jumps to it. We work around this using NASM macros that push the interrupt number manually before jumping to a common handler.

---

**Q21. What is the difference between an interrupt handler and a trap handler?**
An interrupt handler disables further interrupts while running. A trap handler does not — other interrupts can occur during it. We use trap handlers and disable interrupts manually when needed.

---

**Q22. What is the PIC and why remap its interrupts?**
The PIC (Programmable Interrupt Controller) maps hardware signals to CPU interrupts. By default it uses interrupts 0–15, which clash with CPU exception interrupts. We remap it to 0x20–0x2F to avoid conflicts.

---

**Q23. What happens if we don't acknowledge a hardware interrupt?**
The PIC stops sending further interrupts from that device. Acknowledgement is done by sending `0x20` to the PIC's I/O port after handling the interrupt.

---

**Q24. Why does the keyboard send scan codes instead of ASCII?**
A scan code represents a physical key — both press and release. The OS translates scan codes to ASCII based on the current keyboard layout. This allows flexibility (different languages, key combinations).

---

**Q25. Why save all CPU registers before calling the C interrupt handler?**
The interrupted code does not know an interrupt occurred. It expects all registers to be unchanged when it resumes. The interrupt handler must save and restore every register it touches.

---

## Chapter 7 — Road to User Mode

**Q26. Why can't we just jump directly to a user program?**
We need to know where the program is in memory. GRUB modules solve this — GRUB loads the binary to a known address and tells us via the multiboot structure where it is.

---

**Q27. What is the multiboot structure and who fills it in?**
It is a C struct that GRUB fills with system information — memory map, loaded modules, boot device. GRUB places a pointer to it in the `ebx` register before jumping to the kernel.

---

**Q28. Why does the program in Chapter 7 still run at kernel privilege?**
At this stage we haven't set up paging or user mode segments yet. The program is just code we jump to — it runs at whatever privilege level the kernel is at (Ring 0).

---

**Q29. What is the difference between kernel and user mode memory access?**
Kernel mode can access any memory address. User mode is restricted by page table flags — pages marked kernel-only cause a fault if a user program tries to access them.

---

## Chapters 8 & 9 — Virtual Memory & Paging

**Q30. Why is segmentation alone not enough for virtual memory?**
Segments require contiguous physical memory. If a segment needs to grow, we may need to move it. Paging avoids this by mapping fixed 4KB pages anywhere in physical RAM.

---

**Q31. What is a page frame and how big is it?**
A page frame is a fixed-size block of physical memory. In x86, each page frame is 4096 bytes (4KB). The OS manages physical RAM as a collection of these frames.

---

**Q32. What is the difference between a virtual and physical address?**
A virtual address is what the program uses — it may not correspond to real RAM. The MMU (Memory Management Unit) translates it to a physical address using the page table.

---

**Q33. What is a page fault and when does it occur?**
A page fault is a CPU exception raised when a program accesses a virtual address with no valid mapping in the page table, or one it does not have permission to access.

---

**Q34. Why place the kernel at a high virtual address like 0xC0000000?**
This reserves the low address space (0x00000000–0xBFFFFFFF) for user programs. The kernel sits in the upper 1GB, always mapped in every process, available for system calls without switching page tables.

---

**Q35. What is identity paging?**
Identity paging maps each virtual address to the same physical address (virtual 0x1000 → physical 0x1000). Simple to set up, useful during early boot before a real page table is ready.

---

**Q36. What is the TLB and why invalidate it?**
The TLB (Translation Lookaside Buffer) caches recent virtual-to-physical translations. When we change a page table entry, the old cached translation must be invalidated with `invlpg`, otherwise the CPU uses stale data.

---

**Q37. Why can't we load the kernel at physical address 0x00000000?**
The first 1MB of memory is used by BIOS, GRUB, and memory-mapped I/O. Placing the kernel there would overwrite critical data. The kernel is loaded at 0x00100000 (1MB) instead.

---

## Chapter 10 — Page Frame Allocation

**Q38. Why does the OS need to track free page frames?**
Without tracking, the OS might give two programs the same physical memory, causing data corruption. The page frame allocator keeps a record of which frames are free and which are used.

---

**Q39. What is a bitmap allocator?**
Each bit in the bitmap represents one page frame — 0 = free, 1 = used. Simple and memory-efficient. To find a free frame, scan for the first 0 bit.

---

**Q40. Why can't we use standard `malloc` in the kernel?**
`malloc` depends on a C runtime and OS services that don't exist yet. The kernel must implement its own heap allocator from scratch, using the page frame allocator as the backing memory source.

---

**Q41. What is the circular dependency problem in page table allocation?**
To map a new page frame into virtual memory, we need a page table. But to write to the page table, we need to map it first. We break this by reserving a small region of virtual memory for temporary mappings.

---

## Chapter 11 — User Mode

**Q42. Why do we need two extra GDT entries for user mode?**
We need a user code segment (DPL=3, executable) and a user data segment (DPL=3, read/write). The CPU enforces privilege checks based on these entries when running user programs.

---

**Q43. What is `iret` and why is it the only way to enter user mode?**
`iret` (interrupt return) restores `cs`, `eip`, `eflags`, `ss`, and `esp` from the stack and switches privilege levels. No other instruction can lower the CPU privilege level safely.

---

**Q44. What is the TSS and why does user mode need it?**
The TSS (Task State Segment) tells the CPU which kernel stack to use when an interrupt happens in user mode. Without it, the CPU would not know where to switch the stack during a system call.

---

**Q45. Why must the kernel be mapped in every user process page directory?**
When a system call or interrupt occurs while in user mode, the CPU immediately starts executing kernel code. The kernel must be mapped into the active page directory or the CPU will fault trying to fetch kernel instructions.

---

**Q46. What happens if the IF flag is not set before entering user mode?**
Interrupts stay disabled in user mode forever. The OS can never receive keyboard input, timer ticks, or system calls. The machine effectively freezes from the OS's perspective.

---

## Chapter 12 — File Systems

**Q47. Why does an OS need a file system?**
Without a file system, programs and data have no persistent location. A file system gives named, organized, persistent storage — it is how the OS knows what programs exist and where user data lives.

---

**Q48. What is a VFS and why is it useful?**
A Virtual File System is an abstraction layer over real file systems. It lets the OS treat keyboards, disks, and network sockets all as "files" with the same read/write interface — simplifying application code.

---

**Q49. What is an inode?**
An inode is a data structure that stores metadata about a file — size, permissions, timestamps, and pointers to the actual data blocks. It separates the file's name (directory entry) from its content.

---

## Chapter 13 — System Calls

**Q50. Why implement system calls using software interrupts?**
A software interrupt (`int 0x80`) safely transfers control from user mode (Ring 3) to kernel mode (Ring 0). It is the only controlled way for user code to request kernel services without violating privilege rules.

---

**Q51. What happens to the privilege level during a system call?**
The CPU switches from Ring 3 (user) to Ring 0 (kernel) automatically when the interrupt fires. It uses the TSS to find the kernel stack, pushes registers, and jumps to the kernel's interrupt handler.

---

## Chapter 14 — Multitasking

**Q52. What is cooperative vs preemptive scheduling?**
Cooperative: processes decide when to give up the CPU (they call `yield`). Preemptive: the OS forces a switch using a timer interrupt. Preemptive is fairer but harder to implement and debug.

---

**Q53. What is the PIT and how does it enable preemptive scheduling?**
The PIT (Programmable Interval Timer) fires an interrupt at a set frequency (e.g. every 20ms). The OS handles this interrupt by saving the current process state and switching to the next one.

---

**Q54. Why does each process need its own kernel stack?**
If two processes share one kernel stack, an interrupt during a kernel operation for process A could corrupt the stack that process B is also using. Separate stacks keep each process's kernel state isolated.

---

**Q55. What is the difference between `fork` and `exec`?**
`fork` creates an exact copy of the current process. `exec` replaces the current process with a new program loaded from a file. Together they are the standard UNIX way to launch new programs.

---

**Q56. Why is preemptive scheduling harder to debug than cooperative?**
With cooperative scheduling, context switches only happen at known `yield` points — predictable and reproducible. Preemptive switches can happen at any instruction, making bugs timing-dependent and hard to reproduce.

---

*Arion OS — Study Notes | Powered by Coding Moves ✦*