// bootloader/main.c
// Basic UEFI bootloader

#include <efi.h>
#include <efilib.h>

// Entry point for the UEFI application
EFI_STATUS
EFIAPI
efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {
    // Initialize the EFI Library
    InitializeLib(ImageHandle, SystemTable);
    
    // Display message on screen
    Print(L"Hello from HSOS Bootloader!\n");
    Print(L"This is a simple UEFI application\n");
    
    // Sleep a bit
    for (UINTN i = 0; i < 10000000; i++) {
        asm volatile("nop");
    }
    
    return EFI_SUCCESS;
}
