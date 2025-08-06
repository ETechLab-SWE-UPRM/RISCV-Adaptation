`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Reference Book: FPGA Prototyping By Verilog Examples Xilinx Spartan-3 Version
// Authored by: Dr. Pong P. Chu
// Published by: Wiley
//
// Adapted for the Basys 3 Artix-7 FPGA by David J. Marion
//
// UART System Verification Circuit
//
// Comments:
// - Many of the variable names have been changed for clarity
//////////////////////////////////////////////////////////////////////////////////

module uart_test(
    input clk,       // basys 3 FPGA clock signal
    input reset,            // btnR    
    input rx,               // USB-RS232 Rx
    input btn,              // btnL (read and write FIFO operation)
    output tx,              // USB-RS232 Tx
    output [3:0] an,        // 7 segment display digits
    output [0:6] seg,       // 7 segment display segments
    output [7:0] led2,       // data byte display
    output led3
    );
    
    // Connection Signals
    wire rx_full, rx_empty, btn_tick;
    wire [7:0] rec_data, rec_data1;
   
    // Complete UART Core
    uart_top UART_UNIT
        (
            .clk_100MHz(clk),
            .reset(reset),
            .read_uart(btn_tick),
            .write_uart(btn_tick),
            .rx(rx),
            .write_data(rec_data1),
            .rx_full(rx_full),
            .rx_empty(rx_empty),
            .read_data(rec_data),
            .tx(tx)
        );
    
    // Button Debouncer
    debounce_explicit BUTTON_DEBOUNCER
        (
            .clk_100MHz(clk),
            .reset(reset),
            .btn(btn),         
            .db_level(),  
            .db_tick(btn_tick)
        );
    
    // Signal Logic    
    assign rec_data1 = rec_data + 1;    // add 1 to ascii value of received data (to transmit)
    
    // Output Logic
    assign led2 = rec_data;              // data byte received displayed on LEDs
    assign an = 4'b1110;                // using only one 7 segment digit 
    assign seg = {~rx_full, 2'b11, ~rx_empty, 3'b111};
    assign led3 = btn;
endmodule