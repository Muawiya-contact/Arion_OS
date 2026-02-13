ROOT_DIR := ..
BUILD_DIR := $(ROOT_DIR)/build/x86_64/kernel

CC ?= x86_64-elf-gcc
LD ?= x86_64-elf-ld
AS ?= nasm

CFLAGS := -std=gnu11 -ffreestanding -O2 -Wall -Wextra -mcmodel=large -fno-pic -fno-stack-protector -nostdlib -mno-red-zone
LDFLAGS := -T $(ROOT_DIR)/kernel/linker.ld -nostdlib
ASFLAGS := -f elf64

KERNEL_C := $(shell find $(ROOT_DIR)/kernel -name "*.c")
LIBK_C := $(shell find $(ROOT_DIR)/libk -name "*.c")
ARCH_ASM := $(ROOT_DIR)/arch/x86_64/boot/entry.asm

KERNEL_OBJS := $(patsubst $(ROOT_DIR)/%.c,$(BUILD_DIR)/%.o,$(KERNEL_C))
LIBK_OBJS := $(patsubst $(ROOT_DIR)/%.c,$(BUILD_DIR)/%.o,$(LIBK_C))
ARCH_OBJ := $(BUILD_DIR)/arch/x86_64/boot/entry.o

OBJS := $(KERNEL_OBJS) $(LIBK_OBJS) $(ARCH_OBJ)

TARGET := $(BUILD_DIR)/kernel.elf

.PHONY: all clean

all: $(TARGET)

$(BUILD_DIR)/%.o: $(ROOT_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -I$(ROOT_DIR)/include -c $< -o $@

$(ARCH_OBJ): $(ARCH_ASM)
	@mkdir -p $(dir $@)
	nasm $(ASFLAGS) $< -o $@

$(TARGET): $(OBJS) $(ROOT_DIR)/kernel/linker.ld
	@mkdir -p $(dir $@)
	$(LD) $(LDFLAGS) -o $@ $(OBJS)

clean:
	@rm -rf $(BUILD_DIR)
