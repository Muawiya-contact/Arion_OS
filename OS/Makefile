# Arion Makefile

ROOT_DIR := $(CURDIR)

.PHONY: all kernel boot user iso run clean help

all: iso

help:
	@echo "Targets: kernel, boot, user, iso, run, clean"

kernel:
	@$(MAKE) -C kernel

boot:
	@$(MAKE) -C boot

user:
	@$(MAKE) -C user

iso: kernel
	@sh scripts/build_iso.sh

run: iso
	@sh scripts/run_qemu.sh

clean:
	@rm -rf build iso

