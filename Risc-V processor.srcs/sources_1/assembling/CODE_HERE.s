.macro mac rd, rs1, rs2
    .insn r OP, 0x00, 0x01, \rd, \rs1, \rs2
.endm

.macro vmac rd, rs1, rs2
    .insn r 0x4c, 0x00, 0x7f, \rd, \rs1, \rs2
.endm

.macro vadd rd, rs1, rs2
    .insn r 0x4c, 0x00, 0x7f, \rd, \rs1, \rs2
.endm

.macro lv rd, rs1, offset
    .insn i , 0x7c, 0x02, 0x7f, \rd, \rs1, \offset
.endm

.macro sv rs1, rs2, offset
    .insn s 0x5c, 0x02, 0x7f, \rs1, \rs2, \offset
.endm

.data 
    signal: .zero 4096 #1024 * 4
    kernel: .word 1,1,1 # {1,1,1}
    result: .zero 4088 #1022 * 4
    
.text
.globl main

main:
    # ---------- initialization (do not use this) ----------
    # ---------- This is to add the 1d matrix to memory ----------
    la   t1, signal        # base address of signal[]
    la   s1, kernel
    la   s2, result      
    li   t2, 1
    li   t6, 1024
    li   t0, 0             # i = 0
init_loop:
    add  t3, t0, t2        # t3 = i+1
    slli t4, t0, 2         # t4 = i*4
    add  t5, t1, t4        # t5 = &signal[i]
    sw   t3, 0(t5)
    addi t0, t0, 1
    blt  t0, t6, init_loop

   # ---------- Convolution (start here) ----------
convolution:
    li t0, 0 # i = 0 
    li s7, 3
    li s9, 1022
    
outer_loop:
    li t5, 0 # j = 0
    li t4, 0 # sum = 0

# Everything up there works, so dont change it.

inner_loop:
    # loading signal[i + j]
    add s6, t0, t5 # s6 = i + j
    slli s6, s6, 2 # word_offset * 4
    add s6, t1, s6 # s6 = &signal[i+j]
    lw s3, 0(s6) # s3 = signal[i+j]

    # loading kernel [j]
    slli s4, t5, 2 # s4 = j * 4
    add s4, s1, s4 # &kernel[j]
    lw s5, 0(s4) # s5 = kernel[j]
    
    # MAC
    mac t4, s5, s3

    addi t5, t5, 1
    blt t5, s7, inner_loop 

outside_inner_loop:

    slli s6, t0, 2 # word_offset * 4
    add s6, s2, s6 # &result[i]
    sw t4, 0(s6) # result[i] = sum

    addi t0, t0, 1
    blt t0, s9, outer_loop
    
forever:
    jal forever