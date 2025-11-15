`timescale 1ns / 1ps

module ProgramCounter(
    input logic clk,
    input logic reset,
    input logic pc_write,
    input logic [31:0] next_pc,
    output logic [31:0] pc    
);

    always_ff @(posedge clk) begin
        if (reset) begin
            pc <= 32'b0; // Reset PC to 0
        end  else if (pc_write) begin
            pc <= next_pc; // Update PC with next_pc
        end else begin
            pc <= pc;
        end
    end
endmodule
