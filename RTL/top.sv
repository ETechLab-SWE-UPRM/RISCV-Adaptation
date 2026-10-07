`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UPRM
// Engineer: Fernando L. Pizarro Diaz
// 
// Create Date: 02/24/2026 10:08:49 PM
// Design Name: RVW_top
// Module Name: top
// Project Name: Risc-V Wearable
// Target Devices: Artix-7
// Tool Versions: Vivado 2024.2
// Description: top module for RVW CPU. Has the cpu and clock wizard.
//
// Dependencies: Read RVW dependencies
// 
// Revision: 
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top (
    input logic clk,
    input logic reset, 
    input logic rx, 
    input logic sclk,
    input logic cs_in,
    input logic mosi,

    output logic miso,
    output logic tx,
    output logic [6:0] seg, 
    output logic [3:0] an,
    output logic led
);
    logic locked;
    logic clk_out;

    clk_wiz_0 clk50 (
        .clk_in1(clk), 
        .reset(reset), 
        .locked(locked),
        .clk_out1(clk_out)
    );

    logic ext_reset;
    assign ext_reset = reset || !locked; 

    RISCV_WEARABLE RVW_CPU (
        .clk(clk_out),
        .reset(ext_reset),
        .rx(rx),
        .sclk(sclk),
        .cs_in(cs_in),
        .mosi(mosi),
        .miso(miso),
        .tx(tx),
        .seg(seg),
        .an(an),
        .led(led)
    );
    
endmodule
