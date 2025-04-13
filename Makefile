# HSOS Makefile

EFI_INC = /usr/include/efi
EFI_LIB = /usr/lib

BUILD_DIR = build
BOOT_DIR = bootloader
IMG_DIR = disk_image

ARCH = x86_64
CC = x86_64-linux-gnu-gcc
LD = x86_64-linux-gnu-ld
CFLAGS = -I$(EFI_INC) -I$(EFI_INC)/$(ARCH) -fno-stack-protector -fpic -fshort-wchar -mno-red-zone -Wall -Wextra -c
LDFLAGS = -T $(BOOT_DIR)/linker.ld -nostdlib -znocombreloc
EFI_LIB_DIR = $(EFI_LIB)/gnuefi

OBJS = $(BUILD_DIR)/main.o
TARGET = $(BUILD_DIR)/BOOTX64.EFI

all: setup $(TARGET)

setup:
	mkdir -p $(BUILD_DIR) $(IMG_DIR)/EFI/BOOT

$(BUILD_DIR)/main.o: $(BOOT_DIR)/main.c
	$(CC) $(CFLAGS) -o $@ $<

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $(OBJS) -L$(EFI_LIB_DIR) -L$(EFI_LIB) -lefi -lgnuefi
	cp $(TARGET) $(IMG_DIR)/EFI/BOOT/

clean:
	rm -rf $(BUILD_DIR) $(IMG_DIR) boot.img

image: all
	rm -f boot.img
	mkfs.vfat -C boot.img 64000
	mmd -i boot.img ::/EFI
	mmd -i boot.img ::/EFI/BOOT
	mcopy -i boot.img $(IMG_DIR)/EFI/BOOT/BOOTX64.EFI ::/EFI/BOOT

run: image
	qemu-system-x86_64 -drive file=boot.img,format=raw,if=none,id=mydisk \
		-device ide-hd,drive=mydisk,bootindex=0 \
		-serial file:serial.log \
		-bios /usr/share/qemu/OVMF.fd
