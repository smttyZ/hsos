/* bootloader/linker.ld */
OUTPUT_FORMAT(pei-x86-64)
ENTRY(efi_main)

SECTIONS
{
  . = 0x100000; /* Load address for the bootloader */

  .text : {
    *(.text)
  }

  .data : {
    *(.data)
  }

  .bss : {
    *(.bss)
  }
}