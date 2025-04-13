/* bootloader/linker.ld */
OUTPUT_FORMAT("pei-x86-64")
SEARCH_DIR(/usr/lib)
SEARCH_DIR(/usr/lib/gnuefi)
ENTRY(efi_main)

SECTIONS
{
  .text : {
    *(.text)
    *(.text.*)
    *(.gnu.linkonce.t.*)
  }

  .data : {
    *(.rodata)
    *(.rodata.*)
    *(.data)
    *(.data.*)
    *(.gnu.linkonce.d.*)
  }

  .bss : {
    *(.bss)
    *(.bss.*)
    *(.gnu.linkonce.b.*)
  }
}