import fp_fma_pkg::*;

module ID_EX_reg #(
    parameter vec_length = 2
) (
    input logic clk, 
    input logic reset, 
    input logic flush,
    input logic stall,
    input logic vec_op,
    input logic fp_instruction,
    input logic rd_is_int,
    input logic fp_reg_write,
    input logic vec_reg_write,
    input logic continous_addr,
    input logic single_load,
    input logic branch,
    input logic beq,
    input logic bne,
    input logic blt,
    input logic bge,
    input logic mem_read,
    input logic memtoreg,
    input logic mem_write,
    input logic alu_src,
    input logic reg_write,
    input logic jal,
    input logic jalr,
    input logic auipc,
    input logic lui,
    input logic fp_alu_src,
    input logic fp_load,
    input logic fp_store,
    input fp_fma_t fmat_type,
    input logic [31:0] conv_data_read, 
    input logic [31:0] weights_data_read,
    input logic [1:0] alu_op,
    input logic [1:0] fp_op,
    input logic [31:0] pc_if_id,
    input logic [31:0] instruction_if_id,
    input logic [31:0] big_immediate,
    input logic [4:0] reg1,
    input logic [4:0] reg2,
    input logic [4:0] reg3,
    input logic [4:0] reg_dest,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input logic [31:0] scalar_data_read1,
    input logic [31:0] scalar_data_read2,
    input logic [31:0] scalar_data_read3,
    input logic [31:0] fp_data_read1,
    input logic [31:0] fp_data_read2,
    input logic [31:0] fp_data_read3,
    input logic [31:0] fp_data_read4,
    input logic [31:0] vector_data_read1 [0:vec_length-1],
    input logic [31:0] vector_data_read2 [0:vec_length-1],
    input logic [31:0] vector_data_read3 [0:vec_length-1],

    output logic [31:0] pc_id_ex,
    output logic [31:0] instruction_id_ex,
    output logic vec_op_id_ex,
    output logic fp_instruction_id_ex,
    output lgoic rd_is_int_id_ex,
    output logic fp_reg_write_id_ex,
    output logic vec_reg_write_id_ex,
    output logic id_ex_continous_addr,
    output logic id_ex_single_load,
    output logic id_ex_branch,
    output logic id_ex_beq,
    output logic id_ex_bne,
    output logic id_ex_blt,
    output logic id_ex_bge,
    output logic id_ex_mem_read,
    output logic id_ex_memtoreg,
    output logic id_ex_mem_write,
    output logic id_ex_alu_src,
    output logic id_ex_reg_write,
    output logic id_ex_jal,
    output logic id_ex_jalr,
    output logic id_ex_auipc,
    output logic id_ex_lui,
    output logic id_ex_fp_alu_src,
    output logic id_ex_fp_load,
    output logic id_ex_fp_store,
    output fp_fma_t id_ex_fmat_type,
    output logic [31:0] conv_data_read_id_ex,
    output logic [31:0] weights_data_read_id_ex,
    output logic [1:0] id_ex_alu_op,
    output logic [1:0] id_ex_fp_op,
    output logic [31:0] scalar_data_read1_id_ex,
    output logic [31:0] scalar_data_read2_id_ex,
    output logic [31:0] scalar_data_read3_id_ex,
    output logic [31:0] fp_data_read1_id_ex,
    output logic [31:0] fp_data_read2_id_ex,
    output logic [31:0] fp_data_read3_id_ex,
    output logic [31:0] fp_data_read4_id_ex,
    output logic [31:0] vector_data_read1_id_ex [0:vec_length-1],
    output logic [31:0] vector_data_read2_id_ex [0:vec_length-1],
    output logic [31:0] vector_data_read3_id_ex [0:vec_length-1],
    output logic [31:0] big_immediate_id_ex,
    output logic [4:0] reg_dest_id_ex,
    output logic [4:0] reg3_id_ex,
    output logic [4:0] reg2_id_ex,
    output logic [4:0] reg1_id_ex,
    output logic [2:0] funct3_id_ex,
    output logic [6:0] funct7_id_ex  
);

    always_ff @(posedge clk) begin
        if (reset || flush) begin
            pc_id_ex <= 32'b0;
            instruction_id_ex <= 32'h13;
            vec_op_id_ex <= 1'b0;
            fp_instruction_id_ex <= 1'b0;
            rd_is_int_id_ex <= 1'b0;
            fp_reg_write_id_ex <= 1'b0;
            vec_reg_write_id_ex <= 1'b0;
            id_ex_continous_addr <= 1'b0;
            id_ex_single_load <= 1'b0;
            id_ex_branch <= 1'b0;
            id_ex_beq <= 1'b0;
            id_ex_bne <= 1'b0;
            id_ex_blt <= 1'b0;
            id_ex_bge <= 1'b0;
            id_ex_mem_read <= 1'b0;
            id_ex_memtoreg <= 1'b0;
            id_ex_mem_write <= 1'b0;
            id_ex_alu_src <= 1'b0;
            id_ex_reg_write <= 1'b0;
            id_ex_jal <= 1'b0;
            id_ex_jalr <= 1'b0;
            id_ex_auipc <= 1'b0;
            id_ex_lui <= 1'b0;
            id_ex_fp_alu_src <= 1'b0;
            id_ex_fp_load <= 1'b0;
            id_ex_fp_store <= 1'b0;
            id_ex_fmat_type <= FM_NONE;
            conv_data_read_id_ex <= 32'b0;
            weights_data_read_id_ex <= 32'b0;
            id_ex_alu_op <= 2'b0;
            id_ex_fp_op <= 2'b0;
            scalar_data_read1_id_ex <= 32'b0;
            scalar_data_read2_id_ex <= 32'b0;
            scalar_data_read3_id_ex <= 32'b0; 
            fp_data_read1_id_ex <= 32'b0;
            fp_data_read2_id_ex <= 32'b0;
            fp_data_read3_id_ex <= 32'b0;
            fp_data_read4_id_ex <= 32'b0; 
            vector_data_read1_id_ex <= '{default: 32'b0};
            vector_data_read2_id_ex <= '{default: 32'b0};
            vector_data_read3_id_ex <= '{default: 32'b0};
            big_immediate_id_ex <= 32'b0;
            reg_dest_id_ex <= 5'b0;
            reg3_id_ex <= 5'b0;
            reg2_id_ex <= 5'b0;
            reg1_id_ex <= 5'b0;
            funct3_id_ex <= 3'b0;
            funct7_id_ex <= 7'b0;

        end else if (!stall) begin

            pc_id_ex <= pc_if_id; 
            instruction_id_ex <= instruction_if_id;
            vec_op_id_ex <= vec_op;
            fp_instruction_id_ex <= fp_instruction;
            rd_is_int_id_ex <= rd_is_int;
            fp_reg_write_id_ex <= fp_reg_write;
            vec_reg_write_id_ex <= vec_reg_write;
            id_ex_continous_addr <= continous_addr;
            id_ex_single_load <= single_load;
            id_ex_branch <= branch;
            id_ex_beq <= beq;
            id_ex_bne <= bne;
            id_ex_blt <= blt;
            id_ex_bge <= bge;
            id_ex_mem_read <= mem_read;
            id_ex_memtoreg <= memtoreg;
            id_ex_mem_write <= mem_write;
            id_ex_alu_src <= alu_src;
            id_ex_reg_write <= reg_write;
            id_ex_jal <= jal;
            id_ex_jalr <= jalr;
            id_ex_auipc <= auipc;
            id_ex_lui <= lui;
            id_ex_fp_alu_src <= fp_alu_src;
            id_ex_fp_load <= fp_load;
            id_ex_fp_store <= fp_store;
            id_ex_fmat_type <= fmat_type;
            conv_data_read_id_ex <= conv_data_read;
            weights_data_read_id_ex <= weights_data_read;
            id_ex_alu_op <= alu_op;
            id_ex_fp_op <= fp_op;
            scalar_data_read1_id_ex <= scalar_data_read1;
            scalar_data_read2_id_ex <= scalar_data_read2;
            scalar_data_read3_id_ex <= scalar_data_read3;
            fp_data_read1_id_ex <= fp_data_read1;
            fp_data_read2_id_ex <= fp_data_read2;
            fp_data_read3_id_ex <= fp_data_read3;
            fp_data_read4_id_ex <= fp_data_read4;
            vector_data_read1_id_ex <= vector_data_read1;
            vector_data_read2_id_ex <= vector_data_read2;
            vector_data_read3_id_ex <= vector_data_read3;
            big_immediate_id_ex <= big_immediate;
            reg_dest_id_ex <= reg_dest;
            reg3_id_ex <= reg3;
            reg1_id_ex <= reg1;
            reg2_id_ex <= reg2;
            funct3_id_ex <= funct3;
            funct7_id_ex <= funct7;
        end
    end
endmodule