`timescale 1ns/1ps

module uart_word_creator #(
    parameter   DBITS = 8,
                SB_TICK = 16,
                BR_LIMIT = 651,
                BR_BITS = 10,
                FIFO_EXP = 2
) (
    input logic clk,
    input logic reset,
    input logic rx,

    output logic tx,
    output logic [DBITS-1:0] data_out
);
    
endmodule