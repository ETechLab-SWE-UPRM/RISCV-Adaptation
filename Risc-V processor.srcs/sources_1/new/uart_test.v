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
    (*MARK_DEBUG = "TRUE" *) wire [7:0] rec_data;
    (*MARK_DEBUG = "TRUE" *) reg [7:0] tx_data;
    reg [27:0] led_timer;
    (*MARK_DEBUG = "TRUE" *) reg write_counter;
    (*MARK_DEBUG = "TRUE" *) reg data_word_complete;
    (*MARK_DEBUG = "TRUE" *) reg tx_send_byte;
    reg [1:0] data_place;
    reg [1:0] data_send;
    (* MARK_DEBUG = "TRUE" *) reg [31:0] uart_data;

    // Complete UART Core
    uart_top #(
        .DBITS(8),          // number of data bits in a word
        .SB_TICK(16),       // number of stop bit / oversampling ticks
        .BR_LIMIT(54),     // baud rate generator counter limit
        .BR_BITS(6),       // number of baud rate generator counter bits
        .FIFO_EXP(2) 
    ) UART_UNIT (
            .clk_100MHz(clk),
            .reset(reset),
            .read_uart(write_counter),
            .write_uart(tx_send_byte),
            .rx(rx),
            .write_data(tx_data),
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

    always @(posedge clk) begin
        if(reset) begin
            led_timer <= 28'b0;
        end else if(rx_full) begin
            led_timer <= 28'd200_000_000;
        end else if(led_timer > 0) begin
            led_timer <= led_timer - 1;
        end
    end

    always @(posedge clk) begin
        if(reset) begin
            write_counter <= 1'b0;
        end else if(rx_full) begin
            write_counter <= 1'b1;
        end else if(rx_empty) begin
            write_counter <= 1'b0;
        end
    end

    always @(posedge clk )begin
        if(tx_send_byte) begin
            tx_send_byte <= 1'b0;
        end else if(data_word_complete) begin
            case (data_send)
                2'b00: begin
                    tx_data <= uart_data[7:0];
                    tx_send_byte <= 1'b1;
                end
                2'b01: begin
                    tx_data <= uart_data[15:8];
                    tx_send_byte <= 1'b1;
                end
                2'b10: begin
                    tx_data <= uart_data[23:16];
                    tx_send_byte <= 1'b1;
                end
                2'b11: begin
                    tx_data <= uart_data[31:24];
                    tx_send_byte <= 1'b1;
                    data_word_complete <= 1'b0;
                end
                default: ;
            endcase
            data_send <= data_send + 1'b1;
        end else if(write_counter) begin
            case (data_place)
                2'b00: uart_data[7:0] <= rec_data;
                2'b01: uart_data[15:8] <= rec_data;
                2'b10: uart_data[23:16] <= rec_data;
                2'b11: begin
                    uart_data[31:24] <= rec_data;
                    data_word_complete <= 1'b1;
                end
                default: ;
            endcase
            data_place <= data_place + 1'b1;
        end
    end
    
    // Output Logic
    assign led2 = rec_data;              // data byte received displayed on LEDs
    assign an = 4'b1110;                // using only one 7 segment digit 
    assign seg = {~rx_full, 2'b11, ~rx_empty, 3'b111};
    assign led3 = btn;
    assign led4 = (led_timer > 0);
endmodule