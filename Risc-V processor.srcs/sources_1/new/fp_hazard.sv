`timescale 1ns/1ps

module fp_hazard_detection (
    input logic clk,
    input logic reset,
    input logic id_ex_fmadd,
    input logic id_ex_adder,
    input logic [4:0] if_id_rs1, if_id_rs2, if_id_rs3,
    input logic [4:0] reg_dest_id_ex,
    input logic id_ex_mem_read,
    input logic fp_fmadd_result_valid,
    input logic fp_adder_result_valid,

    output logic stall, pc_write, if_id_write
);

    logic hazard1, hazard2, hazard3;
    logic fp_hazard1, fp_hazard2, fp_hazard3;

    assign hazard1 = (id_ex_mem_read && (if_id_rs1 == reg_dest_id_ex));
    assign hazard2 = (id_ex_mem_read && (if_id_rs2 == reg_dest_id_ex));
    assign hazard3 = (id_ex_mem_read && (if_id_rs3 == reg_dest_id_ex));
    // MAC hazards 
    assign fp_hazard1 = ((id_ex_fmadd) && (if_id_rs1 == reg_dest_id_ex));
    assign fp_hazard2 = ((id_ex_fmadd) && (if_id_rs2 == reg_dest_id_ex));
    assign fp_hazard3 = ((id_ex_fmadd) && (if_id_rs3 == reg_dest_id_ex));

    always_comb begin
        stall = 1'b0; 
        pc_write = 1'b1; 
        if_id_write = 1'b1;

        if(hazard1 || hazard2 || hazard3 || fp_hazard1 || fp_hazard2 || fp_hazard3) begin
            stall = 1'b1;
            pc_write = 1'b0;
            if_id_write = 1'b0;
        end
    end
endmodule