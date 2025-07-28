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
.macro vload rd, rs1, offset
    .insn i, 0x0B, 0x02, \rd, \rs1, \offset
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

# main:
#     la t1, signal        # base address of signal[]
#     la s1, kernel
#     la s2, result

#     li   t0, 0             # i = 0
#     li   t2, 1
#     li   t6, 1024
# init_loop:
#     add  t3, t0, t2        # t3 = i+1
#     slli t4, t0, 2         # t4 = i*4
#     add  t5, t1, t4        # t5 = &signal[i]
#     sw   t3, 0(t5)
#     addi t0, t0, 1
#     blt  t0, t6, init_loop

#    # ---------- Convolution (start here) ----------
# convolution:
#     li t0, 0 # i = 0 
#     li s7, 3
#     li s9, 1022
    
# outer_loop:
#     li t4, 0 # sum = 0
#     li t5, 0 # j = 0


main:
    # ---------- initialization (do not use this) ----------
    # -------- This is to add the 1d matrix to memory ----------
    vauipc s0, 0x10000
    vaddi s0, s0, 0
    vauipc s1, 0x10001
    vaddi s1, s1, -8
    vauipc s2, 0x10001
    vaddi s2, s2, -4
    
    vcaddi t0, t0, -2 # continous address for i and i+1
    li t0, 0 # i = 0
    li t2, 1024

init_loop:
    vaddi t3, t0, 2        # t3 = i+1
    vaddi t0, t0, 2
    vslli t4, t0, 2         # t4 = i*4
    vadd t5, s0, t4        # t5 = &signal[i]
    vstore t3, t5, 0
    addi t0, t0, 2  # increment by 2 for vector operations
    blt t0, t2, init_loop

forever:
    jal forever