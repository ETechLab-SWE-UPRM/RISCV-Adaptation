`timescale 1ns/1ps

module fp_hazard_detection #(
    parameter fp_adder_delay = 3,
    parameter fp_multiplier_delay = 1
) (
    input logic clk,
    input logic reset,
    input logic fp_mac_result_valid,
    input logic [4:0] if_id_rs1, if_id_rs2, if_id_rs3,
    input logic [4:0] reg_dest_id_ex,
    input logic [4:0] id_ex_rs2,
    input logic [4:0] fp_mac_reg_dest,
    input logic fp_mac_finished,
    input logic id_ex_mem_read,
    input logic id_ex_mem_write,
    input logic fp_adder_result_valid,

    output logic mac_stall,
    output logic stall, pc_write, if_id_write
);

    logic hazard1, hazard2, hazard3;
    logic previous_fp_stall;
    logic mac_in_progress;
    logic mac_hazard;
    logic [1:0] delay_counter;

    assign hazard1 = (id_ex_mem_read && (if_id_rs1 == reg_dest_id_ex));
    assign hazard2 = (id_ex_mem_read && (if_id_rs2 == reg_dest_id_ex));
    assign hazard3 = (id_ex_mem_read && (if_id_rs3 == reg_dest_id_ex));
    // MAC hazards 
    assign mac_hazard = (mac_in_progress && id_ex_mem_write && (id_ex_rs2 == fp_mac_reg_dest));

    always_ff @(posedge clk) begin
        if (reset) begin
            mac_in_progress <= 1'b0;
        end else begin
            if (fp_mac_result_valid) begin
                mac_in_progress <= 1'b1;
            end else if (fp_mac_finished) begin
                mac_in_progress <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk) begin
        if(reset) begin
            delay_counter <= 2'd0;
        end else begin
            if (mac_hazard) begin
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

        if(mac_hazard && !previous_fp_stall || (delay_counter != 0)) begin
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