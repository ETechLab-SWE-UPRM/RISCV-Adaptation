// Memory locations for MMIO
.set UART_BASE, 0x100082A0
.set UART_STATUS, 0x04
.set UART_RECEIVE, 0x08
.set UART_SEND, 0x0C

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

// load UART status, immediate value for different registers is need be
.macro load_UART_status rd
    lui \rd, %hi(UART_BASE)
    addi \rd, \rd, %lo(UART_BASE + UART_STATUS)
    lw \rd, 0(\rd)
.endm

.macro UART_READ rd
    lui \rd, %hi(UART_BASE)
    addi \rd, \rd, %lo(UART_BASE + UART_RECEIVE)
    lw \rd, 0(\rd)
.endm

.macro UART_WRITE rs1, rs2=t0
    lui \rs2, %hi(UART_BASE)
    addi \rs2, \rs2, %lo(UART_BASE + UART_SEND)
    sw \rs1, 0(\rs2)
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

.text
.globl main

main:
    load_UART_status t1
    bne t1, zero, start
    jal main

start: 
    UART_READ t1
    addi t1, t1, 1
    UART_WRITE t1
    jal main