`timescale 1ns/1ps

module Timer (
    input logic clk,
    input logic reset,

    output logic [31:0] timer_value
);

    always_ff @(posedge clk) begin
        if (reset) begin
            timer_value <= 0;
        end else begin
            timer_value <= timer_value + 1;
        end
    end
endmodule