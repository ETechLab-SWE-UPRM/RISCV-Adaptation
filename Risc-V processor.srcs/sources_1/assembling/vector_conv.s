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

# to move data from a integer register to a vector register
.macro vmove rd, rs1
    .insn r 0x5B, 0x04, 0x01, \rd, \rs1, x0
.endm

# opcode, registers
.macro vauipc rd, offset
    .insn u 0x7B, \rd, \offset
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

    
.text
.globl vector_convolution_main
.type vector_convolution_main, @function

# Risc-V ABI:
# int vector_convolution(int *data, int *weights, int *output,
#                  int data_length, int weights_length, int output_length);
#
# RISC-V (RV32) ABI:
#   a0 = data
#   a1 = weights
#   a2 = output
#   a3 = data_length
#   a4 = weights_length
#   a5 = output_length

vector_convolution_main:
    # ---------- initialization (do not use this) ----------
    # -------- This is to add the 1d matrix to memory ----------
    # vauipc s0, 0x10000
    # vaddi s0, s0, 0
    # vauipc s1, 0x10001
    # vaddi s1, s1, -8
    # vauipc s2, 0x10001
    # vaddi s2, s2, -4

    vmove s0, a0 # s0 = signal base address
    vmove s1, a1 # s1 = kernel base address
    vmove s2, a2 # s2 = result base address

    vcaddi t0, t0, 1 # values for i and i+1
    vcaddi t3, t3, 0 # continous address for i+1
    li t0, 0 # i = 0
    mv t2, a3

    li t0, 0 # i = 0
    vcaddi t0, zero, 0 # vt0 = [0,1]
    mv t1, a5 # t1 = output lenght
    mv t2, a4 # t2 = kernel length

outer_loop_vector:
    li t3, 0 # j = 0
    vaddi t3, zero, 0 # vt3 = j = 0
    vaddi s4, zero, 0 # vt4 = sum = 0

inner_loop_vector:
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

    blt t3, t2, inner_loop_vector

outside_inner_loop:
    vslli t5, t0, 2 # t5 = i * 4
    vadd s5, s2, t5 # s4 = &result[i]
    vstore s4, s5, 0 # store the result

    vaddi t0, t0, 2 # i += 2
    addi t0, t0, 2 # increment by 2 for vector operations
    blt t0, t1, outer_loop_vector

    li a0, 0
    ret