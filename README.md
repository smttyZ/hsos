# HSOS - Simple UEFI Bootloader

A minimal UEFI bootloader designed to be bootable from a USB drive.

## Overview

This project has been simplified to focus on these core features:
1. Load as a UEFI executable from a bootable device
2. Display a simple message on screen
3. Output logs to a serial port
4. Runs in QEMU as a USB storage device simulation

## Dependencies

You need the following packages installed:

```bash
sudo apt install gcc build-essential gnu-efi ovmf qemu-system-x86
```

## Building and Running

- `make all` - Build the bootloader and prepare EFI directories
- `make run` - Build and run in QEMU with USB device emulation
- `make clean` - Remove all build artifacts

## How It Works

The bootloader:
1. Initializes the UEFI environment
2. Prints welcome messages to the screen
3. Writes logs to the serial port (captured in `serial.log`)
4. Enters an infinite loop to prevent returning to UEFI firmware

## Creating a Bootable USB Drive

To create a physical bootable USB drive:

1. Format a USB drive as FAT32
2. Create the directory structure: `/EFI/BOOT/`
3. Copy `build/bootloader.efi` to `/EFI/BOOT/BOOTX64.EFI` on the USB drive
4. Boot your computer with the USB drive inserted
5. Enter BIOS/UEFI settings and select the USB drive as the boot device

## QEMU USB Boot Simulation

This project is configured to simulate booting from a USB drive in QEMU. The Makefile uses:
- USB storage device emulation
- OVMF firmware for UEFI support
- Serial output captured to serial.log

## Debugging

All output from the bootloader will be written to:
- The QEMU console window
- `serial.log` file

## Next Steps

This minimal bootloader could be extended to:
- Load a kernel from the bootable media
- Initialize hardware devices
- Set up memory management
- Transition to a full operating system

## License

This project is for educational purposes only.