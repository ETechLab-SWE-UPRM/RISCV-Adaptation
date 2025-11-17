.section .init, "ax"
.globl _start

_start:
    la sp, __stack_top
    jal main
1: jal 1b

.macro mac rd, rs1, rs2
    .insn r OP, 0x00, 0x01, \rd, \rs1, \rs2
.endm

.macro fmac rd, rs1, rs2, rs3
    .insn r OP_FP, 0x00, \rd, \rs1, \rs2, \rs3
.endm

#addresses where the lengths are stored
.set uart_status, 0x100082A4
.set uart_receive, 0x100082A8
.set uart_send, 0x100082AC
.set data_addr, 0x100082B0
.set weights_addr, 0x100082B4
.set output_addr, 0x100082B8

.data
    data: .zero 4096 #1024 spaces * 4 bytes
    weights: .float 1.0,1.0,1.0
    output: .zero 4088 #1022 spaces * 4 bytes

.section .text.main, "ax"
.globl main

main:
    # The mac operations expect the addresses to be in these registers:
    # a0 -> data address
    # a1 -> weights address
    # a2 -> output address
    la a0, data
    la a1, weights
    la a2, output
    li t0, 1024 #inputs length
    lui t1, %hi(data_addr)
    sw t0, %lo(data_addr)(t1)
    lui s1, %hi(uart_send)
    li t1, 0 # i = 0
    li t2, 1

init_loop:
    addi t3, t1, 1  #i + 1
    slli t4, t1, 2  # (i + 1) * 4
    add t5, a0, t4  # &data[i + 1]
    fcvt.s.w f0, t3   # convert to float
    fsw f0, 0(t5)    # data[i] = i + 1
    addi t1, t1, 1
    blt t1, t0, init_loop

convolution1D:
    li t1, 0 # i = 0
    li a3, 3 # weights length
    lui t2, %hi(weights_addr)
    sw a3, %lo(weights_addr)(t2)
    li a4, 1022 # outputs length
    lui t2, %hi(output_addr)
    sw a4, %lo(output_addr)(t2)

    flw f0, 0(a0) # preload first data
    flw f1, 0(a1) # preload first weight

outer_loop:
    li t2, 0 # j = 0
    fmv.w.x f2, x0 # sum = 0 

inner_loop:
    # f2 used as accumulator, dual issue will use the registers specified on the instruction
    # any register can be changed in this instruction if you wish so.
    fmadd.s f2, f0, f1, f2 # sum += data[i + j] * weights[j]

    addi t2, t2, 1
    blt t2, a3, inner_loop

inner_loop_finished:
    # Store the result
    fsw f2, 0(a2)
    fsw f2, %lo(uart_send)(s1) # send output to uart
    addi a2, a2, 4 # output address increment
    addi t1, t1, 1
    blt t1, a4, outer_loop

forever:
    jal forever
