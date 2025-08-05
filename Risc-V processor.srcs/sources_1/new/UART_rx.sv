
module UART_receiver #(
    parameter data_bits = 8,
    parameter stop_bit_tick = 16
) (
    input logic clk,
    input logic reset,
    input logic rx,
    input logic sample_tick,
    
    output logic [data_bits-1:0] data_out,
    output logic data_ready
);

    localparam idle = 2'b00, 
               start = 2'b01, 
               data = 2'b10, 
               stop = 2'b11;
    
    logic [1:0] state, next_state;
    logic [3:0] tick_reg, tick_next;
    logic [2:0] bit_reg, bit_next;
    logic [data_bits-1:0] data_reg, data_next;

    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            state <= idle;
            tick_reg <= 0;
            bit_reg <= 0;
            data_reg <= 0;
            data_ready <= 0;
        end else begin
            state <= next_state;
            tick_reg <= tick_next;
            bit_reg <= bit_next;
            data_reg <= data_next;
        end
    end

    always_comb begin 
        next_state = state;
        tick_next = tick_reg;
        bit_next = bit_reg;
        data_next = data_reg;
        data_ready = 0;

        case(state)
            idle: begin
                if(~rx) begin // Start detected
                    next_state = start;
                    tick_next = 0;
                end
            end
            
            start: begin
                if(tick_reg == 7) begin
                    next_state = data;
                    tick_next = 0;
                    bit_next = 0; 
                end else begin
                    tick_next = tick_reg + 1;
                end
            end
            
            data: begin
                if(sample_tick) begin
                    if(tick_reg == 15) begin
                        tick_next = 0;
                        data_next = {rx, data_reg[data_bits-1:1]}; 

                        if(bit_reg == (data_bits - 1)) begin
                            next_state = stop; 
                        end else begin
                            bit_next = bit_reg + 1; 
                        end
                    end else begin
                        tick_next = tick_reg + 1; 
                    end
                end
            end
            
            stop: begin
                if(sample_tick) begin
                    if(tick_reg == (stop_bit_tick - 1)) begin
                        next_state = idle;
                        data_ready = 1; 
                    end
                end else begin
                    tick_next = tick_reg + 1;
                end
            end
            
            default: next_state = idle;
            
        endcase
    end
    
    assign data_out = data_reg;

endmodule