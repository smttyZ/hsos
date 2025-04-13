# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands
- `make all` - Build bootloader and create disk image
- `make run` - Build and run OS in QEMU emulator 
- `make clean` - Remove build artifacts

## Code Style Guidelines
- Use C99 standard for all C code
- Indentation: 4 spaces (no tabs)
- Follow GNU-EFI conventions for bootloader code
- Variable naming: lowercase_with_underscores
- Functions: descriptive names with EFI prefixes when appropriate
- Error handling: Use EFI_STATUS return values consistently

## Architecture
- x86_64 UEFI bootloader written in C
- Modular design with separate bootloader and kernel
- Debug output directed to debug.log file
- Built using GNU-EFI libraries

## Development Notes
- This is a custom operating system (HSOS) with UEFI support
- Primary test environment is QEMU with OVMF firmware
- Disk image format is FAT32 with standard EFI boot structure