.section .init, "ax"
.globl _start

_start:
    la sp, __stack_top
    call main
1: jal 1b
