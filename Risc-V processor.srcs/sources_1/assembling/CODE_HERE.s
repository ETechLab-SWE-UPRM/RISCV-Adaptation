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

.macro vstore rs2, rs1, offset
    .insn i 0x2B, 0x02, \rs2, \rs1, \offset
.endm

.macro vaddi rd, rs1, offset
    .insn i 0x0B, 0x00, \rd, \rs1, \offset 
.endm

.macro vslli rd, rs1, offset
    .insn i 0x0B, 0x01, \rd, \rs1, \offset
.endm

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
    vauipc s1, 0x10001
    vaddi s1, s1, -4
    vauipc s2, 0x10001
    la s0, signal
    la s1, kernel
    la s2, result
    
forever:
    jal forever