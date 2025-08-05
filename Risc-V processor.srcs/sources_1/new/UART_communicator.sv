`timescale 1ns/1ps

module UART #(
    parameter data_bits = 8,
    parameter stop_bit_tick = 16,
    // Baud rates  tested : 9600, 115200, 19200, 1500
    // 9600 currently used
    parameter baud_limit = 651,
    parameter baud_bits = 10,
    parameter FIFO_exp = 2 // exponent for FIFO size, 2^2 = 4 data words

) (
    input logic clk,
    input logic reset,
    input logic read,  // button
    input logic write, // button
    input logic rx,    // serial data input
    input logic [data_bits-1:0] write_data,
    
    output logic tx,   // serial data output
    output logic rx_full,
    output logic rx_empty, 
    output logic [data_bits-1:0] read_data
);

    logic tick;
    logic rx_done_tick, tx_done_tick;
    logic tx_empty, tx_fifo_not_empty;
    logic [data_bits-1:0] tx_fifo_out;
    logic [data_bits-1:0] rx_data_out;

    baud_rate_generator #(
        .counter(baud_bits),
        .counter_limit(baud_limit)
    ) baud_gen_unit (
        .clk(clk),
        .reset(reset),
        .tick(tick)
    );

    UART_receiver #(
        .data_bits(data_bits),
        .stop_bit_tick(stop_bit_tick)
    ) uart_rx_unit (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .sample_tick(tick),
        .data_out(rx_data_out),
        .data_ready(rx_done_tick)
    );

    UART_transmitter #(
        .data_bits(data_bits),
        .stop_bit_tick(stop_bit_tick)
    ) uart_tx_unit (
        .clk(clk),
        .reset(reset),
        .tx(tx),
        .data_in(tx_fifo_out),
        .tx_done(tx_done_tick)
    );

    FIFO #(
        .data_size(data_bits),
        .FIFO_exp(FIFO_exp)
    ) tx_fifo (
        .clk(clk),
        .reset(reset),
        .write_to_fifo(write),
        .read_from_fifo(tx_done_tick),
        .write_data_in(write_data),
        .read_data_out(tx_fifo_out),
        .empty(tx_empty),
        .full()
    );

    FIFO #(
        .data_size(data_bits),
        .FIFO_exp(FIFO_exp)
    ) rx_fifo (
        .clk(clk),
        .reset(reset),
        .write_to_fifo(rx_done_tick),
        .read_from_fifo(read),
        .write_data_in(rx_data_out),
        .read_data_out(read_data),
        .empty(rx_empty),
        .full(rx_full)
    );

    assign tx_fifo_not_empty = ~tx_empty;

endmodule