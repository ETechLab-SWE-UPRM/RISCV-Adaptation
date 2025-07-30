# Macro definitions for RISC-V assembly mac and vector instructions
# opcode, funct3, funct7, registers 
.macro mac rd, rs1, rs2
    .insn r OP, 0x00, 0x01, \rd, \rs1, \rs2
.endm

.macro vmac rd, rs1, rs2
    .insn r 0x5B, 0x00, 0x01, \rd, \rs1, \rs2
.endm

.macro vadd rd, rs1, rs2
    .insn r 0x5B, 0x00, 0x00, \rd, \rs1, \rs2
.endm

# opcode, funct3, registers
# load a vector register from memory with continuous address
.macro vload rd, rs1, offset
    .insn i 0x0B, 0x02, \rd, \rs1, \offset
.endm

# load a single value from memory into a vector register
.macro vsload rd, rs1, offset
    .insn i 0x0B, 0x06, \rd, \rs1, \offset
.endm

# This is to add the same immediate value to the vector register
.macro vaddi rd, rs1, offset
    .insn i 0x0B, 0x00, \rd, \rs1, \offset 
.endm

.macro vslli rd, rs1, offset
    .insn i 0x0B, 0x01, \rd, \rs1, \offset
.endm

.macro vstore rs2, rs1, offset
    .insn i 0x2B, 0x02, \rs2, \rs1, \offset
.endm

# This is to add the continuation of the immediate value to the vector register
.macro vcaddi rd, rs1, offset
    .insn i 0x0B, 0x03, \rd, \rs1, \offset
.endm

# opcode, registers
.macro vauipc rd, offset
    .insn u 0x7B, \rd, \offset
.endm

.data 
    signal: .zero 4096 #1024 * 4
    kernel: .word 1,1,1 # {1,1,1}
    result: .zero 4088 #1022 * 4
    
.text
.globl main

main:
    # ---------- initialization (do not use this) ----------
    # -------- This is to add the 1d matrix to memory ----------
    vauipc s0, 0x10000
    vaddi s0, s0, 0
    vauipc s1, 0x10001
    vaddi s1, s1, -8
    vauipc s2, 0x10001
    vaddi s2, s2, -4

    vcaddi t0, t0, 1 # values for i and i+1
    vcaddi t3, t3, 0 # continous address for i+1
    li t0, 0 # i = 0
    li t2, 1024

init_loop:
    vslli t4, t3, 2         # t4 = i*4
    vadd t5, s0, t4        # t5 = &signal[i]
    vstore t0, t5, 0
    vaddi t3, t3, 2        # t3 = address[i,i+1]
    vaddi t0, t0, 2 # t0 = [i, i+1]
    addi t0, t0, 2  # increment by 2 for vector operations
    blt t0, t2, init_loop

convolution:
    li t0, 0 # i = 0
    vcaddi t0, zero, 0 # vt0 = [0,1]
    li t1, 1022
    li t2, 3

outer_loop:
    li t3, 0 # j = 0
    vaddi t3, zero, 0 # vt3 = j = 0
    vaddi s4, zero, 0 # vt4 = sum = 0

inner_loop:
    vadd t5, t0, t3 # vt5 = [i + j, i + j + 1]
    vslli t5, t5, 2 # vt5 = [(i + j) * 4, (i + j + 1) * 4]
    vadd t5, s0, t5 # vt5 = &signal[i + j]
    vload t6, t5, 0 # vt6 = signal[i + j]

    vslli t5, t3, 2 # vt5 = j * 4
    vadd t5, s1, t5 # vt5 = &kernel[j]
    vsload s3, t5, 0 # t7 = kernel[j]

    vaddi t3, t3, 1 # j++ for addressing kernel
    addi t3, t3, 1 # j++ for loop

    vmac s4, t6, s3 # s4 = s4 + signal[i + j] * kernel[j]

    blt t3, t2, inner_loop

outside_inner_loop:
    vslli t5, t0, 2 # t5 = i * 4
    vadd s5, s2, t5 # s4 = &result[i]
    vstore s4, s5, 0 # store the result

    vaddi t0, t0, 2 # i += 2
    addi t0, t0, 2 # increment by 2 for vector operations
    blt t0, t1, outer_loop

forever:
    jal forever