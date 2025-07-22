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
    .insn i, 0x7B, 0x02, \rd, \rs1, \offset
.endm

.macro vstore rs1, rs2, offset
    .insn i 0x2B, 0x02, \rs1, \rs2, \offset
.endm

.macro vaddi rd, rs1, offset
    .insn i 0x0B, 0x00, \rd, \rs1, \offset 
.endm

.macro vslli rd, rs1, offset
    .insn i 0x0B, 0x01, \rd, \rs1, \offset
.endm

.data 
    signal: .zero 4096 #1024 * 4
    kernel: .word 1,1,1 # {1,1,1}
    result: .zero 4088 #1022 * 4
    
.text
.globl main

main:
    vaddi t0, zero, 10
    vaddi t1, zero, 2
    vslli t2, t1, 2
    vstore t0, t2, 0
    sw t0, 0(t2)    
forever:
    jal forever