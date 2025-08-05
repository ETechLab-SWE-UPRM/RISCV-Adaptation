
module UART_transmitter #(
    parameter data_bits = 8,
    parameter stop_bit_tick = 16
) (
    input logic clk, 
    input logic reset,
    input logic tx_start,
    input logic sample_tick,
    input logic [data_bits-1:0] data_in,

    output logic tx_done,
    output logic tx
);

    localparam [1:0] idle = 2'b00, 
                    start = 2'b01, 
                    data = 2'b10, 
                    stop = 2'b11;

    logic [1:0] state, next_state;
    logic [3:0] tick_reg, tick_next;
    logic [2:0] bit_reg, bit_next;
    logic [data_bits-1:0] data_reg, data_next;
    logic tx_reg, tx_next;

    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            state <= idle;
            tick_reg <= 0;
            bit_reg <= 0;
            data_reg <= 0;
            tx_reg <= 1; 
        end else begin
            state <= next_state;
            tick_reg <= tick_next;
            bit_reg <= bit_next;
            tx_reg <= tx_next;
        end
    end

    always_comb begin
        next_state = state;
        tick_next = tick_reg;
        bit_next = bit_reg;
        data_next = data_reg;
        tx_next = tx_reg;
        tx_done = 1'b0;

        case(state)
            idle: begin
                tx_next = 1'b1;
                if(tx_start) begin
                    next_state = start;
                    tick_next = 0;
                    data_next = data_in; // Load data to transmit
                end
            end
            
            start: begin
                tx_next = 1'b0;
                if(sample_tick) begin
                    if(tick_reg == 15) begin
                        next_state = data;
                        tick_next = 0;
                        bit_next = 0;
                    end else begin
                        tick_next = tick_reg + 1;
                    end
                end
            end
            
            data: begin
                tx_next = data_reg[0];
                if(sample_tick) begin
                    if(tick_reg == 15) begin
                        tick_next = 0;
                        data_next = data_reg >> 1; 
                        if(bit_reg == data_bits - 1) begin
                            next_state = stop; 
                        end else begin
                            bit_next = bit_reg + 1;
                        end
                    end
                end else begin
                    tick_next = tick_reg + 1;
                end
            end
            
            stop: begin
                tx_next = 1'b1;
                if(sample_tick) begin
                    if(tick_reg == stop_bit_tick) begin
                        next_state = idle;
                        tx_done = 1'b1;
                    end
                end else begin
                    tick_next = tick_reg + 1;
                end
            end
            
            default: next_state = idle; // Fallback to idle state on unexpected state
        endcase
    end

    assign tx = tx_reg; 

endmodule