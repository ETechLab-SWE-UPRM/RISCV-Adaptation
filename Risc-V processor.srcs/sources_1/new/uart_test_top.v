`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Reference Book: FPGA Prototyping By Verilog Examples Xilinx Spartan-3 Version
// Authored by: Dr. Pong P. Chu
// Published by: Wiley
//
//
//
// UART System Verification Circuit
//
// Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module uart_test_top(
    input clk,       // basys 3 FPGA clock signal
    input reset,            // btnR    
    input rx,               // USB-RS232 Rx
    input btn,              // btnL (read and write FIFO operation)

    output tx,              // USB-RS232 Tx
    output [3:0] an,        // 7 segment display digits
    output [0:6] seg,       // 7 segment display segments
    output [7:0] led2,       // data byte display
    output led3,
    output led4
);
    wire clk_out, locked;

    clk_wiz_0 clk50 (
        .clk_in1(clk), 
        .reset(reset), 
        .locked(locked),
        .clk_out1(clk_out)
    );

    wire reset_ext;
    assign reset_ext = reset || !locked;

    uart_test test_module (
        .clk(clk_out),
        .reset(reset_ext),
        .rx(rx),
        .btn(btn),
        .tx(tx),
        .an(an),
        .seg(seg),
        .led2(led2),
        .led3(led3),
        .led4(led4)
    );
endmodule