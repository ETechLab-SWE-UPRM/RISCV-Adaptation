`timescale 1ns/1ps

module branch_predictor #(
    parameter BHT_SIZE = 256
) (
    input logic clk,
    input logic rst,
    input logic actual_branch_taken,
    input logic branch_calculated,
    input logic [31:0] pc,
    input logic [31:0] actual_target_pc,

    output logic [31:0] predicted_pc,
    output logic prediction_taken
);
    // Ceiling of log2(BHT_SIZE) = 8;
    localparam index_width = $clog2(BHT_SIZE);

    logic [1:0] bht [0:BHT_SIZE-1]; // 2-bit Branch History Table with BHT_SIZE entries
    logic [31:0] btb [0:BHT_SIZE-1]; // Branch Target Buffer
    logic valid [0:BHT_SIZE-1];
    logic [index_width-1:0] index;

    assign index = pc[index_width+1:2];

    always_comb begin
        if (valid[index] && bht[index][1]) begin
            prediction_taken = 1'b1;
            predicted_pc = btb[index];
        end else begin
            prediction_taken = 1'b0;
            predicted_pc = pc + 4;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < BHT_SIZE; i++) begin
                bht[i] <= 2'b01;
                valid[i] <= 1'b0;
                btb[i] <= 32'b0;
            end
        end else if (branch_calculated) begin

            if(actual_branch_taken && bht[index] != 2'b11) begin
               bht[index] <= bht[index] + 1;
            end else if (!actual_branch_taken && bht[index] != 2'b00) begin
                bht[index] <= bht[index] - 1;
            end

            if (actual_branch_taken) begin
                btb[index]   <= actual_target_pc;
                valid[index] <= 1'b1;
            end
        end
    end
endmodule