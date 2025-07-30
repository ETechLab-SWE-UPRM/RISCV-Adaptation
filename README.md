# RISC-V Pipelined Processor with MAC Instruction and ELF Integration

## Overview

This project implements a 5-stage pipelined RISC-V processor with support for a custom **MAC (Multiply-Accumulate)** instruction accelerated via a dedicated DSP block, and **Vector Computations** including their own custom opcodes and instructions.  The processor supports most RV32I instructions and accepts programs compiled into **ELF binaries**, allowing for a seamless software-hardware workflow.

Designed for FPGA implementation (e.g., Basys3), the processor uses separate BRAMs for instruction and data memory, both pre-loadable from ELF-generated coe files.

## Features

- **5-Stage Pipeline**: IF, ID, EX, MEM, WB
- **Custom MAC Instruction**:  
  - Syntax: `mac rd, rs1, rs2`  
  - Semantics: `rd = rd + (rs1 * rs2)`
  - Implemented using a DSP block for fast multiply-accumulate
  - Generates the amount of DSP's necessary for vector MACs depending on the size of the vectors 
- **Extended Register File**:
  - Supports simultaneous `rs1`, `rs2`, and `rd` reads (for MAC) with forwarding and hazard detection for scalar values and vector values
- **Dual BRAM Architecture**:
  - One BRAM each for instructions and data
  - Data Memory is a true Dual Port RAM in to access memory in pairs for vector computations
  - Generates the necessary data memory IP's depending on the size of the vector registers
- **ELF Binary Integration**:
  - Use `riscv64-unknown-elf-gcc` to compile code into ELF binary
  - Convert ELF to `.coe` files for faster workflow and simulation
- **Vector Registers and ALU**
  - Paraller computation for each lane of the vector  
- **Custom Vector Instructions**
  - vadd, vaddi, vslli, vmac, vauipc
    - same as its scalar counterparts, done in parallel
  - vload, vstore
    - Loads the values from the address to address + [vector length - 1], and stores the vector to the address up to  address + [vector length - 1]
  - vsload
    - loads a single value from memory to the entire vector register