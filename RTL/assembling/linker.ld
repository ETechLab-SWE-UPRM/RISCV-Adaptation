/* linker.ld */
ENTRY(_start)

MEMORY
{
  ROM (rx) : ORIGIN = 0x00000000, LENGTH = 16384 /* 16KB ROM for instructions */
  RAM (rwx): ORIGIN = 0x10000000, LENGTH = 33440 /* 33KB RAM for data */
}

__stack_top = ORIGIN(RAM) + LENGTH(RAM);

SECTIONS
{
  /* all .text go into ROM starting at 0x0 */
  .text : {
    *(.init)
    *(.text)        /* every input section named .text */
  } > ROM

  /* all initialized data (.data) goes into RAM at 0x1000_0000 */
  .data : {
    __data_start = .;
    *(.data*)
    *(.rodata*)      /* read-only data */
    *(.sdata*)      /* small data */
    *(.srodata*)    /* small read-only data */
    __data_end = .;
  } > RAM

  /* uninitialized data (.bss) also lives in RAM, zero-filled */
  .bss  : {
    __bss_start = .;
    *(.bss)
    *(COMMON)
    __bss_end = .;
  } > RAM
}