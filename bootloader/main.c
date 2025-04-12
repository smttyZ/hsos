// bootloader/main.c

#include <efi.h>
#include <efilib.h>

EFI_STATUS
efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {
    // Initialize the EFI Library
    InitializeLib(ImageHandle, SystemTable);

    // Print a message to the console
    Print(L"Hello, UEFI World!\n");

    while (1); // Infinite loop to keep the program running
    return EFI_SUCCESS;
}
