`timescale 1ns/1ps

module fp_hazard_detection #(
    parameter FMADD_CYCLES = 7,
    parameter ADDER_CYCLES = 3
) (
    input logic clk,
    input logic reset,
    input logic id_ex_busy,
    input logic id_ex_fmadd,
    input logic id_ex_adder,
    input logic [4:0] if_id_rs1, if_id_rs2, if_id_rs3,
    input logic [4:0] reg_dest_id_ex,
    input logic id_ex_mem_read,
    input logic fp_fmadd_result_valid,
    input logic fp_adder_result_valid,

    output logic stall, pc_write, if_id_write
);

    // Check if any FP register is being executed
    logic [3:0] busy [31:0]; 
    logic hazard1, hazard2;
    logic fp_hazard1, fp_hazard2, fp_hazard3;

    assign hazard1 = (id_ex_mem_read && (if_id_rs1 == reg_dest_id_ex));
    assign hazard2 = (id_ex_mem_read && (if_id_rs2 == reg_dest_id_ex));

    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            for(int i = 0; i < 32; i++) begin
                busy[i] <= 1'b0;
            end
        end else begin
            for(int i = 0; i < 32; i++) begin
                if(busy[i] > '0) begin
                    busy[i] <= busy[i] - 1;
                end
            end

            if(id_ex_busy && busy[reg_dest_id_ex] == 0) begin
                if(id_ex_fmadd) begin
                    busy[reg_dest_id_ex] <= FMADD_CYCLES;
                end else begin
                    busy[reg_dest_id_ex] <= ADDER_CYCLES;
                end
            end
        end
    end

    always_comb begin
        stall = 1'b1; 
        pc_write = 1'b0; 
        if_id_write = 1'b0;
        
        if(hazard1 || hazard2 || fp_hazard1 || fp_hazard2 || fp_hazard3) begin
            stall = 1'b1; 
            pc_write = 1'b0; 
            if_id_write = 1'b0; 
        end
    
        fp_hazard1 = (busy[if_id_rs1] > 0);
        fp_hazard2 = (busy[if_id_rs2] > 0);
        fp_hazard3 = (busy[if_id_rs3] > 0);
    end
endmodule