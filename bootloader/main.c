// bootloader/main.c
// Simplified UEFI bootloader that prints a message and writes to serial log

#include <efi.h>
#include <efilib.h>

// Using predefined GUID from efilib.h

// Function to write a string to the serial port
VOID 
WriteToSerial(EFI_SYSTEM_TABLE *SystemTable, CHAR16 *Message) {
    // Try to find any serial ports for output
    EFI_HANDLE *Handles = NULL;
    UINTN HandleCount = 0;
    EFI_SERIAL_IO_PROTOCOL *SerialIo;
    EFI_STATUS Status;
    
    // Get all handles that support the Serial I/O protocol
    Status = uefi_call_wrapper(SystemTable->BootServices->LocateHandleBuffer, 5,
                              ByProtocol, 
                              &gEfiSerialIoProtocolGuid,
                              NULL,
                              &HandleCount,
                              &Handles);
    
    if (!EFI_ERROR(Status) && HandleCount > 0) {
        // Use the first serial port for simplicity
        Status = uefi_call_wrapper(SystemTable->BootServices->HandleProtocol, 3,
                                  Handles[0],
                                  &gEfiSerialIoProtocolGuid,
                                  (VOID**)&SerialIo);
        
        if (!EFI_ERROR(Status)) {
            // Convert wide string to ASCII for the serial port
            CHAR8 AsciiMessage[256];
            UINTN i;
            for (i = 0; Message[i] != 0 && i < 255; i++) {
                AsciiMessage[i] = (CHAR8)Message[i];
            }
            AsciiMessage[i] = 0;
            
            // Write to the serial port
            UINTN Size = i;
            uefi_call_wrapper(SerialIo->Write, 3, SerialIo, &Size, AsciiMessage);
        }
        
        // Free the handle buffer
        uefi_call_wrapper(SystemTable->BootServices->FreePool, 1, Handles);
    }
}

// Entry point for the UEFI application
EFI_STATUS
EFIAPI
efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {
    // Initialize the EFI Library
    InitializeLib(ImageHandle, SystemTable);
    
    // Display message on screen
    Print(L"Hello from HSOS Bootloader!\n");
    Print(L"This is a simple UEFI application running from a bootable device\n");
    
    // Write message to serial port
    WriteToSerial(SystemTable, L"HSOS Bootloader started\r\n");
    WriteToSerial(SystemTable, L"Hello from HSOS Serial Output\r\n");
    
    // Let the user know we're done
    Print(L"\nBootloader execution complete. System halted.\n");
    WriteToSerial(SystemTable, L"Bootloader execution complete. System halted.\r\n");
    
    // Sleep a bit to ensure messages are sent
    for (UINTN i = 0; i < 10000000; i++) {
        asm volatile("nop");
    }
    
    // Infinite loop to keep the program running
    while (1);
    
    return EFI_SUCCESS;
}
