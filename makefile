# HSOS Makefile (using gnu-efi)

# Paths for EFI system include and library files
EFI_INC = /usr/include/efi
EFI_LIB = /usr/lib

# Build directories
BUILD_DIR = build
BOOT_DIR = bootloader
IMG_DIR = disk_image

# Compiler and linker settings
CC = gcc
LD = ld
OBJCOPY = objcopy

# Compiler flags for EFI applications
CFLAGS = -I$(EFI_INC) -I$(EFI_INC)/x86_64 -fpic -ffreestanding -fno-stack-protector \
        -fno-stack-check -fshort-wchar -mno-red-zone -Wall -Wextra -c

# Linker settings for EFI applications
LDFLAGS = -T $(EFI_LIB)/elf_x86_64_efi.lds -nostdlib -znocombreloc -shared -Bsymbolic

# Objects and target
OBJS = $(BUILD_DIR)/main.o
TARGET_SO = $(BUILD_DIR)/BOOTX64.SO
TARGET = $(BUILD_DIR)/BOOTX64.EFI

all: setup $(TARGET)

setup:
	mkdir -p $(BUILD_DIR) $(IMG_DIR)/EFI/BOOT

$(BUILD_DIR)/main.o: $(BOOT_DIR)/main.c
	$(CC) $(CFLAGS) -o $@ $<

$(TARGET_SO): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ \
		$(EFI_LIB)/crt0-efi-x86_64.o \
		$(OBJS) -L$(EFI_LIB) -lefi -lgnuefi

$(TARGET): $(TARGET_SO)
	$(OBJCOPY) -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel \
		-j .rela -j .reloc --target=efi-app-x86_64 $< $@
	cp $(TARGET) $(IMG_DIR)/EFI/BOOT/

clean:
	rm -rf $(BUILD_DIR) $(IMG_DIR) boot.img

image: all
	rm -f boot.img
	@echo "Creating bootable FAT32 disk image..."
	mkfs.vfat -C boot.img 64000
	mmd -i boot.img ::/EFI
	mmd -i boot.img ::/EFI/BOOT
	mcopy -i boot.img $(IMG_DIR)/EFI/BOOT/BOOTX64.EFI ::/EFI/BOOT
	mcopy -i boot.img startup.nsh ::
	@echo "Verifying disk image contents:"
	mdir -i boot.img ::/EFI/BOOT
	mdir -i boot.img ::
	@echo "Disk image ready at boot.img"

run: image
	@echo "Starting QEMU with UEFI firmware..."
	qemu-system-x86_64 -drive file=boot.img,format=raw,if=none,id=mydisk \
		-device ide-hd,drive=mydisk,bootindex=0 \
		-global isa-debugcon.iobase=0x402 \
		-serial file:serial.log \
		-bios /usr/share/qemu/OVMF.fd
	@echo "QEMU exited. Check serial.log for output."