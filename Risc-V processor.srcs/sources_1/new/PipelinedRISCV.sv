`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CAWT
// Engineer: Fernando L. Pizarro Diaz
// 
// Create Date: 05/27/2025 10:22:03 AM
// Design Name: Eutanio 
// Module Name: RISCV_PIPELINED
// Project Name: RISC-V Processor (w/ vector computations and UART communication)
// Target Devices: Basys3
// Tool Versions: SystemVerilog
// Description: A pipelined RISC-V processor implementation, with support for the majority of its instructions.
// Has 2 memory instances, and one DSP instance for MAC operations (A*B + C = P).
// ALU has its own register called accumulator (C). 
// MAC is its own instruction to substitute the mul -> add instruction when calculating convolutions
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

package fp_fma_pkg;
    typedef enum logic [1:0] { 
        FM_NONE  = 2'b00,
        FMADD    = 2'b01,
        FNMADD   = 2'b10
    } fp_fma_t;
endpackage

package fp_alu_pkg;
    typedef enum logic [2:0] {
        FADD = 3'd0,
        FSUB = 3'd1,
        FMUL = 3'd2,
        FEQ = 3'd3, // Equal
        FLT = 3'd4, // Less Than
        FLE = 3'd5 // Less Than or Equal
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
    // Keep this number even, because data memory is organized in pairs of words
    localparam vector_length = 2;

    localparam data_base = 32'h1000_0000;
    localparam data_word_space = 8360 * 4; // 33,440 bytes
    localparam uart_status = data_base + data_word_space + 4; // 8361 in memory
    localparam uart_receive = uart_status + 4;
    localparam uart_send = uart_receive + 4;

    // UART Parameters
    localparam data_bits = 8;
    localparam stop_tick = 16; // Stop bit / Oversampling ticks
    localparam fifo_exp = 2; // 2^2 = 4 entries in the FIFO's

    (* MARK_DEBUG = "TRUE" *) logic [data_bits-1:0] uart_write_data;
    logic [data_bits-1:0] uart_read_data;
    logic uart_rx_full, uart_rx_empty;

    // IF/ID pipeline registers
    logic [31:0] instruction_if_id;
    logic [31:0] pc_if_id;
    
    // Flush signal 
    logic ex_taken;
    
    // Hazard detection unit to handle stalls
    logic stall, pc_write, if_id_write;
    
    // ID/EX pipeline registers
    logic [31:0] pc_id_ex, instruction_id_ex;
    logic vec_op_id_ex, vec_reg_write_id_ex;
    logic id_ex_continous_addr;
    logic id_ex_single_load;
    logic id_ex_branch, id_ex_beq, id_ex_bne, id_ex_blt, id_ex_bge, id_ex_mem_read, id_ex_memtoreg, id_ex_mem_write, id_ex_auipc, id_ex_alu_src, id_ex_reg_write, id_ex_jal, id_ex_jalr;
    logic id_ex_lui;
    logic [1:0] id_ex_alu_op;
    logic [31:0] data_read1_id_ex, data_read2_id_ex, data_read3_id_ex;
    logic [31:0] vector_data_read1_id_ex [0:vector_length-1];
    logic [31:0] vector_data_read2_id_ex [0:vector_length-1];
    logic [31:0] vector_data_read3_id_ex [0:vector_length-1];
    logic [31:0] big_immediate_id_ex;
    logic [4:0] reg_dest_id_ex, reg1_id_ex, reg2_id_ex;
    logic [2:0] funct3_id_ex;
    logic [6:0] funct7_id_ex;
    logic id_ex_flush; 

    assign id_ex_flush = ex_taken || stall;
    
    logic [31:0] ex_next_pc;

    // EX/MEM pipeline registers
    logic ex_mem_vec_op, ex_mem_vec_reg_write;
    logic ex_mem_enable;
    logic ex_mem_single_load;
    logic ex_mem_memread, ex_mem_memwrite, ex_mem_memtoreg, ex_mem_regwrite, ex_mem_jal, ex_mem_jalr;
    logic [31:0] ex_mem_alu_result [0:vector_length-1], ex_mem_data_read2;
    logic [31:0] vec_ex_mem_data_read2 [0:vector_length-1];
    logic [4:0] ex_mem_reg_dest;
    logic [2:0] ex_mem_funct3;
    logic [31:0] ex_mem_link_address_reg;

    // Duplicate the 5-bit RD bus with max 16-sink clusters
    (* DONT_TOUCH = "true" *) wire [4:0] ex_mem_rd_dup = ex_mem_reg_dest;

    // Do the same for the write-enable bit if it has high fan-out
    (* DONT_TOUCH = "true" *) wire       ex_mem_regwrite_dup = ex_mem_regwrite;
    
    // MEM/WB pipeline registers
    logic mem_wb_memtoreg, mem_wb_regwrite, mem_wb_jal, mem_wb_jalr, mem_wb_vec_op, mem_wb_vec_reg_write;
    logic [31:0] mem_wb_alu_result [0:vector_length-1], mem_wb_memory_data_read [0:vector_length-1], mem_wb_link_address;
    logic [4:0] mem_wb_reg_dest;
    logic [31:0] mem_wb_write_data [0:vector_length-1];

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
        .pc_write(pc_write),
        .next_pc(next_pc), 
        .pc(pc)
    );

    InstructionMemory im (
        .clk(clk),
        .stall(stall),
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
        .if_id_write(if_id_write),
        .pc(fetch_pc), 
        .instruction(instruction), 
        .pc_if_id(pc_if_id), 
        .instruction_if_id(instruction_if_id) 
    );

    // ------DECODE STAGE------
    logic [4:0] reg1, reg2;
    (* MARK_DEBUG = "TRUE" *) logic [4:0] reg_dest;
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;


    // Extracting the fields for readable signals
    assign opcode = instruction_if_id[6:0]; 
    assign reg1 = instruction_if_id[19:15]; 
    assign reg2 = instruction_if_id[24:20]; 
    assign reg_dest = instruction_if_id[11:7]; 
    assign funct3 = instruction_if_id[14:12]; 
    assign funct7 = instruction_if_id[31:25]; 

    logic [31:0] data_read1, data_read2;
    (* MARK_DEBUG = "TRUE" *) logic [31:0] data_read3;
    logic [31:0] vector_data_read1 [0:vector_length-1];
    logic [31:0] vector_data_read2 [0:vector_length-1];
    logic [31:0] vector_data_read3 [0:vector_length-1];
    
    Registers regs (
        .clk(clk),
        .reset(reset),
        .read_reg1(reg1),
        .read_reg2(reg2),
        .read_reg3(reg_dest),
        .write_reg(mem_wb_reg_dest), 
        .write_data(mem_wb_write_data[0]),
        .reg_write_enable(mem_wb_regwrite),
        .read_data1(data_read1),
        .read_data2(data_read2),
        .read_data3(data_read3)
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

    logic [31:0] big_immediate;

    Immediate_generator imm_gen (
        .instruction(instruction_if_id), 
        .immediate(big_immediate) 
    );
    
    logic vec_op, vec_reg_write, continous_addr, single_load, branch, beq, bne, blt, bge, mem_read, memtoreg, mem_write, alu_src, reg_write, jal, jalr, auipc, lui;
    logic [1:0] alu_op;
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

    Hazard_Detection hazard_detection_unit (
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

    // ------INSTRUCTION DECODE / EXECUTE STAGE------    

    ID_EX_reg #(
        .vec_length(vector_length)
    ) id_ex_reg (
        .clk(clk), 
        .reset(reset), 
        .flush(id_ex_flush),
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
        .mem_write(mem_write), 
        .alu_src(alu_src), 
        .reg_write(reg_write), 
        .jal(jal), 
        .jalr(jalr), 
        .auipc(auipc),
        .lui(lui),
        .alu_op(alu_op), 
        .pc_if_id(pc_if_id), 
        .instruction_if_id(instruction_if_id), 
        .big_immediate(big_immediate), 
        .reg1(reg1), 
        .reg2(reg2), 
        .reg_dest(reg_dest), 
        .funct3(funct3), 
        .funct7(funct7),
        .scalar_data_read1(data_read1),
        .scalar_data_read2(data_read2),
        .scalar_data_read3(data_read3),
        .vector_data_read1(vector_data_read1),
        .vector_data_read2(vector_data_read2),
        .vector_data_read3(vector_data_read3),

        .pc_id_ex(pc_id_ex),
        .instruction_id_ex(instruction_id_ex),
        .vec_op_id_ex(vec_op_id_ex),
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
        .id_ex_alu_src(id_ex_alu_src),
        .id_ex_reg_write(id_ex_reg_write),
        .id_ex_jal(id_ex_jal),
        .id_ex_jalr(id_ex_jalr),
        .id_ex_alu_op(id_ex_alu_op),
        .scalar_data_read1_id_ex(data_read1_id_ex),
        .scalar_data_read2_id_ex(data_read2_id_ex),
        .scalar_data_read3_id_ex(data_read3_id_ex),
        .vector_data_read1_id_ex(vector_data_read1_id_ex),
        .vector_data_read2_id_ex(vector_data_read2_id_ex),
        .vector_data_read3_id_ex(vector_data_read3_id_ex),
        .big_immediate_id_ex(big_immediate_id_ex),
        .reg_dest_id_ex(reg_dest_id_ex),
        .reg1_id_ex(reg1_id_ex), 
        .reg2_id_ex(reg2_id_ex),
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

    // ------EXECUTE STAGE------
    logic [3:0] alu_control;
    logic [31:0] alu_result;
    logic zero;
    logic is_mac;
    logic [31:0] alu_input, alu_input2;
    logic [31:0] v_alu_input [0:vector_length-1], v_alu_input2 [0:vector_length-1];
    logic [31:0] v_alu_result [0:vector_length-1];

    ALU_control alu_control_unit (
        .alu_op(id_ex_alu_op),
        .funct3(funct3_id_ex),
        .alu_src(id_ex_alu_src), 
        .funct7(funct7_id_ex[5]),
        .funct7_mac(funct7_id_ex[0]),
        .is_mac(is_mac),
        .alu_control(alu_control)
    );

    logic [31:0] alu_operand1, alu_operand2, alu_operand3;
    logic [31:0] va_operand1 [0:vector_length-1], va_operand2 [0:vector_length-1], va_operand3 [0:vector_length-1];

    always_comb begin
        if(reset) begin
            for (int i = 0; i < vector_length; i++) begin
                va_operand1[i] = '0;
                va_operand2[i] = '0;
                va_operand3[i] = '0;
            end
        end if(vec_op_id_ex) begin
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

    always_comb begin
        for(int i = 0; i < vector_length; i++) begin
            v_alu_input[i] = (id_ex_auipc) ? pc_id_ex : va_operand1[i];
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

    always_comb begin
        if(vec_op_id_ex) begin
            complete_alu_result = vec_ex_result;
        end else begin
            complete_alu_result[0] = ex_result;
            for(int i = 1; i < vector_length; i++) begin
                complete_alu_result[i] = 32'b0;
            end
        end
    end

    logic [31:0] link_addr_ex1;

    assign led = complete_alu_result[0][0];
    assign link_addr_ex1 = pc_id_ex;

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


    // ------EXECUTE STAGE / MEMORY STAGE------

    EX_MEM_reg #(
        .vec_length(vector_length)
    ) ex_mem_reg (
        .clk(clk), 
        .reset(reset), 
        .vec_op(vec_op_id_ex),
        .vec_reg_write(vec_reg_write_id_ex),
        .id_ex_single_load(id_ex_single_load),
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_mem_write(id_ex_mem_write),
        .id_ex_memtoreg(id_ex_memtoreg), 
        .id_ex_reg_write(id_ex_reg_write), 
        .id_ex_jal(id_ex_jal), 
        .id_ex_jalr(id_ex_jalr), 
        .alu_result(complete_alu_result),
        .data_read2_id_ex(alu_operand2), 
        .vec_data_read2_id_ex(va_operand3),
        .reg_dest_id_ex(reg_dest_id_ex),
        .ex_link_address(link_addr_ex1),
        .funct3(funct3_id_ex),

        .ex_mem_vec_op(ex_mem_vec_op),
        .ex_mem_vec_reg_write(ex_mem_vec_reg_write),
        .ex_mem_single_load(ex_mem_single_load),
        .ex_mem_memread(ex_mem_memread),
        .ex_mem_memwrite(ex_mem_memwrite),
        .ex_mem_memtoreg(ex_mem_memtoreg),
        .ex_mem_regwrite(ex_mem_regwrite),
        .ex_mem_jal(ex_mem_jal),
        .ex_mem_jalr(ex_mem_jalr),
        .ex_mem_alu_result(ex_mem_alu_result),
        .ex_mem_data_read2(ex_mem_data_read2),
        .vec_ex_mem_data_read2(vec_ex_mem_data_read2),
        .ex_mem_reg_dest(ex_mem_reg_dest),
        .ex_mem_link_address_reg(ex_mem_link_address_reg),
        .ex_mem_funct3(ex_mem_funct3)
    );

    // ------MEMORY STAGE------
    logic [31:0] memory_data_read [0:vector_length-1];
    logic inside_data_mem;
    (* MARK_DEBUG = "TRUE" *) logic [31:0] memory_address;
    logic [31:0] write_data [0:vector_length-1];

    assign memory_address = ex_mem_alu_result[0];
    assign inside_data_mem = (memory_address < (data_base + data_word_space -1));
    assign ex_mem_enable = (ex_mem_memread || ex_mem_memwrite) && inside_data_mem;

    always_comb begin
        if(ex_mem_vec_op) begin
            write_data = vec_ex_mem_data_read2;
        end else begin
            write_data[0] = ex_mem_data_read2;
            for(int i = 1; i < vector_length; i++) begin
                write_data[i] = 32'b0;
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
        .address(memory_address),
        .write_data(write_data),
        .funct3(ex_mem_funct3),
        .mem_write(ex_mem_memwrite),
        .mem_read(ex_mem_memread),
        .vec_op(ex_mem_vec_op),

        .read_data(memory_data_read)
    );

    // holds the data received from UART
    (* MARK_DEBUG = "TRUE" *) logic [31:0] uart_data;
    (* MARK_DEBUG = "TRUE" *) logic [31:0] uart_send_data;

    logic [31:0] uart_memory [0:vector_length-1];
    logic override_data_read;
    logic data_word_complete; // indicates if a complete word has been received
    logic [1:0] data_place; // rx indexing
    logic [1:0] data_send; // tx indexing
    (* MARK_DEBUG = "TRUE" *) logic tx_done_tick; // baud rate tick to send the bits back
    logic word_in_progress; // indicates if a word is being sent
    logic uart_write_to_mem, send_byte, ready_to_send;

    uart_top #(
        .DBITS(data_bits),
        .SB_TICK(stop_tick),
        .FIFO_EXP(fifo_exp)
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

    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            uart_write_to_mem <= 1'b0;
        end else if(uart_rx_full) begin
            uart_write_to_mem <= 1'b1;
        end else if(uart_rx_empty) begin
            uart_write_to_mem <= 1'b0;
        end
    end

    // TX
    always_ff @(posedge clk or posedge reset) begin
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
            if((memory_address == uart_send) && ex_mem_memwrite && data_word_complete && !word_in_progress) begin
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

    (* MARK_DEBUG = "TRUE" *) logic status_read, receive_read;
    assign status_read = (memory_address == uart_status) && ex_mem_memread;
    assign receive_read = (memory_address == uart_receive) && ex_mem_memread;

    always_comb begin
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
        .ex_mem_vec_reg_write(ex_mem_vec_reg_write),
        .ex_mem_memtoreg(ex_mem_memtoreg),
        .ex_mem_regwrite(ex_mem_regwrite),
        .ex_mem_jal(ex_mem_jal),
        .ex_mem_jalr(ex_mem_jalr),
        .ex_mem_alu_result(ex_mem_alu_result),
        .memory_data_read((override_data_read) ? uart_memory : memory_data_read),
        .ex_mem_reg_dest(ex_mem_reg_dest),
        .ex_mem_link_address_reg(ex_mem_link_address_reg),

        .mem_wb_vec_op(mem_wb_vec_op),
        .mem_wb_vec_reg_write(mem_wb_vec_reg_write),
        .mem_wb_memtoreg(mem_wb_memtoreg),
        .mem_wb_regwrite(mem_wb_regwrite),
        .mem_wb_jal(mem_wb_jal),
        .mem_wb_jalr(mem_wb_jalr),
        .mem_wb_alu_result(mem_wb_alu_result),
        .mem_wb_memory_data_read(mem_wb_memory_data_read),
        .mem_wb_reg_dest(mem_wb_reg_dest),
        .mem_wb_link_address(mem_wb_link_address),
        .mem_wb_write_data(mem_wb_write_data)
    );    

    // 7 segment display
    assign an = 4'b1110;
    assign seg = {~uart_rx_full, 2'b11, ~uart_rx_empty, 3'b111};

endmodule