; Arion x86_64 Boot Entry - Multiboot to Long Mode Transition
; Phase 2: Bootloader & Kernel Entry

bits 32

; Multiboot header
section .multiboot
align 4
    dd 0x1BADB002              ; magic
    dd 0x00                     ; flags
    dd -(0x1BADB002)           ; checksum

section .text
global _start
extern kernel_main

_start:
    ; Set up stack
    mov esp, stack_top
    
    ; Check for CPUID support
    call check_cpuid
    test eax, eax
    jz .no_cpuid
    
    ; Check for long mode support
    call check_long_mode
    test eax, eax
    jz .no_long_mode
    
    ; Set up page tables (identity map first 2GB)
    call setup_page_tables
    
    ; Load GDT
    lgdt [gdt_descriptor]
    
    ; Enable PAE (Physical Address Extension)
    mov eax, cr4
    or eax, (1 << 5)           ; Set PAE bit
    mov cr4, eax
    
    ; Load PML4 table address
    mov eax, pml4_table
    mov cr3, eax
    
    ; Enable long mode (set EFER.LME)
    mov ecx, 0xC0000080        ; EFER MSR
    rdmsr
    or eax, (1 << 8)           ; Set LME bit
    wrmsr
    
    ; Enable paging and protected mode
    mov eax, cr0
    or eax, (1 << 31) | (1 << 0)  ; PG | PE
    mov cr0, eax
    
    ; Far jump to 64-bit code segment
    jmp 0x08:long_mode_start

.no_cpuid:
    mov dword [0xb8000], 0x4f4e4f43  ; "CN" (no CPUID)
    hlt

.no_long_mode:
    mov dword [0xb8000], 0x4f4d4f4c  ; "LM" (no long mode)
    hlt

; Check if CPUID is supported
check_cpuid:
    pushfd
    pop eax
    mov ecx, eax
    xor eax, 1 << 21
    push eax
    popfd
    pushfd
    pop eax
    push ecx
    popfd
    xor eax, ecx
    ret

; Check if long mode is supported
check_long_mode:
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb .no_long_mode
    
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29          ; Check LM bit
    jz .no_long_mode
    
    mov eax, 1
    ret
    
.no_long_mode:
    xor eax, eax
    ret

; Set up identity paging for first 2GB
setup_page_tables:
    ; Clear tables
    mov edi, pml4_table
    mov ecx, 4096
    xor eax, eax
    rep stosd
    
    ; PML4[0] -> PDPT
    mov eax, pdpt_table
    or eax, 0b11               ; Present + writable
    mov [pml4_table], eax
    
    ; PDPT[0] -> PD
    mov eax, pd_table
    or eax, 0b11
    mov [pdpt_table], eax
    
    ; Identity map first 2GB (1024 entries * 2MB each)
    mov edi, pd_table
    mov eax, 0x83              ; Present + writable + huge (2MB pages)
    mov ecx, 1024
.map_pd:
    mov [edi], eax
    add eax, 0x200000          ; 2MB
    add edi, 8
    loop .map_pd
    
    ret

bits 64
long_mode_start:
    ; Clear segment registers
    xor ax, ax
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    ; Call kernel main
    call kernel_main
    
.hang:
    hlt
    jmp .hang

section .data
align 16
gdt_start:
    dq 0                       ; Null descriptor
gdt_code:
    dq 0x00209A0000000000      ; 64-bit code segment
gdt_data:
    dq 0x0000920000000000      ; 64-bit data segment
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

section .bss
align 4096
pml4_table:
    resb 4096
pdpt_table:
    resb 4096
pd_table:
    resb 4096

align 16
stack_bottom:
    resb 16384
stack_top:
