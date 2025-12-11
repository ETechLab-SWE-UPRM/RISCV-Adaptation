.section .init, "ax"
.globl _start

_start:
    la sp, __stack_top
    jal main
1: jal 1b