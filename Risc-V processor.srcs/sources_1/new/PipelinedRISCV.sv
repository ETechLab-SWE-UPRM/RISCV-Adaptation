`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CAWT
// Engineer: Fernando L. Pizarro Diaz
// 
// Create Date: 05/27/2025 10:22:03 AM
// Design Name: Piper
// Module Name: RISCV_PIPELINED
// Project Name: RISC-V Wearable
// Target Devices: Artix-7
// Tool Versions: SystemVerilog 2012
// Description: A pipelined RISC-V processor implementation, with support for all integer instructions (excluding environment call instructions), 
// and support for custom vector and floating point MAC computations (FMADD).
// Contains usual components such as instruction (ROM) and data memory (RAM), 3 distinct ALU components, and several DSPs for faster computations.
// For integer MAC operations, the destination register serves as the 3rd input and the accumulator to the scalar MAC DSP.
// MAC is its own instruction to substitute the mul -> add instruction when calculating convolutions. Uses the same opcode as MUL.
// UART communication is implemented through memory-mapped I/O.
//
// 
// Dependencies: 
//           - riscv-gnu-toolchain for compilation and assembly of data: https://github.com/riscv-collab/riscv-gnu-toolchain
//           - WSL (if using Windows) for running the toolchain: https://learn.microsoft.com/en-us/windows/wsl/install
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

package fp_fma_pkg;
    typedef enum logic [1:0] { 
        FM_NONE,
        FMADD,
        FNMADD
    } fp_fma_t;
endpackage

package fp_alu_pkg;
    typedef enum logic [3:0] {
        FADD,
        FSUB,
        FMUL,
        FEQ,
        FLT,
        FLE,
        FMVWX,
        FCVTSW,
        FMEM, // Load or store 
        FNONE
    } fp_alu_op_t;

    typedef enum logic [2:0] {
        RNE,
        RTZ,
        RDN,
        RUP,
        RMM,
        DYN
    } rm_t;
endpackage

module RISCV_PIPELINED (
    input logic clk,
    input logic reset, 
    input logic rx, 
    output logic tx,
    output logic [6:0] seg, 
    output logic [3:0] an,
    output logic led
);
    import fp_fma_pkg::*;
    import fp_alu_pkg::*;

    // Keep this number even, because data memory is organized in pairs of words
    localparam vector_length = 2;

    // Memory Mapping
    localparam data_base = 32'h1000_0000;
    localparam data_word_space = 8360 * 4; // 33,440 bytes, change this if data size changes
    localparam uart_status = data_base + data_word_space + 4; // Max + 1 in memory
    localparam uart_receive = uart_status + 4;
    localparam uart_send = uart_receive + 4;
    localparam data_length_addr = uart_send + 4;
    localparam weights_length_addr = data_length_addr + 4;
    localparam output_length_addr = weights_length_addr + 4;

    // UART Parameters
    localparam data_bits = 8;
    localparam stop_tick = 16; // Stop bit / Oversampling ticks
    localparam fifo_exp = 2; // 2^2 = 4 entries in the FIFO's
    localparam baud_rate = 115200;
    localparam br_limit = 54; // 100 MHz / (115200 * 16)
    localparam br_bits = 6; // ceil(log2(br_limit))

    logic [data_bits-1:0] uart_write_data;
    logic [data_bits-1:0] uart_read_data;
    logic uart_rx_full, uart_rx_empty;

    localparam fp_adder_delay = 2; 
    localparam fp_multiplier_delay = 1;

    // IF/ID pipeline registers
    logic [31:0] instruction_if_id;
    logic [31:0] pc_if_id;
    logic [1:0] fp_op;
    logic [31:0] data_read1, data_read2;
    logic [31:0] data_read3;
    logic [31:0] fp_data_read1, fp_data_read2, fp_data_read3, fp_data_read4;
    logic [31:0] vector_data_read1 [0:vector_length-1];
    logic [31:0] vector_data_read2 [0:vector_length-1];
    logic [31:0] vector_data_read3 [0:vector_length-1];
    logic [31:0] conv_data_read, conv_weights_read;
    logic fp_instruction,fp_alu_src, fp_reg_write, fp_load, fp_store;
    fp_fma_t fmat_type;
    logic vec_op, vec_reg_write, continous_addr, single_load, branch, beq, bne, blt, bge, mem_read, memtoreg, mem_write, alu_src, reg_write, jal, jalr, auipc, lui;
    logic [1:0] alu_op;
    logic [31:0] big_immediate;
    
    // Flush signal 
    logic ex_taken;
    
    // Hazard detection unit to handle stalls
    logic stall, pc_write, if_id_write;
    logic fp_stall, fp_pc_write, fp_if_id_write;
    logic mac_stall;
    
    // ID/EX pipeline registers
    logic [31:0] pc_id_ex, instruction_id_ex;
    logic vec_op_id_ex, vec_reg_write_id_ex;
    logic fp_instruction_id_ex, fp_reg_write_id_ex;
    logic id_ex_continous_addr;
    logic id_ex_single_load;
    logic id_ex_branch, id_ex_beq, id_ex_bne, id_ex_blt, id_ex_bge, id_ex_mem_read, id_ex_memtoreg, id_ex_mem_write, id_ex_auipc, id_ex_alu_src, id_ex_reg_write, id_ex_jal, id_ex_jalr;
    logic id_ex_lui;
    logic id_ex_fp_alu_src,id_ex_fp_load, id_ex_fp_store;
    fp_fma_t id_ex_fmat_type;
    logic conv_write_enable;
    logic [31:0] conv_addr_read_id_ex, weights_addr_read_id_ex;
    logic [1:0] id_ex_fp_op;
    logic [1:0] id_ex_alu_op;
    logic [31:0] data_read1_id_ex, data_read2_id_ex, data_read3_id_ex;
    logic [31:0] fp_data_read1_id_ex, fp_data_read2_id_ex, fp_data_read3_id_ex, fp_data_read4_id_ex;
    logic [31:0] vector_data_read1_id_ex [0:vector_length-1];
    logic [31:0] vector_data_read2_id_ex [0:vector_length-1];
    logic [31:0] vector_data_read3_id_ex [0:vector_length-1];
    logic [31:0] big_immediate_id_ex;
    logic [4:0] reg_dest_id_ex, reg1_id_ex, reg2_id_ex, reg3_id_ex;
    logic [2:0] funct3_id_ex;
    logic [6:0] funct7_id_ex;
    logic id_ex_flush; 

    // FP ALU and MAC signals
    fp_alu_op_t fp_alu_op;
    rm_t rm;
    logic fp_alu_result_valid;
    logic fp_mac_result_valid;

    assign id_ex_flush = ex_taken || stall || fp_stall;
    
    logic [31:0] ex_next_pc;

    // EX/MEM pipeline registers
    logic ex_mem_vec_op, ex_mem_vec_reg_write;
    logic ex_mem_fp_instruction, ex_mem_fp_reg_write;
    logic ex_mem_single_load;
    logic ex_mem_memread, ex_mem_memwrite, ex_mem_memtoreg, ex_mem_regwrite, ex_mem_jal, ex_mem_jalr;
    fp_fma_t ex_mem_fmat_type;
    logic [31:0] ex_mem_conv_addr, ex_mem_weights_addr;
    logic [31:0] ex_mem_fp_mac_1, ex_mem_fp_mac_2, ex_mem_mac_result;
    logic [31:0] ex_mem_alu_result [0:vector_length-1], ex_mem_data_read2;
    logic [31:0] vec_ex_mem_data_read2 [0:vector_length-1];
    logic [4:0] ex_mem_rs1, ex_mem_rs2, ex_mem_reg_dest;
    logic [2:0] ex_mem_funct3;
    logic [31:0] ex_mem_link_address_reg;
    logic [31:0] ex_mem_data_counter, ex_mem_weights_counter;
    logic [4:0] fp_mac_result_reg_dest;
    logic [31:0] memory_data_read [0:vector_length-1];

    // Convolution registers for memory mapping
    logic [31:0] conv_data_length, conv_weights_length, conv_output_length;

    // Duplicate the 5-bit RD bus with max 16-sink clusters
    (* DONT_TOUCH = "true" *) wire [4:0] ex_mem_rd_dup = ex_mem_reg_dest;

    // Do the same for the write-enable bit if it has high fan-out
    (* DONT_TOUCH = "true" *) wire       ex_mem_regwrite_dup = ex_mem_regwrite;
    
    // MEM/WB pipeline registers
    logic mem_wb_memtoreg, mem_wb_regwrite, mem_wb_jal, mem_wb_jalr, mem_wb_vec_op, mem_wb_vec_reg_write;
    logic mem_wb_fp_instruction, mem_wb_fp_reg_write;
    logic [31:0] mem_wb_alu_result [0:vector_length-1], mem_wb_memory_data_read [0:vector_length-1], mem_wb_link_address;
    logic [4:0] mem_wb_rs1, mem_wb_rs2, mem_wb_reg_dest;
    logic [31:0] mem_wb_write_data [0:vector_length-1];
    logic [31:0] mem_wb_conv_addr, mem_wb_weights_addr;

    // -- INSTRUCTION FETCH STAGE --
    logic [31:0] pc ;
    logic [31:0] next_pc;
    logic [31:0] instruction;

    always_comb begin
        if(ex_taken) begin
            next_pc = ex_next_pc;
        end else begin
            next_pc = pc + 32'h4; 
        end
    end
        
    ProgramCounter pc_i (
        .clk(clk),
        .reset(reset),
        .pc_write(pc_write && fp_pc_write),
        .next_pc(next_pc), 
        .pc(pc)
    );

    InstructionMemory im (
        .clk(clk),
        .stall(stall || fp_stall || mac_stall),
        .instruction_address(pc), 
        .instruction(instruction)
    );

    logic [31:0] fetch_pc;

    // This is simply to fix the missalignment of the PC with its corresponding instruction
    always_ff @(posedge clk) begin
        if (reset) begin
            fetch_pc <= 32'b0;
        end else if (pc_write) begin
            fetch_pc <= pc;
        end else begin
            fetch_pc <= fetch_pc;
        end
    end

    // ------INSTRUCTION FETCH / INSTRUCTION DECODE------

    IF_ID_reg if_id_reg (
        .clk(clk), 
        .reset(reset), 
        .flush(ex_taken), 
        .if_id_write(if_id_write && fp_if_id_write),
        .pc(fetch_pc), 
        .instruction(instruction), 
        .pc_if_id(pc_if_id), 
        .instruction_if_id(instruction_if_id) 
    );

    // ------DECODE STAGE------
    logic [4:0] reg1, reg2, reg3;
    logic [4:0] reg_dest;
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    // Extracting the fields for readable signals
    assign opcode = instruction_if_id[6:0]; 
    assign reg1 = instruction_if_id[19:15]; 
    assign reg2 = instruction_if_id[24:20]; 
    assign reg3 = instruction_if_id[31:27];
    assign reg_dest = instruction_if_id[11:7]; 
    assign funct3 = instruction_if_id[14:12]; 
    assign funct7 = instruction_if_id[31:25]; 
    
    Registers regs (
        .clk(clk),
        .reset(reset),
        .fp_mac(fmat_type),
        .read_reg1(reg1),
        .read_reg2(reg2),
        .read_reg3(reg_dest),
        .write_reg(mem_wb_reg_dest), 
        .write_data(mem_wb_write_data[0]),
        .conv_write_enable(mem_wb_fmat_type == FMADD),
        .conv_data_write(mem_wb_conv_addr),
        .conv_weights_write(mem_wb_weights_addr),
        .reg_write_enable(mem_wb_regwrite),
        .read_data1(data_read1),
        .read_data2(data_read2),
        .read_data3(data_read3),
        .conv_data_read(conv_data_read),
        .conv_weights_read(conv_weights_read)
    );

    vector_registers #(
        .vec_length(vector_length)
    ) v_regs (
        .clk(clk),
        .reset(reset),
        .read_reg1(reg1),
        .read_reg2(reg2),
        .read_reg3(reg_dest),
        .write_reg(mem_wb_reg_dest), 
        .write_data(mem_wb_write_data),
        .reg_write_enable(mem_wb_vec_reg_write),
        .read_data1(vector_data_read1),
        .read_data2(vector_data_read2),
        .read_data3(vector_data_read3)
    );

    Floating_Point_registers fp_regs (
        .clk(clk),
        .reset(reset),
        .read_reg1(reg1),
        .read_reg2(reg2),
        .read_reg3(reg3),
        .read_regdest(reg_dest),
        .conv_write_reg_rs1(mem_wb_rs1),
        .conv_write_reg_rs2(mem_wb_rs2),
        .write_reg(mem_wb_reg_dest), 
        .write_data(mem_wb_write_data[0]),
        .reg_write_enable(mem_wb_fp_reg_write),
        .conv_write_enable(mem_wb_fmat_type == FMADD),
        .conv_data_write(memory_data_read),
        .fp_mac_finished(ex_mem_mac_result_valid),
        .fp_mac_reg_dest(fp_mac_result_reg_dest),
        .fp_mac_data(ex_mem_mac_result),

        .read_data1(fp_data_read1),
        .read_data2(fp_data_read2),
        .read_data3(fp_data_read3),
        .read_data4(fp_data_read4)
    );

    Immediate_generator imm_gen (
        .instruction(instruction_if_id), 
        .immediate(big_immediate) 
    );
    
    Control control_unit (
        .opcode(opcode),
        .funct3(funct3),

        .vec_op(vec_op),
        .vec_reg_write(vec_reg_write),
        .continous_addr(continous_addr),
        .single_load(single_load),
        .branch(branch),
        .beq(beq),
        .bne(bne),
        .blt(blt),
        .bge(bge),
        .mem_read(mem_read),
        .memtoreg(memtoreg),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .jal(jal),
        .jalr(jalr),
        .auipc(auipc),
        .lui(lui)
    );

    fp_control fp_control_u (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),

        .fp_instruction(fp_instruction),
        .fp_op(fp_op),
        .fp_alu_src(fp_alu_src),
        .fp_reg_write(fp_reg_write),
        .fp_load(fp_load),
        .fp_store(fp_store),
        .fmat_type(fmat_type)
    );

    Hazard_Detection hazard_detection_unit (
        .clk(clk),
        .reset(reset),
        .if_id_vec_op(vec_op),
        .id_ex_vec_op(vec_op_id_ex),
        .if_id_rs1(reg1), 
        .if_id_rs2(reg2), 
        .reg_dest_id_ex(reg_dest_id_ex),
        .id_ex_mem_read(id_ex_mem_read),

        .stall(stall), 
        .pc_write(pc_write), 
        .if_id_write(if_id_write)
    );

    fp_hazard_detection #(
        .fp_adder_delay(fp_adder_delay),
        .fp_multiplier_delay(fp_multiplier_delay)
    ) fp_hd_u (
        .clk(clk),
        .reset(reset),
        .fp_mac_result_valid(fp_mac_result_valid),
        .if_id_rs1(reg1),
        .if_id_rs2(reg2),
        .if_id_rs3(reg3),
        .id_ex_rs2(reg2_id_ex),
        .reg_dest_id_ex(reg_dest_id_ex),
        .fp_mac_reg_dest(fp_mac_result_reg_dest),
        .fp_mac_finished(ex_mem_mac_result_valid),
        .id_ex_mem_read(id_ex_fp_load),
        .id_ex_mem_write(id_ex_fp_store),
        .fp_adder_result_valid(fp_alu_result_valid),

        .mac_stall(mac_stall),
        .stall(fp_stall),
        .pc_write(fp_pc_write),
        .if_id_write(fp_if_id_write)
    );

    // ------INSTRUCTION DECODE / EXECUTE STAGE------    

    ID_EX_reg #(
        .vec_length(vector_length)
    ) id_ex_reg (
        .clk(clk), 
        .reset(reset), 
        .flush(id_ex_flush),
        .stall(mac_stall),
        .vec_op(vec_op),
        .fp_instruction(fp_instruction),
        .fp_reg_write(fp_reg_write),
        .vec_reg_write(vec_reg_write),
        .continous_addr(continous_addr),
        .single_load(single_load),
        .branch(branch), 
        .beq(beq),
        .bne(bne),
        .blt(blt),
        .bge(bge),
        .mem_read(mem_read), 
        .memtoreg(memtoreg), 
        .mem_write(mem_write), 
        .alu_src(alu_src), 
        .reg_write(reg_write), 
        .jal(jal), 
        .jalr(jalr), 
        .auipc(auipc),
        .lui(lui),
        .fp_alu_src(fp_alu_src),
        .fp_load(fp_load),
        .fp_store(fp_store),
        .fmat_type(fmat_type),
        .conv_data_read(conv_data_read),
        .weights_data_read(conv_weights_read),
        .alu_op(alu_op), 
        .fp_op(fp_op),
        .pc_if_id(pc_if_id), 
        .instruction_if_id(instruction_if_id), 
        .big_immediate(big_immediate), 
        .reg1(reg1),
        .reg2(reg2),
        .reg3(reg3),
        .reg_dest(reg_dest), 
        .funct3(funct3), 
        .funct7(funct7),
        .scalar_data_read1(data_read1),
        .scalar_data_read2(data_read2),
        .scalar_data_read3(data_read3),
        .fp_data_read1(fp_data_read1),
        .fp_data_read2(fp_data_read2),
        .fp_data_read3(fp_data_read3),
        .fp_data_read4(fp_data_read4),
        .vector_data_read1(vector_data_read1),
        .vector_data_read2(vector_data_read2),
        .vector_data_read3(vector_data_read3),

        .pc_id_ex(pc_id_ex),
        .instruction_id_ex(instruction_id_ex),
        .vec_op_id_ex(vec_op_id_ex),
        .fp_instruction_id_ex(fp_instruction_id_ex),
        .fp_reg_write_id_ex(fp_reg_write_id_ex),
        .vec_reg_write_id_ex(vec_reg_write_id_ex),
        .id_ex_continous_addr(id_ex_continous_addr),
        .id_ex_single_load(id_ex_single_load),
        .id_ex_branch(id_ex_branch),
        .id_ex_beq(id_ex_beq),
        .id_ex_bne(id_ex_bne),
        .id_ex_blt(id_ex_blt),
        .id_ex_bge(id_ex_bge),
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_memtoreg(id_ex_memtoreg),
        .id_ex_mem_write(id_ex_mem_write),
        .id_ex_auipc(id_ex_auipc),
        .id_ex_lui(id_ex_lui),
        .id_ex_fp_alu_src(id_ex_fp_alu_src),
        .id_ex_fp_load(id_ex_fp_load),
        .id_ex_fp_store(id_ex_fp_store),
        .id_ex_fmat_type(id_ex_fmat_type),
        .conv_data_read_id_ex(conv_addr_read_id_ex),
        .weights_data_read_id_ex(weights_addr_read_id_ex),
        .id_ex_alu_src(id_ex_alu_src),
        .id_ex_reg_write(id_ex_reg_write),
        .id_ex_jal(id_ex_jal),
        .id_ex_jalr(id_ex_jalr),
        .id_ex_alu_op(id_ex_alu_op),
        .id_ex_fp_op(id_ex_fp_op),
        .scalar_data_read1_id_ex(data_read1_id_ex),
        .scalar_data_read2_id_ex(data_read2_id_ex),
        .scalar_data_read3_id_ex(data_read3_id_ex),
        .fp_data_read1_id_ex(fp_data_read1_id_ex),
        .fp_data_read2_id_ex(fp_data_read2_id_ex),
        .fp_data_read3_id_ex(fp_data_read3_id_ex),
        .fp_data_read4_id_ex(fp_data_read4_id_ex),
        .vector_data_read1_id_ex(vector_data_read1_id_ex),
        .vector_data_read2_id_ex(vector_data_read2_id_ex),
        .vector_data_read3_id_ex(vector_data_read3_id_ex),
        .big_immediate_id_ex(big_immediate_id_ex),
        .reg_dest_id_ex(reg_dest_id_ex),
        .reg1_id_ex(reg1_id_ex), 
        .reg2_id_ex(reg2_id_ex),
        .reg3_id_ex(reg3_id_ex),
        .funct3_id_ex(funct3_id_ex),
        .funct7_id_ex(funct7_id_ex)
    );

    logic [1:0] forward_a, forward_b, forward_c;
    Forward forwarding_unit ( 
        .id_ex_rs1(reg1_id_ex), 
        .id_ex_rs2(reg2_id_ex), 
        .id_ex_rs3(reg_dest_id_ex),
        .ex_mem_rd(ex_mem_rd_dup), 
        .mem_wb_rd(mem_wb_reg_dest),
        .ex_mem_reg_write(ex_mem_regwrite_dup), 
        .ex_mem_vec_regwrite(ex_mem_vec_reg_write),
        .mem_wb_reg_write(mem_wb_regwrite),
        .mem_wb_vec_regwrite(mem_wb_vec_reg_write),
        .id_ex_vec_op(vec_op_id_ex),
        .ex_mem_vec_op(ex_mem_vec_op),
        .mem_wb_vec_op(mem_wb_vec_op),
        .forward_a(forward_a), 
        .forward_b(forward_b),
        .forward_c(forward_c)
    );

    logic [1:0] fp_forward_a, fp_forward_b, fp_forward_c, fp_forward_d;
    fp_forward fp_forwarding_unit ( 
        .id_ex_rs1(reg1_id_ex),
        .id_ex_rs2(reg2_id_ex),
        .id_ex_rs3(reg3_id_ex),
        .id_ex_rs4(reg_dest_id_ex),
        .ex_mem_rd(ex_mem_rd_dup),
        .mem_wb_rd(mem_wb_reg_dest),
        .ex_mem_reg_write(ex_mem_fp_reg_write),
        .mem_wb_reg_write(mem_wb_fp_reg_write),
        .id_ex_fp_instruction(fp_instruction_id_ex),
        .ex_mem_fp_instruction(ex_mem_fp_instruction),
        .mem_wb_fp_instruction(mem_wb_fp_instruction),

        .fp_forward_a(fp_forward_a),
        .fp_forward_b(fp_forward_b),
        .fp_forward_c(fp_forward_c),
        .fp_forward_d(fp_forward_d)
    );

    // ------EXECUTE STAGE------
    logic [3:0] alu_control;
    logic [31:0] alu_result;
    logic zero;
    logic is_mac;
    logic [31:0] alu_input, alu_input2;
    logic [31:0] v_alu_input [0:vector_length-1], v_alu_input2 [0:vector_length-1];
    logic [31:0] v_alu_result [0:vector_length-1];
    logic [31:0] fp_alu_result;

    ALU_control alu_control_unit (
        .alu_op(id_ex_alu_op),
        .funct3(funct3_id_ex),
        .alu_src(id_ex_alu_src), 
        .funct7(funct7_id_ex[5]),
        .funct7_mac(funct7_id_ex[0]),
        .is_mac(is_mac),
        .alu_control(alu_control)
    );

    fp_alu_control fp_alu_control_unit (
        .fp_op(id_ex_fp_op),
        .funct7(funct7_id_ex),
        .funct3(funct3_id_ex),

        .fp_alu_op(fp_alu_op),
        .rm(rm)
    );

    logic [31:0] fp_alu_operand1, fp_alu_operand2, fp_alu_operand3;

    always_comb begin
        fp_alu_operand1 = '0;
        fp_alu_operand2 = '0;
        fp_alu_operand3 = '0;

        if(fp_instruction_id_ex) begin
            unique case (fp_forward_a)
                2'b00: fp_alu_operand1 = fp_data_read1_id_ex;
                2'b01: fp_alu_operand1 = mem_wb_write_data[0];
                2'b10: fp_alu_operand1 = ex_mem_alu_result[0];
                default : fp_alu_operand1 = fp_data_read1_id_ex;
            endcase

            unique case (fp_forward_b)
                2'b00: fp_alu_operand2 = fp_data_read2_id_ex;
                2'b01: fp_alu_operand2 = mem_wb_write_data[0];
                2'b10: fp_alu_operand2 = ex_mem_alu_result[0];
                default : fp_alu_operand2 = fp_data_read2_id_ex;
            endcase

            unique case (fp_forward_c)
                2'b00: fp_alu_operand3 = fp_data_read3_id_ex;
                2'b01: fp_alu_operand3 = mem_wb_write_data[0];
                2'b10: fp_alu_operand3 = ex_mem_alu_result[0];
                default : fp_alu_operand3 = fp_data_read3_id_ex;
            endcase
        end
    end

    logic [31:0] alu_operand1, alu_operand2, alu_operand3;
    logic [31:0] va_operand1 [0:vector_length-1], va_operand2 [0:vector_length-1], va_operand3 [0:vector_length-1];

    always_comb begin
        for (int i = 0; i < vector_length; i++) begin
            va_operand1[i] = '0;
            va_operand2[i] = '0;
            va_operand3[i] = '0;
        end

        alu_operand1 = '0;
        alu_operand2 = '0;
        alu_operand3 = '0;

        if(vec_op_id_ex) begin
            unique case (forward_a)
                2'b00: va_operand1 = vector_data_read1_id_ex;
                2'b01: va_operand1 = mem_wb_write_data;
                2'b10: va_operand1 = ex_mem_alu_result;
                default: va_operand1 = vector_data_read1_id_ex;
            endcase

            unique case (forward_b)
                2'b00: va_operand2 = vector_data_read2_id_ex;
                2'b01: va_operand2 = mem_wb_write_data;
                2'b10: va_operand2 = ex_mem_alu_result;
                default: va_operand2 = vector_data_read2_id_ex;
            endcase

            unique case (forward_c)
                2'b00: va_operand3 = vector_data_read3_id_ex;
                2'b01: va_operand3 = mem_wb_write_data;
                2'b10: va_operand3 = ex_mem_alu_result;
                default: va_operand3 = vector_data_read3_id_ex;
            endcase
        end else begin
            unique case (forward_a)
                2'b00: alu_operand1 = data_read1_id_ex;
                2'b01: alu_operand1 = mem_wb_write_data[0];
                2'b10: alu_operand1 = ex_mem_alu_result[0];
                default: alu_operand1 = data_read1_id_ex;
            endcase

            unique case (forward_b)
                2'b00: alu_operand2 = data_read2_id_ex;
                2'b01: alu_operand2 = mem_wb_write_data[0];
                2'b10: alu_operand2 = ex_mem_alu_result[0];
                default: alu_operand2 = data_read2_id_ex;
            endcase

            unique case (forward_c)
                2'b00: alu_operand3 = data_read3_id_ex;
                2'b01: alu_operand3 = mem_wb_write_data[0];
                2'b10: alu_operand3 = ex_mem_alu_result[0];
                default: alu_operand3 = data_read3_id_ex;
            endcase
        end
    end
        
    assign alu_input = (id_ex_auipc) ? pc_id_ex : (id_ex_lui) ? '0 : alu_operand1;
    assign alu_input2 = id_ex_alu_src ? big_immediate_id_ex: alu_operand2;

    logic use_scalar1;
    logic [31:0] scalar1;

    assign use_scalar1 = id_ex_auipc || (alu_control == 4'b1100); // 1100b = 12d => vmove

    always_comb begin
        scalar1 = 32'b0;
        if(id_ex_auipc) begin
            scalar1 = pc_id_ex;
        end else if (alu_control == 4'b1100) begin // 1100b = 12d => vmove
            scalar1 = data_read1_id_ex;
        end
    end

    always_comb begin
        for(int i = 0; i < vector_length; i++) begin
            if(use_scalar1) begin
                v_alu_input[i] = scalar1;
            end else begin
                v_alu_input[i] = va_operand1[i];
            end

            if(id_ex_alu_src) begin
                v_alu_input2[i] = (id_ex_continous_addr) ? big_immediate_id_ex + i : big_immediate_id_ex;
            end else begin
                v_alu_input2[i] = va_operand2[i];
            end
        end
    end
    
    logic [24:0] scalar_mac_input_a;
    logic [17:0] scalar_mac_input_b;
    logic [43:0] scalar_mac_result;
    logic [31:0] scalar_mac_input_c, ex_result;
    logic [31:0] complete_alu_result [0:vector_length-1];

    logic [24:0] vector_mac_input_a [0:vector_length-1];
    logic [17:0] vector_mac_input_b [0:vector_length-1];
    logic [43:0] vector_mac_result [0:vector_length-1];
    logic [31:0] vector_mac_input_c [0:vector_length-1], vec_ex_result [0:vector_length-1];

    logic [31:0] fp_mac_mul_result;

    // Prepare inputs if MAC
    always_comb begin
        if (is_mac) begin 
            scalar_mac_input_a = alu_operand1[24:0]; 
            scalar_mac_input_b = alu_operand2[17:0]; 
            scalar_mac_input_c = alu_operand3; 
        end else begin
            scalar_mac_input_a = 25'b0;
            scalar_mac_input_b = 18'b0;
            scalar_mac_input_c = 32'b0;
        end
    end

    always_comb begin 
        if(is_mac) begin
            for(int i = 0; i < vector_length; i++) begin
                vector_mac_input_a[i] = va_operand1[i][24:0];
                vector_mac_input_b[i] = va_operand2[i][17:0];
                vector_mac_input_c[i] = va_operand3[i];
            end
        end else begin
            for(int i = 0; i < vector_length; i++) begin
                vector_mac_input_a[i] = 25'b0;
                vector_mac_input_b[i] = 18'b0;
                vector_mac_input_c[i] = 32'b0;
            end
        end
    end

    genvar mac_num;
    generate 
        for (mac_num = 0; mac_num < vector_length; mac_num++) begin : mac_block
            MAC_dsp vector_mac (
                .A(vector_mac_input_a[mac_num]),
                .B(vector_mac_input_b[mac_num]),
                .C(vector_mac_input_c[mac_num]),
                .P(vector_mac_result[mac_num])
            );
        end
    endgenerate

    MAC_dsp scalar_dsp (
        .A(scalar_mac_input_a),
        .B(scalar_mac_input_b),
        .C(scalar_mac_input_c),
        .P(scalar_mac_result)
    );

    ALU alu (
        .a(alu_input), 
        .b(alu_input2), 
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero) 
    );

    vector_ALU #(
        .vec_length(vector_length)
    ) v_alu (
        .a(v_alu_input),
        .b(v_alu_input2),
        .c(vector_data_read3_id_ex),
        .alu_control(alu_control),
        .result(v_alu_result)
    );

    logic [31:0] alu_fp_1, alu_fp_2;

    always_comb begin
        if(reset) begin
            alu_fp_1 = 32'b0;
            alu_fp_2 = 32'b0;
        end else begin
            alu_fp_1 = id_ex_fp_store || id_ex_fp_load  || fp_alu_op == FMVWX ? alu_operand1 : fp_alu_operand1;
            alu_fp_2 = id_ex_fp_alu_src ? big_immediate_id_ex : fp_alu_operand2;
        end
    end

    logic [31:0] itf_result;
    logic itf_result_valid;

    int_to_float_ip itf_inst (
        .s_axis_a_tdata(alu_operand1),
        .s_axis_a_tvalid(fp_alu_op == FCVTSW),
        .m_axis_result_tdata(itf_result),
        .m_axis_result_tvalid(itf_result_valid)
    );

    fp_alu fp_alu (
        .clk(clk),
        .a(alu_fp_1),
        .b(alu_fp_2),
        .fp_alu_op(fp_alu_op),
        .rm(rm),

        .result(fp_alu_result),
        .result_valid(fp_alu_result_valid)
    );

    // MAC multiply operations
    floating_point_multiplier mac_mult (
        .aclk(clk),
        .s_axis_a_tdata(fp_alu_operand1),
        .s_axis_b_tdata(fp_alu_operand2),
        .s_axis_a_tvalid(id_ex_fmat_type == FMADD),
        .s_axis_b_tvalid(id_ex_fmat_type == FMADD),

        .m_axis_result_tdata(fp_mac_mul_result),
        .m_axis_result_tvalid(fp_mac_result_valid)
    );

    assign ex_result = (is_mac) ? scalar_mac_result[31:0] : alu_result;
    
    always_comb begin
        if(reset) begin
            for (int i = 0; i < vector_length; i++) begin
                vec_ex_result[i] = 32'b0;
            end
        end else if(is_mac) begin
            for(int i = 0; i < vector_length; i++) begin
                vec_ex_result[i] = vector_mac_result[i][31:0];
            end
        end else begin
            for(int i = 0; i < vector_length; i++) begin
                vec_ex_result[i] = v_alu_result[i];
            end
        end
    end

    always_comb begin : alu_result_mux
        if(vec_op_id_ex) begin
            complete_alu_result = vec_ex_result;
        end else if (fp_instruction_id_ex) begin
            complete_alu_result[0] = fp_alu_op == FCVTSW ? itf_result : fp_alu_result;
            for(int i = 1; i < vector_length; i++) begin
                complete_alu_result[i] = 32'b0;
            end
        end else begin
            complete_alu_result[0] = ex_result;
            for(int i = 1; i < vector_length; i++) begin
                complete_alu_result[i] = 32'b0;
            end
        end
    end

    logic [31:0] link_addr_ex1;

    assign led = complete_alu_result[0][0];
    assign link_addr_ex1 = pc_id_ex + 32'h4;

    branch branch_unit (
        .pc(pc_id_ex), 
        .read_data1(alu_operand1), 
        .read_data2(alu_operand2),
        .big_immediate(big_immediate_id_ex),
        .branch(id_ex_branch), 
        .beq(id_ex_beq),
        .bne(id_ex_bne),
        .blt(id_ex_blt),
        .bge(id_ex_bge),
        .jal(id_ex_jal), 
        .jalr(id_ex_jalr), 
        .next_pc(ex_next_pc),
        .branch_taken(ex_taken)
    );

    logic [31:0] data_to_memory;
    assign data_to_memory = fp_instruction_id_ex ? fp_alu_operand2 : alu_operand2;

    logic ex_mem_read, ex_mem_write, ex_mem_to_reg;

    assign ex_mem_read = id_ex_mem_read | id_ex_fp_load;
    assign ex_mem_write = id_ex_mem_write | id_ex_fp_store;
    assign ex_mem_to_reg = id_ex_memtoreg | id_ex_fp_load;

    // ------EXECUTE STAGE / MEMORY STAGE------

    EX_MEM_reg #(
        .vec_length(vector_length)
    ) ex_mem_reg (
        .clk(clk), 
        .reset(reset),
        .stall(mac_stall),
        .vec_op(vec_op_id_ex),
        .id_ex_fp_instruction(fp_instruction_id_ex),
        .id_ex_fp_reg_write(fp_reg_write_id_ex),
        .vec_reg_write(vec_reg_write_id_ex),
        .id_ex_single_load(id_ex_single_load),
        .id_ex_mem_read(ex_mem_read),
        .id_ex_mem_write(ex_mem_write),
        .id_ex_memtoreg(ex_mem_to_reg), 
        .id_ex_reg_write(id_ex_reg_write), 
        .id_ex_jal(id_ex_jal), 
        .id_ex_jalr(id_ex_jalr), 
        .id_ex_fmat_type(id_ex_fmat_type),
        .conv_data_read_id_ex(conv_addr_read_id_ex),
        .weights_data_read_id_ex(weights_addr_read_id_ex),
        .id_ex_fp_mac_1(fp_mac_mul_result),
        .id_ex_fp_mac_2(fp_alu_operand3),
        .alu_result(complete_alu_result),
        .data_read2_id_ex(data_to_memory), 
        .vec_data_read2_id_ex(va_operand3),
        .id_ex_rs1(reg1_id_ex),
        .id_ex_rs2(reg2_id_ex),
        .reg_dest_id_ex(reg_dest_id_ex),
        .ex_link_address(link_addr_ex1),
        .funct3(funct3_id_ex),
        .conv_data_length(conv_data_length),
        .conv_weights_length(conv_weights_length),
        .data_counter(ex_mem_data_counter),
        .weights_counter(ex_mem_weights_counter),

        .ex_mem_vec_op(ex_mem_vec_op),
        .ex_mem_fp_instruction(ex_mem_fp_instruction),
        .ex_mem_fp_reg_write(ex_mem_fp_reg_write),
        .ex_mem_vec_reg_write(ex_mem_vec_reg_write),
        .ex_mem_single_load(ex_mem_single_load),
        .ex_mem_memread(ex_mem_memread),
        .ex_mem_memwrite(ex_mem_memwrite),
        .ex_mem_memtoreg(ex_mem_memtoreg),
        .ex_mem_regwrite(ex_mem_regwrite),
        .ex_mem_jal(ex_mem_jal),
        .ex_mem_jalr(ex_mem_jalr),
        .ex_mem_fmat_type(ex_mem_fmat_type),
        .ex_mem_conv_data_read(ex_mem_conv_addr),
        .ex_mem_weights_data_read(ex_mem_weights_addr),
        .ex_mem_fp_mac_1(ex_mem_fp_mac_1),
        .ex_mem_fp_mac_2(ex_mem_fp_mac_2),
        .ex_mem_alu_result(ex_mem_alu_result),
        .ex_mem_data_read2(ex_mem_data_read2),
        .vec_ex_mem_data_read2(vec_ex_mem_data_read2),
        .ex_mem_rs1(ex_mem_rs1),
        .ex_mem_rs2(ex_mem_rs2),
        .ex_mem_reg_dest(ex_mem_reg_dest),
        .ex_mem_link_address_reg(ex_mem_link_address_reg),
        .ex_mem_funct3(ex_mem_funct3),
        .ex_mem_data_counter(ex_mem_data_counter),
        .ex_mem_weights_counter(ex_mem_weights_counter)
    );

    logic [31:0] mac_result;

    // Keeps track of the fp mac result register
    // When completed, it writes to this register
    // in the regfile
    always_ff @(posedge clk) begin
        if(reset) begin
            fp_mac_result_reg_dest <= '0;
            mac_result <= '0;
        end else if (ex_mem_fmat_type == FMADD) begin
            fp_mac_result_reg_dest <= ex_mem_reg_dest;
        end else if (ex_mem_mac_result_valid) begin
            mac_result <= ex_mem_mac_result;
        end
    end

    //MAC adder operations 
    floating_point_add_sub mac_adder (
        .aclk(clk),
        .s_axis_a_tdata(fp_mac_mul_result),
        .s_axis_b_tdata(ex_mem_fp_mac_2),
        .s_axis_a_tvalid(fp_mac_result_valid),
        .s_axis_b_tvalid(fp_mac_result_valid),

        .m_axis_result_tdata(ex_mem_mac_result),
        .m_axis_result_tvalid(ex_mem_mac_result_valid)
    );

    // ------MEMORY STAGE------
    logic inside_data_mem;
    logic [31:0] memory_address [0:vector_length-1];
    logic [31:0] write_data [0:vector_length-1];

    assign memory_address[0] = ex_mem_fmat_type == FMADD ? ex_mem_conv_addr: ex_mem_alu_result[0];
    assign memory_address[1] = ex_mem_fmat_type == FMADD ? ex_mem_weights_addr : ex_mem_alu_result[1];
    assign inside_data_mem = (memory_address[0] < (data_base + data_word_space -1));

    always_comb begin
        if(ex_mem_vec_op) begin
            write_data = vec_ex_mem_data_read2;
        end else if (ex_mem_memwrite && ex_mem_fp_instruction && (ex_mem_rs2 == fp_mac_result_reg_dest)) begin
            write_data[0] = mac_result;
            for(int i = 1; i < vector_length; i++) begin
                write_data[i] = 32'b0;
            end
        end else begin
            write_data[0] = ex_mem_data_read2;
            for(int i = 1; i < vector_length; i++) begin
                write_data[i] = 32'b0;
            end
        end
    end

    logic data_length_store, weights_length_store, output_length_store;
    assign data_length_store = (memory_address[0] == data_length_addr) && ex_mem_memwrite;
    assign weights_length_store = (memory_address[0] == weights_length_addr) && ex_mem_memwrite;
    assign output_length_store = (memory_address[0] == output_length_addr) && ex_mem_memwrite;

    always_ff @(posedge clk) begin
        if (reset) begin
            conv_data_length <= '0;
            conv_weights_length <= '0;
            conv_output_length <= '0;
        end else begin
            if(data_length_store) begin
                conv_data_length <= write_data[0];
            end else if(weights_length_store) begin
                conv_weights_length <= write_data[0] - 32'd1; // adjust for zero indexing due to preload
            end else if(output_length_store) begin
                conv_output_length <= write_data[0];
            end
        end
    end

    Data_memory #(
        .vec_length(vector_length),
        .data_base(data_base),
        .data_addresses(data_word_space),
        .UART_base(data_base + data_word_space)
    ) data_mem(
        .clk(clk),
        .single_load(ex_mem_single_load),
        .fmac(ex_mem_fmat_type == FMADD),
        .address(memory_address),
        .write_data(write_data),
        .funct3(ex_mem_funct3),
        .mem_write(ex_mem_memwrite),
        .mem_read(ex_mem_memread),
        .vec_op(ex_mem_vec_op),

        .read_data(memory_data_read)
    );

    // holds the data received from UART
    logic [31:0] uart_data;
    logic [31:0] uart_send_data;

    logic [31:0] uart_memory [0:vector_length-1];
    logic override_data_read;
    logic data_word_complete;
    logic [1:0] data_place; // rx indexing
    logic [1:0] data_send; // tx indexing
    logic tx_done_tick;
    logic word_in_progress;
    logic uart_write_to_mem, send_byte, ready_to_send;

    // Number descriptions at the top of the file
    uart_top #(
        .DBITS(8),
        .SB_TICK(16),
        .BR_LIMIT(54),
        .BR_BITS(6),
        .FIFO_EXP(2)
    ) uart (
        .clk_100MHz(clk),
        .reset(reset),
        .read_uart(uart_write_to_mem),
        .write_uart(send_byte),
        .rx(rx),
        .write_data(uart_write_data),
        .rx_full(uart_rx_full),
        .rx_empty(uart_rx_empty),
        .tx(tx),
        .tx_done(tx_done_tick),
        .read_data(uart_read_data)
    );

    logic receive_send;
    assign receive_send = (memory_address[0] == uart_send) && ex_mem_memwrite;

    always_ff @(posedge clk) begin : uart_write_control
        if(reset) begin
            uart_write_to_mem <= 1'b0;
        end else if(uart_rx_full) begin
            uart_write_to_mem <= 1'b1;
        end else if(uart_rx_empty) begin
            uart_write_to_mem <= 1'b0;
        end
    end

    always_ff @(posedge clk) begin : uart_rx_tx_process
        if(reset) begin
            data_send <= 2'b00;
            ready_to_send <= 1'b0;
            uart_write_data <= 8'b0;
            send_byte <= 1'b0;
            uart_send_data <= 32'b0;
            word_in_progress <= 1'b0;
            data_word_complete <= 1'b0;
            data_place <= 2'b00;
            uart_data <= 32'b0;
        end else begin
            send_byte <= 1'b0;

            // TX
            if(receive_send && !word_in_progress) begin
                uart_send_data <= write_data[0];
                ready_to_send <= 1'b1;
                data_send <= 2'd1;
                word_in_progress <= 1'b1;
                uart_write_data <= write_data[0][31:24];
                send_byte <= 1'b1;
                data_word_complete <= 1'b0;
                data_place <= 2'b0;
            end

            if (ready_to_send && tx_done_tick) begin
                case (data_send)
                2'd1: begin
                    uart_write_data <= uart_send_data[23:16];
                    send_byte <= 1'b1;
                end
                2'd2: begin
                    uart_write_data <= uart_send_data[15:8];
                    send_byte <= 1'b1;
                end
                2'd3: begin
                    uart_write_data <= uart_send_data[7:0];
                    send_byte <= 1'b1;
                    ready_to_send <= 1'b0;
                    uart_send_data <= 32'b0;
                    word_in_progress <= 1'b0;
                end
                default: ;
                endcase
                data_send <= data_send + 1'b1;
            end 

            // RX 
            if(uart_write_to_mem) begin
                case (data_place) 
                    2'd0: uart_data[31:24] <= uart_read_data;
                    2'd1: uart_data[23:16] <= uart_read_data;
                    2'd2: uart_data[15:8] <= uart_read_data;
                    2'd3: begin
                        uart_data[7:0] <= uart_read_data;
                        data_word_complete <= 1'b1;
                    end
                    default: ;
                endcase
                data_place <= data_place + 1'b1;
            end
        end
    end

    logic status_read, receive_read;
    assign status_read = (memory_address[0] == uart_status) && ex_mem_memread;
    assign receive_read = (memory_address[0] == uart_receive) && ex_mem_memread;

    always_comb begin : uart_memory_override
        override_data_read = 1'b0;
        for(int i = 0; i < vector_length; i++) begin
            uart_memory[i] = 32'b0;
        end

        if(status_read) begin
            uart_memory[0] = (data_word_complete) ? 32'b1 : 32'b0;
            override_data_read = 1'b1;
        end else if(receive_read && data_word_complete) begin
            uart_memory[0] = uart_data;
            override_data_read = 1'b1;
        end
    end

    MEM_WB_reg #(
        .vec_length(vector_length)
    ) mem_wb_reg (
        .clk(clk),
        .reset(reset),
        .ex_mem_vec_op(ex_mem_vec_op),
        .ex_mem_fp_instruction(ex_mem_fp_instruction),
        .ex_mem_fmat_type(ex_mem_fmat_type),
        .ex_mem_fp_reg_write(ex_mem_fp_reg_write),
        .ex_mem_vec_reg_write(ex_mem_vec_reg_write),
        .ex_mem_memtoreg(ex_mem_memtoreg),
        .uart_instruction(status_read | receive_read | receive_send),
        .ex_mem_regwrite(ex_mem_regwrite),
        .ex_mem_jal(ex_mem_jal),
        .ex_mem_jalr(ex_mem_jalr),
        .ex_mem_alu_result(ex_mem_alu_result),
        .memory_data_read((override_data_read) ? uart_memory : memory_data_read),
        .ex_mem_rs1(ex_mem_rs1),
        .ex_mem_rs2(ex_mem_rs2),
        .ex_mem_reg_dest(ex_mem_reg_dest),
        .ex_mem_link_address_reg(ex_mem_link_address_reg),
        .ex_mem_conv_addr(ex_mem_conv_addr),
        .ex_mem_weights_addr(ex_mem_weights_addr),

        .mem_wb_vec_op(mem_wb_vec_op),
        .mem_wb_fp_instruction(mem_wb_fp_instruction),
        .mem_wb_fmat_type(mem_wb_fmat_type),
        .mem_wb_fp_reg_write(mem_wb_fp_reg_write),
        .mem_wb_vec_reg_write(mem_wb_vec_reg_write),
        .mem_wb_memtoreg(mem_wb_memtoreg),
        .mem_wb_regwrite(mem_wb_regwrite),
        .mem_wb_jal(mem_wb_jal),
        .mem_wb_jalr(mem_wb_jalr),
        .mem_wb_alu_result(mem_wb_alu_result),
        .mem_wb_memory_data_read(mem_wb_memory_data_read),
        .mem_wb_rs1(mem_wb_rs1),
        .mem_wb_rs2(mem_wb_rs2),
        .mem_wb_reg_dest(mem_wb_reg_dest),
        .mem_wb_link_address(mem_wb_link_address),
        .mem_wb_write_data(mem_wb_write_data),
        .mem_wb_conv_addr(mem_wb_conv_addr),
        .mem_wb_weights_addr(mem_wb_weights_addr)
    );    

    // 7 segment display
    assign an = 4'b1110;
    assign seg = {~uart_rx_full, 2'b11, ~uart_rx_empty, 3'b111};

endmodule