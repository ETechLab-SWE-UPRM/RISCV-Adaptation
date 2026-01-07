# RISC-V Pipelined Processor with MAC Instruction and ELF Integration

## Overview

This project implements a 5-stage pipelined RISC-V processor with support for a custom **MAC (Multiply-Accumulate)** instruction accelerated via a dedicated DSP block, and **Vector Computations** including their own custom opcodes and instructions.  The processor supports most RV32I instructions (with some RV32IF instructions) and accepts programs compiled into **ELF binaries**, allowing for a seamless software-hardware workflow.

Designed for FPGA implementation (e.g., Artix7), the processor uses separate BRAMs for instruction and data memory, both pre-loadable from ELF-generated coe files.

## Description

The architecture works at 100MHz, which is the default clock of the FPGA being used for testing (Basys3). It has a UART system with two FIFOs of 4 bytes, at a baud rate of 115200. This is the only way of communication with it via memory mapping.

## Features

- **Integer Convolutions**:
  - Vector Registers of size 2 are used for faster integer computations.
  - Custom instructions were created for this implementation, found in the `vector_conv.s` file in the `Risc-V processor.srcs/sources_1/assembling` folder.
- **Floating Point Convolutions**:
  - Since Floating Point computations are heavy, these were separated into the EX stage and the MEM stage. The multiplication is done in the EX, while the addition is done in the MEM stage.
  - The specific instructions used for this implementation are found in the `convolution.s` file in the `Risc-V processor.srcs/sources_1/assembling` folder.
- **General Purpose CPU**
  - The CPU can be used with a general purpose, considering that the instructions stay as integer instructions. In floating point, you can only do **FLW, FSW, or FMADD.s** 
  - All the instructions work on separate registers, unless using the specific instructions to do so, like `fcvt.s` or `vmove` (vector to integer register)