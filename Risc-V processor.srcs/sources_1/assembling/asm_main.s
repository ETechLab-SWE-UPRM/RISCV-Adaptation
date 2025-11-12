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
.set data_addr, 0x10008370
.set weights_addr, 0x10008374
.set output_addr, 0x10008378

.data
    data: .zero 4096 #1024 spaces * 4 bytes
    weights: .word 1,1,1
    output: .zero 4088 #1022 spaces * 4 bytes

.section .text.main, "ax"
.globl main

main:
    la a0, data
    la a1, weights
    la a2, output
    li t0, 1024 #inputs length
    lui t1, %hi(data_addr)
    sw t0, %lo(data_addr)(t1)
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
    # when entering the loop, s1 = data[i + j], s2 = weights[j]
      # The idea is, since the fmadd is in the mem stage, forward the result and keep acumulating
      # on the same register (f2) until the end of the inner loop
    fmadd.s f2, f0, f1, f2 # sum += data[i + j] * weights[j]

    addi t2, t2, 1
    blt t2, a3, inner_loop

inner_loop_finished:
    # Store the result
    fsw f2, 0(a2)
    addi a2, a2, 4 # output address increment
    addi t1, t1, 1
    blt t1, a4, outer_loop

forever:
    jal forever
