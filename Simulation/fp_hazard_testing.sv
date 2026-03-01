`timescale 1ns/1ps

module fp_hazard_testing ();
    
    logic clk, reset;
    logic id_ex_busy, id_ex_fmadd, id_ex_adder;
    logic [4:0] if_id_rs1, if_id_rs2, if_id_rs3;
    logic [4:0] reg_dest_id_ex;
    logic id_ex_mem_read;
    logic fp_fmadd_result_valid, fp_adder_result_valid;
    logic stall, pc_write, if_id_write;

    fp_hazard_detection hazard_unit (
        .clk(clk),
        .reset(reset),
        .id_ex_busy(id_ex_busy),
        .id_ex_fmadd(id_ex_fmadd),
        .id_ex_adder(id_ex_adder),
        .if_id_rs1(if_id_rs1),
        .if_id_rs2(if_id_rs2),
        .if_id_rs3(if_id_rs3),
        .reg_dest_id_ex(reg_dest_id_ex),
        .id_ex_mem_read(id_ex_mem_read),
        .fp_fmadd_result_valid(fp_fmadd_result_valid),
        .fp_adder_result_valid(fp_adder_result_valid),

        .stall(stall),
        .pc_write(pc_write),
        .if_id_write(if_id_write)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 1;
        id_ex_busy = 0;
        id_ex_fmadd = 0;
        id_ex_adder = 0;
        if_id_rs1 = 5'd1;
        if_id_rs2 = 5'd2;
        if_id_rs3 = 5'd3;
        reg_dest_id_ex = 5'd0;
        id_ex_mem_read = 0;
        fp_fmadd_result_valid = 0;
        fp_adder_result_valid = 0;

        #20;

        reset = 0;
        id_ex_busy = 1;
        id_ex_fmadd = 1;
        reg_dest_id_ex = 5'd1; // rs1 hazard

        #70;

        id_ex_fmadd = 0;
        id_ex_adder = 1;
        reg_dest_id_ex = 5'd2; // rs2 hazard

        #40;

        $finish;
    end
endmodule