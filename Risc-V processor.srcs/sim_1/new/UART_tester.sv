`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/05/2025 11:04:17 AM
// Design Name: 
// Module Name: UART_tester
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module UART_tester(
    input logic clk,
    input logic reset,
    input logic rx,
    input logic btn, 

    output logic tx, 
    output logic [3:0] an,
    output logic [0:6] seg,
    output logic [7:0] led2
);

    logic [7:0] rec_data, rec_data1;
    logic rx_full, rx_empty, btn_tick;

    UART uart_inst (
        .clk(clk),
        .reset(reset),
        .read(btn_tick),
        .write(btn_tick),
        .rx(rx),
        .write_data(rec_data1),
        .tx(tx),
        .rx_full(rx_full),
        .rx_empty(rx_empty),
        .read_data(rec_data)
    );

    assign rec_data1 = rec_data + 1; // Increment data to send

    button_debouncer btn_deb (
        .clk(clk),
        .reset(reset),
        .btn(btn),
        .btn_level(),
        .btn_tick(btn_tick)
    );

    assign led2 = rec_data;
    assign an = 4'b1110;
    assign seg = {~rx_full, 2'b11, ~rx_empty, 3'b111};

endmodule
