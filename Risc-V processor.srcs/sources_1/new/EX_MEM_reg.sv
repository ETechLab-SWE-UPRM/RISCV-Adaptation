
module EX_MEM_reg #(
    parameter vec_length = 2
) (
    input logic clk,
    input logic reset,
    input logic vec_op, 
    input logic id_ex_fp_instruction,
    input logic id_ex_fp_reg_write,
    input logic vec_reg_write,
    input logic id_ex_single_load,
    input logic id_ex_mem_read,
    input logic id_ex_mem_write,
    input logic id_ex_memtoreg,
    input logic id_ex_reg_write,
    input logic id_ex_jal,
    input logic id_ex_jalr,
    input logic [31:0] alu_result [0:vec_length-1],
    input logic [31:0] data_read2_id_ex,
    input logic [31:0] vec_data_read2_id_ex [0:vec_length-1], 
    input logic [4:0] reg_dest_id_ex,
    input logic [31:0] ex_link_address,
    input logic [2:0] funct3, 

    output logic ex_mem_vec_op,
    output logic ex_mem_fp_instruction,
    output logic ex_mem_fp_reg_write,
    output logic ex_mem_vec_reg_write,
    output logic ex_mem_single_load,
    output logic ex_mem_memread,
    output logic ex_mem_memwrite,
    output logic ex_mem_memtoreg,
    output logic ex_mem_regwrite,
    output logic ex_mem_jal,
    output logic ex_mem_jalr,
    output logic [31:0] ex_mem_alu_result [0:vec_length-1],
    output logic [31:0] ex_mem_data_read2,
    output logic [31:0] vec_ex_mem_data_read2 [0:vec_length-1],
    output logic [4:0] ex_mem_reg_dest,
    output logic [31:0] ex_mem_link_address_reg,
    output logic [2:0] ex_mem_funct3 

);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            ex_mem_vec_op <= 1'b0;
            ex_mem_fp_isntruction <= 1'b0;
            ex_mem_fp_instruction <= 1'b0;
            ex_mem_vec_reg_write <= 1'b0;
            ex_mem_single_load <= 1'b0;
            ex_mem_memread <= 1'b0;
            ex_mem_memwrite <= 1'b0;
            ex_mem_memtoreg <= 1'b0;
            ex_mem_regwrite <= 1'b0;
            ex_mem_jal <= 1'b0;
            ex_mem_jalr <= 1'b0;
            ex_mem_alu_result <= '{default: 32'b0};
            ex_mem_data_read2 <= 32'b0;
            vec_ex_mem_data_read2 <= '{default: 32'b0};
            ex_mem_reg_dest <= 5'b0;
            ex_mem_link_address_reg <= 32'b0;
            ex_mem_funct3 <= 3'b0; 

        end else begin
            ex_mem_vec_op <= vec_op; 
            ex_mem_fp_instruction <= id_ex_fp_instruction;
            ex_mem_fp_reg_write <= id_ex_fp_reg_write;
            ex_mem_vec_reg_write <= vec_reg_write;
            ex_mem_single_load <= id_ex_single_load;
            vec_ex_mem_data_read2 <= vec_data_read2_id_ex;
            ex_mem_memread <= id_ex_mem_read; 
            ex_mem_memwrite <= id_ex_mem_write; 
            ex_mem_memtoreg <= id_ex_memtoreg; 
            ex_mem_regwrite <= id_ex_reg_write; 
            ex_mem_jal <= id_ex_jal; 
            ex_mem_jalr <= id_ex_jalr; 
            ex_mem_alu_result <= alu_result; 
            ex_mem_data_read2 <= data_read2_id_ex;
            ex_mem_reg_dest <= reg_dest_id_ex; 
            ex_mem_link_address_reg <= ex_link_address;
            ex_mem_funct3 <= funct3; 

        end
    end
endmodule