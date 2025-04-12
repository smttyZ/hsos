# Compiler/Linker Tools
CC = gcc
LD = ld

# Directories
BOOTLOADER_DIR = bootloader
BUILD_DIR = build
DISK_IMG_DIR = disk_image
EFI_BOOT_DIR = $(DISK_IMG_DIR)/EFI/BOOT

# Target EFI file name
TARGET_EFI = $(BUILD_DIR)/bootloader.efi
FINAL_EFI = $(EFI_BOOT_DIR)/BOOTX64.EFI
DISK_IMAGE = $(DISK_IMG_DIR)/boot.img

# Disk Image Size (in MB)
DISK_SIZE = 64

# GNU-EFI specific paths and files
ARCH = x86_64
GNUEFI_LIB = /usr/lib/libgnuefi.a
GNUEFI_CRT0 = /usr/lib/crt0-efi-$(ARCH).o
EFI_LDS = /usr/lib/elf_$(ARCH)_efi.lds

# Compiler Flags for Bootloader (UEFI specific)
CFLAGS = -c -ffreestanding -fno-stack-protector -fshort-wchar -mno-red-zone -Wall -Wextra -I$(BOOTLOADER_DIR) -I/usr/include/efi -I/usr/include/efi/$(ARCH) -DEFI_FUNCTION_WRAPPER -m64
# Linker Flags for Bootloader (UEFI specific)
LDFLAGS = -nostdlib -znocombreloc -T $(EFI_LDS) -shared -Bsymbolic -L/usr/lib $(GNUEFI_CRT0) $(GNUEFI_LIB) -lefi

# Source files
BOOTLOADER_SRCS = $(wildcard $(BOOTLOADER_DIR)/*.c)
BOOTLOADER_OBJS = $(patsubst $(BOOTLOADER_DIR)/%.c, $(BUILD_DIR)/%.o, $(BOOTLOADER_SRCS))

# QEMU Command for Ubuntu WSL2 with UEFI support
FIRMWARE_DIR = firmware
OVMF_VARS_COPY = $(BUILD_DIR)/ovmf_vars_copy.fd

# Create a writable copy of OVMF_VARS for QEMU
$(OVMF_VARS_COPY): | $(BUILD_DIR) $(FIRMWARE_DIR)
	@echo "CP   Creating writable copy of OVMF_VARS"
	@cp /usr/share/OVMF/OVMF_VARS_4M.fd $@
	@chmod 644 $@

# Create firmware directory
$(FIRMWARE_DIR):
	@echo "MKDIR  $@"
	@mkdir -p $@

# QEMU command for Ubuntu - with GUI and debug options
QEMU_CMD = qemu-system-x86_64 -machine q35 \
	-drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE_4M.fd \
	-drive if=pflash,format=raw,file=$(OVMF_VARS_COPY) \
	-drive file=$(DISK_IMAGE),format=raw,if=ide,media=disk \
	-debugcon file:debug.log -global isa-debugcon.iobase=0x402 \
	-m 512 \
	-vga std

# Default target: Build the final EFI and the bootable disk image
.PHONY: all
all: $(FINAL_EFI) format_disk

# Rule to link the bootloader EFI executable
$(TARGET_EFI): $(BOOTLOADER_OBJS) | $(BUILD_DIR)
	@echo "LD   $@"
	@$(LD) $(LDFLAGS) $(BOOTLOADER_OBJS) -o $@

# Rule to compile bootloader C source files
$(BUILD_DIR)/%.o: $(BOOTLOADER_DIR)/%.c | $(BUILD_DIR)
	@echo "CC   $<"
	@$(CC) $(CFLAGS) $< -o $@

# Rule to create and format the disk image as FAT32
.PHONY: format_disk
format_disk: | $(DISK_IMG_DIR)
	@echo "DD   $(DISK_IMAGE)"
	@dd if=/dev/zero of=$(DISK_IMAGE) bs=1M count=$(DISK_SIZE)
	@echo "MKFS.FAT $(DISK_IMAGE)"
	@mkfs.fat -F 32 $(DISK_IMAGE)
	@mmd -i $(DISK_IMAGE) ::/EFI
	@mmd -i $(DISK_IMAGE) ::/EFI/BOOT
	@mcopy -i $(DISK_IMAGE) $(TARGET_EFI) ::/EFI/BOOT/BOOTX64.EFI

# Rule to create the EFI boot directory
$(EFI_BOOT_DIR): | $(DISK_IMG_DIR)
	@echo "MKDIR  $@"
	@mkdir -p $@

# Rule to copy the bootloader to the EFI directory
$(FINAL_EFI): $(TARGET_EFI) | $(EFI_BOOT_DIR)
	@echo "CP   $@ <-- $(TARGET_EFI)"
	@cp $(TARGET_EFI) $@

# Rule to create necessary directories
$(BUILD_DIR) $(DISK_IMG_DIR):
	@echo "MKDIR  $@"
	@mkdir -p $@

# Phony target for running in QEMU
.PHONY: run
run: $(FINAL_EFI) format_disk $(OVMF_VARS_COPY)
	@echo "QEMU   Running $(DISK_IMAGE)"
	@$(QEMU_CMD)

# Phony target for cleaning up build files
.PHONY: clean
clean:
	@echo "CLEAN"
	@rm -rf $(BUILD_DIR) $(DISK_IMG_DIR)