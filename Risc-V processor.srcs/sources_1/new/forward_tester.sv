`timescale 1ns / 1ps

module forward_tester();

    logic clk;
    logic [4:0] id_ex_rs1, id_ex_rs2, id_ex_rs3;
    logic [4:0] ex_mem_rd, mem_wb_rd;
    logic ex_mem_reg_write, mem_wb_reg_write;
    logic ex_mem_vec_op, mem_wb_vec_op;
    logic vec_op;
    logic [1:0] forward_a, forward_b, forward_c;

    Forward f_test (
        .id_ex_rs1(id_ex_rs1),
        .id_ex_rs2(id_ex_rs2),
        .id_ex_rs3(id_ex_rs3),
        .ex_mem_rd(ex_mem_rd),
        .mem_wb_rd(mem_wb_rd),
        .ex_mem_reg_write(ex_mem_reg_write),
        .mem_wb_reg_write(mem_wb_reg_write),
        .vec_op(vec_op),
        .ex_mem_vec_op(ex_mem_vec_op),
        .mem_wb_vec_op(mem_wb_vec_op),
        .forward_a(forward_a),
        .forward_b(forward_b),
        .forward_c(forward_c)
    );

    initial clk = 0; 
    always #5 clk = ~clk;

    initial begin
        id_ex_rs1 = 5'b00001;
        id_ex_rs2 = 5'b00010;
        id_ex_rs3 = 5'b00011;

        ex_mem_rd = 5'b00001;
        ex_mem_reg_write = 1;

        mem_wb_rd = 5'b0;
        mem_wb_reg_write = 1;
        vec_op = 1;
        ex_mem_vec_op = 1;
        mem_wb_vec_op = 1;
        #20;

        vec_op = 0;
        #20;

        ex_mem_vec_op = 0;

        $finish;
    end

endmodule