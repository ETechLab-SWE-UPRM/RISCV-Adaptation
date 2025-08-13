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
    output led3,
    output led4
    );
    
    // Connection Signals
    wire rx_full, rx_empty, btn_tick;
    wire [7:0] rec_data;
    wire rx_word_valid; 
    reg [27:0] led_timer;
    reg write_counter;
   
    // Complete UART Core
    uart_top UART_UNIT
        (
            .clk_100MHz(clk),
            .reset(reset),
            .read_uart(write_counter),
            .write_uart(write_counter),
            .rx(rx),
            .write_data(rec_data),
            .rx_full(rx_full),
            .rx_empty(rx_empty),
            .rx_word_valid(rx_word_valid),
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

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            led_timer <= 28'b0;
        end else if(rx_word_valid) begin
            led_timer <= 28'd200_000_000;
        end else if(led_timer > 0) begin
            led_timer <= led_timer - 1;
        end
    end

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            write_counter <= 4'b0;
        end else if(rx_word_valid) begin
            write_counter <= 1'b1;
        end else if(rx_empty) begin
            write_counter <= 1'b0;
        end
    end
    
    // Output Logic
    assign led2 = rec_data;              // data byte received displayed on LEDs
    assign an = 4'b1110;                // using only one 7 segment digit 
    assign seg = {~rx_full, 2'b11, ~rx_empty, 3'b111};
    assign led3 = btn;
    assign led4 = (led_timer > 0);
endmodule