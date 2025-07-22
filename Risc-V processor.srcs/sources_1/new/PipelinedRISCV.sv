//////////////////////////////////////////////////////////////////////////////////
// Company: CAWT
// Engineer: Fernando L. Pizarro Diaz
// 
// Create Date: 05/27/2025 10:22:03 AM
// Design Name: Eutanio 
// Module Name: RISCV_PIPELINED
// Project Name: RISC-V Processor
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

module RISCV_PIPELINED (
    input logic clk,
    input logic reset, 
    output logic led
);
    // Keep this number even, because data memory is organized in pairs of words
    localparam vector_length = 2;

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
    logic id_ex_branch, id_ex_beq, id_ex_bne, id_ex_blt, id_ex_bge, id_ex_mem_read, id_ex_memtoreg, id_ex_mem_write, id_ex_auipc, id_ex_alu_src, id_ex_reg_write, id_ex_jal, id_ex_jalr;
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
    logic mem_wb_memtoreg, mem_wb_regwrite, mem_wb_jal, mem_wb_jalr, mem_wb_memtovreg, mem_wb_vec_op, mem_wb_vec_reg_write;
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
    logic [4:0] reg1, reg2, reg_dest;
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

    logic [31:0] data_read1, data_read2, data_read3;
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
    
    logic vec_op, vec_reg_write, branch, beq, bne, blt, bge, mem_read, memtoreg, mem_write, alu_src, reg_write, jal, jalr, auipc;
    logic [1:0] alu_op;
    Control control_unit (
        .opcode(opcode),
        .funct3(funct3),
        .vec_op(vec_op),
        .vec_reg_write(vec_reg_write),
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
        .auipc(auipc)
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
        .id_ex_branch(id_ex_branch),
        .id_ex_beq(id_ex_beq),
        .id_ex_bne(id_ex_bne),
        .id_ex_blt(id_ex_blt),
        .id_ex_bge(id_ex_bge),
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_memtoreg(id_ex_memtoreg),
        .id_ex_mem_write(id_ex_mem_write),
        .id_ex_auipc(id_ex_auipc),
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
        
    assign alu_input = id_ex_auipc ? pc_id_ex : alu_operand1;
    assign alu_input2 = id_ex_alu_src ? big_immediate_id_ex: alu_operand2;

    always_comb begin
        for(int i = 0; i < vector_length; i++) begin
            v_alu_input[i] = (id_ex_auipc) ? pc_id_ex : va_operand1[i];
            v_alu_input2[i] = (id_ex_alu_src) ? big_immediate_id_ex : va_operand2[i];
        end
    end
    
    logic [24:0] scalar_mac_input_a;
    logic [17:0] scalar_mac_input_b;
    logic [43:0] scalar_mac_result;
    logic [31:0] scalar_mac_input_c, ex_result;
    logic [31:0] complete_alu_result [0:vector_length-1];

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
        .is_mac(is_mac),
        .a(v_alu_input),
        .b(v_alu_input2),
        .c(vector_data_read3_id_ex),
        .alu_control(alu_control),
        .result(v_alu_result)
    );

    assign ex_result = (is_mac) ? scalar_mac_result[31:0] : alu_result;

    always_comb begin
        if(vec_op_id_ex) begin
            complete_alu_result = v_alu_result;
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
        .id_ex_mem_read(id_ex_mem_read),
        .id_ex_mem_write(id_ex_mem_write),
        .id_ex_memtoreg(id_ex_memtoreg), 
        .id_ex_reg_write(id_ex_reg_write), 
        .id_ex_jal(id_ex_jal), 
        .id_ex_jalr(id_ex_jalr), 
        .alu_result(complete_alu_result),
        .data_read2_id_ex(alu_operand2), 
        .vec_data_read2_id_ex(va_operand2),
        .reg_dest_id_ex(reg_dest_id_ex),
        .ex_link_address(link_addr_ex1),
        .funct3(funct3_id_ex),

        .ex_mem_vec_op(ex_mem_vec_op),
        .ex_mem_vec_reg_write(ex_mem_vec_reg_write),
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
    logic [31:0] write_data [0:vector_length-1];

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
        .vec_length(vector_length)
    ) data_mem(
        .clk(clk),
        .address(ex_mem_alu_result[0]),
        .write_data(write_data),
        .funct3(ex_mem_funct3),
        .mem_write(ex_mem_memwrite),
        .mem_read(ex_mem_memread),
        .vec_op(ex_mem_vec_op),

        .read_data(memory_data_read)
    );

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
        .memory_data_read(memory_data_read),
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
endmodule