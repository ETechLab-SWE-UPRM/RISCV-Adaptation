`timescale 1ns/1ps

module fp_forward (
    input logic [4:0] id_ex_rs1, id_ex_rs2, id_ex_rs3, id_ex_rs4,
    input logic [4:0] ex_mem_rd, mem_wb_rd,
    input logic ex_mem_reg_write, mem_wb_reg_write,
    input logic id_ex_fp_instruction, ex_mem_fp_instruction, mem_wb_fp_instruction,

    output logic [1:0] fp_forward_a, fp_forward_b, fp_forward_c, fp_forward_d
);

    logic ex_rs1_match, ex_rs2_match, ex_rs3_match, ex_rs4_match;
    logic mem_rs1_match, mem_rs2_match, mem_rs3_match, mem_rs4_match;

    always_comb begin
        fp_forward_a = 2'b00;
        fp_forward_b = 2'b00;
        fp_forward_c = 2'b00;
        fp_forward_d = 2'b00;

        // Precomputations
        ex_rs1_match = ((ex_mem_reg_write) && (id_ex_fp_instruction && ex_mem_fp_instruction) && (id_ex_rs1 == ex_mem_rd));
        ex_rs2_match = ((ex_mem_reg_write) && (id_ex_fp_instruction && ex_mem_fp_instruction) && (id_ex_rs2 == ex_mem_rd));
        ex_rs3_match = ((ex_mem_reg_write) && (id_ex_fp_instruction && ex_mem_fp_instruction) && (id_ex_rs3 == ex_mem_rd));
        ex_rs4_match = ((ex_mem_reg_write) && (id_ex_fp_instruction && ex_mem_fp_instruction) && (id_ex_rs4 == ex_mem_rd));

        mem_rs1_match = ((mem_wb_reg_write) && (id_ex_fp_instruction && mem_wb_fp_instruction) && (id_ex_rs1 == mem_wb_rd));
        mem_rs2_match = ((mem_wb_reg_write) && (id_ex_fp_instruction && mem_wb_fp_instruction) && (id_ex_rs2 == mem_wb_rd));
        mem_rs3_match = ((mem_wb_reg_write) && (id_ex_fp_instruction && mem_wb_fp_instruction) && (id_ex_rs3 == mem_wb_rd));
        mem_rs4_match = ((mem_wb_reg_write) && (id_ex_fp_instruction && mem_wb_fp_instruction) && (id_ex_rs4 == mem_wb_rd));

        // Forwarding assignments
        fp_forward_a = ex_rs1_match ? 2'b10 :
                    mem_rs1_match ? 2'b01 : 2'b00;
        
        fp_forward_b = ex_rs2_match ? 2'b10 :
                    mem_rs2_match ? 2'b01 : 2'b00;

        fp_forward_c = ex_rs3_match ? 2'b10 :
                    mem_rs3_match ? 2'b01 : 2'b00;            

        fp_forward_d = ex_rs4_match ? 2'b10 :
                    mem_rs4_match ? 2'b01 : 2'b00;
    end
endmodule