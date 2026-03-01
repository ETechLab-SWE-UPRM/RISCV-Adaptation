`timescale 1ns/1ps

module fp_forward_testing ();
    
    logic clk, reset;
    logic [4:0] id_ex_rs1, id_ex_rs2, id_ex_rs3, id_ex_rs4;
    logic [4:0] ex_mem_rd, mem_wb_rd;
    logic ex_mem_reg_write, mem_wb_reg_write;
    logic id_ex_fp_instruction, ex_mem_fp_instruction, mem_wb_fp_instruction;
    logic [1:0] fp_forward_a, fp_forward_b, fp_forward_c, fp_forward_d;

    fp_forward uut (
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .id_ex_rs3(id_ex_rs3),
        .id_ex_rs4(id_ex_rs4),
        .ex_mem_rd(ex_mem_rd),
        .mem_wb_rd(mem_wb_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_reg_write(mem_wb_reg_write),
        .id_ex_fp_instruction(id_ex_fp_instruction),
        .ex_mem_fp_instruction(ex_mem_fp_instruction),
        .mem_wb_fp_instruction(mem_wb_fp_instruction),
        
        .fp_forward_a(fp_forward_a),
        .fp_forward_b(fp_forward_b),
        .fp_forward_c(fp_forward_c),
        .fp_forward_d(fp_forward_d)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        id_ex_rs1 = 5'd1;
        id_ex_rs2 = 5'd2;
        id_ex_rs3 = 5'd3;
        id_ex_rs4 = 5'd4;

        ex_mem_rd = 5'd1;
        ex_mem_reg_write = 1;

        mem_wb_rd = 5'd0;
        mem_wb_reg_write = 1;
        
        id_ex_fp_instruction = 1;
        ex_mem_fp_instruction = 1;
        mem_wb_fp_instruction = 1;
        #20;
        id_ex_fp_instruction = 0;
        #20;
        ex_mem_fp_instruction = 0;

        $finish;
    end
endmodule