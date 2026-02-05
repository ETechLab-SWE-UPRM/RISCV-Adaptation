import fp_fma_pkg::*;

module MEM1_MEM2 #(
    parameter vec_length = 2
) (
    input logic clk, 
    input logic reset,
    input logic ex_mem_vec_op,
    input logic ex_mem_fp_instruction,
    input logic ex_mem_fp_reg_write,
    input logic ex_mem_vec_reg_write,
    input logic ex_mem_single_load,
    input logic ex_mem_memread,
    input logic ex_mem_memwrite,
    input logic ex_mem_memtoreg,
    input logic ex_mem_regwrite,
    input logic ex_mem_jal,
    input logic ex_mem_jalr,
    input logic override_data_read,
    input logic [31:0] uart_memory [0:vec_length-1],
    input fp_fma_t ex_mem_fmat_type,
    input logic [31:0] ex_mem_conv_data_read,
    input logic [31:0] ex_mem_weights_data_read,
    input logic [31:0] ex_mem_fp_mac_1,
    input logic [31:0] ex_mem_fp_mac_2,
    input logic [31:0] ex_mem_alu_result [0:vec_length-1],
    input logic [4:0] ex_mem_rs1,
    input logic [4:0] ex_mem_rs2,
    input logic [4:0] ex_mem_reg_dest,
    input logic [31:0] ex_mem_link_address_reg,

    output logic ex_mem_vec_op_2,
    output logic ex_mem_fp_instruction_2,
    output logic ex_mem_fp_reg_write_2,
    output logic ex_mem_vec_reg_write_2,
    output logic ex_mem_single_load_2,
    output logic ex_mem_memread_2,
    output logic ex_mem_memwrite_2,
    output logic ex_mem_memtoreg_2,
    output logic ex_mem_regwrite_2,
    output logic ex_mem_jal_2,
    output logic ex_mem_jalr_2,
    output logic override_data_read_2,
    output logic [31:0] uart_memory_2 [0:vec_length-1],
    output fp_fma_t ex_mem_fmat_type_2,
    output logic [31:0] ex_mem_conv_data_read_2,
    output logic [31:0] ex_mem_weights_data_read_2,
    output logic [31:0] ex_mem_fp_mac_1_2,
    output logic [31:0] ex_mem_fp_mac_2_2,
    output logic [31:0] ex_mem_alu_result_2 [0:vec_length-1],
    output logic [4:0] ex_mem_rs1_2,
    output logic [4:0] ex_mem_rs2_2,
    output logic [4:0] ex_mem_reg_dest_2,
    output logic [31:0] ex_mem_link_address_reg_2
);

    always_ff @(posedge clk) begin
        if (reset) begin
            ex_mem_vec_op_2 <= 1'b0;
            ex_mem_fp_instruction_2 <= 1'b0;
            ex_mem_fp_reg_write_2 <= 1'b0;
            ex_mem_vec_reg_write_2 <= 1'b0;
            ex_mem_single_load_2 <= 1'b0;
            ex_mem_memread_2 <= 1'b0;
            ex_mem_memwrite_2 <= 1'b0;
            ex_mem_memtoreg_2 <= 1'b0;
            ex_mem_regwrite_2 <= 1'b0;
            ex_mem_jal_2 <= 1'b0;
            ex_mem_jalr_2 <= 1'b0;
            override_data_read_2 <= 1'b0;
            uart_memory_2 <= '{default: 32'b0};
            ex_mem_fmat_type_2 <= FM_NONE;
            ex_mem_conv_data_read_2 <= 32'b0;
            ex_mem_weights_data_read_2 <= 32'b0;
            ex_mem_fp_mac_1_2 <= 32'b0;
            ex_mem_fp_mac_2_2 <= 32'b0;
            ex_mem_alu_result_2 <= '{default: 32'b0};
            ex_mem_rs1_2 <= 5'b0;
            ex_mem_rs2_2 <= 5'b0;
            ex_mem_reg_dest_2 <= 5'b0;
            ex_mem_link_address_reg_2 <= 32'b0;

        end else begin
            ex_mem_vec_op_2 <= ex_mem_vec_op;
            ex_mem_fp_instruction_2 <= ex_mem_fp_instruction;
            ex_mem_fp_reg_write_2 <= ex_mem_fp_reg_write;
            ex_mem_vec_reg_write_2 <= ex_mem_vec_reg_write;
            ex_mem_single_load_2 <= ex_mem_single_load;
            ex_mem_memread_2 <= ex_mem_memread;
            ex_mem_memwrite_2 <= ex_mem_memwrite;
            ex_mem_memtoreg_2 <= ex_mem_memtoreg;
            ex_mem_regwrite_2 <= ex_mem_regwrite;
            ex_mem_jal_2 <= ex_mem_jal;
            ex_mem_jalr_2 <= ex_mem_jalr;
            override_data_read_2 <= override_data_read;
            uart_memory_2 <= uart_memory;
            ex_mem_fmat_type_2 <= ex_mem_fmat_type;
            ex_mem_conv_data_read_2 <= ex_mem_conv_data_read;
            ex_mem_weights_data_read_2 <= ex_mem_weights_data_read;
            ex_mem_fp_mac_1_2 <= ex_mem_fp_mac_1;
            ex_mem_fp_mac_2_2 <= ex_mem_fp_mac_2;
            ex_mem_alu_result_2 <= ex_mem_alu_result;
            ex_mem_rs1_2 <= ex_mem_rs1;
            ex_mem_rs2_2 <= ex_mem_rs2;
            ex_mem_reg_dest_2 <= ex_mem_reg_dest;
            ex_mem_link_address_reg_2 <= ex_mem_link_address_reg;
        end
    end
endmodule