# RISC-V Pipelined Processor with MAC Instruction and ELF Integration

## Overview

This project implements a 5-stage pipelined RISC-V processor with support for a custom **MAC (Multiply-Accumulate)** instruction accelerated via a dedicated DSP block, and **Vector Computations** including their own custom opcodes and instructions.  The processor supports most RV32I instructions (with some RV32IF instructions) and accepts programs compiled into **ELF binaries**, allowing for a seamless software-hardware workflow.

Designed for FPGA implementation (e.g., Artix7), the processor uses separate BRAMs for instruction and data memory, both pre-loadable from ELF-generated coe files.

## Description

The architecture works at 50MHz, which is also the clock being used for testing (The FPGA used is the Basys3). It has a UART system with two FIFOs of 4 bytes, at a baud rate of 115200. It also has a timer register which can be used to measure clock cycles, and exposed registers to store the size of the convolution arrays before executing the algorithm. The way to access this communication and all other registers is via memory mapping.

## Features

- **Integer Convolutions**:
  - Vector Registers of size 2 are used for faster integer computations.
  - Custom instructions were created for this implementation, and the algorithm can be found in the `vector_conv.s` file in the `RTL/assembling` folder.
- **Floating Point Convolutions**:
  - Since Floating Point computations are heavy, these were separated into the EX stage and the MEM stage. The multiplication is done in the EX, while the addition is done in the MEM stage.
  - The algorithm used for this implementation are found in the `convolution.s` file in the `RTL/assembling` folder.
- **General Purpose CPU**
  - The CPU can be used with a general purpose for base RV32I. In floating point, you can only do **FLW, FSW, FEQ.s or FMADD.s** 
  - All the registers handle their own data separately, unless using the specific instructions to do so, like `fcvt.s` or `vmove` (vector to integer register)