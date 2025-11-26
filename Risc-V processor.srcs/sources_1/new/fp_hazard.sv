`timescale 1ns/1ps

module fp_hazard_detection #(
    parameter fp_adder_delay = 3
) (
    input logic clk,
    input logic reset,
    input logic ex_mem_fmadd,
    input logic fp_result_valid,
    input logic id_ex_fmadd,
    input logic id_ex_adder,
    input logic [4:0] if_id_rs1, if_id_rs2, if_id_rs3,
    input logic [4:0] reg_dest_id_ex,
    input logic id_ex_mem_read,
    input logic fp_fmadd_result_valid,
    input logic fp_adder_result_valid,

    output logic mac_stall,
    output logic stall, pc_write, if_id_write
);

    logic hazard1, hazard2, hazard3;
    logic previous_fp_stall;
    logic [1:0] delay_counter;

    assign hazard1 = (id_ex_mem_read && (if_id_rs1 == reg_dest_id_ex));
    assign hazard2 = (id_ex_mem_read && (if_id_rs2 == reg_dest_id_ex));
    assign hazard3 = (id_ex_mem_read && (if_id_rs3 == reg_dest_id_ex));
    // MAC hazards 

    always_ff @(posedge clk) begin
        if(reset) begin
            delay_counter <= 2'd0;
        end else begin
            if (ex_mem_fmadd && !previous_fp_stall) begin
                delay_counter <= fp_adder_delay;
                previous_fp_stall <= 1'b1;
            end else if (delay_counter != 0) begin
                delay_counter <= delay_counter - 2'd1;
            end else begin
                previous_fp_stall <= 1'b0;
            end
        end
    end

    always_comb begin
        stall = 1'b0; 
        mac_stall = 1'b0;
        pc_write = 1'b1; 
        if_id_write = 1'b1;

        if((ex_mem_fmadd && !previous_fp_stall && !fp_result_valid) || (delay_counter != 0)) begin
            mac_stall = 1'b1;
            pc_write = 1'b0;
            if_id_write = 1'b0;
        end else if(hazard1 || hazard2 || hazard3) begin
            stall = 1'b1;
            pc_write = 1'b0;
            if_id_write = 1'b0;
        end
    end
endmodule