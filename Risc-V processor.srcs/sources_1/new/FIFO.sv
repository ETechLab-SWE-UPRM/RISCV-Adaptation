
module FIFO #(
    parameter data_size = 8,
    parameter FIFO_exp = 4 // 2^4 = 16 data words
) (
    input logic clk, 
    input logic reset, 
    input logic write_to_fifo, 
    input logic read_from_fifo,
    input logic [data_size-1:0] write_data_in,

    output logic [data_size-1:0] read_data_out,
    output logic empty, 
    output logic full 
);

    logic [data_size-1:0] fifo_mem [2**FIFO_exp-1:0];
    logic [FIFO_exp-1:0] current_write_addr, current_write_addr_buffr, next_write_addr;
    logic [FIFO_exp-1:0] current_read_addr, current_read_addr_buffr, next_read_addr;
    logic fifo_full, fifo_empty, full_buff, empty_buff;
    logic write_enabled; 

    always_ff @(posedge clk or posedge reset) begin
        if(write_enabled) begin
            fifo_mem[current_write_addr] <= write_data_in;
        end

        if(reset) begin
            current_write_addr <= 0;
            current_read_addr <= 0;
            fifo_full <= 1'b0;
            fifo_empty <= 1'b1;
        end else begin
            current_write_addr <= current_write_addr_buffr;
            current_read_addr <= current_read_addr_buffr;
            fifo_full <= full_buff;
            fifo_empty <= empty_buff;
        end
    end

    assign read_data_out = fifo_mem[current_read_addr];
    assign write_enabled = write_to_fifo && ~fifo_full;

    always_comb begin
        next_write_addr = current_write_addr;
        next_read_addr = current_read_addr;
        full_buff = fifo_full;
        empty_buff = fifo_empty;

        case ({write_to_fifo, read_from_fifo})
            2'b01 : begin // read button pressed
                if(~fifo_empty) begin
                    current_read_addr_buff = next_read_addr;
                    full_buff = 1'b0;
                    if(next_read_addr == current_write_addr) begin
                        empty_buff = 1'b1;
                    end
                end
            end

            2'b10 : begin // write button pressed
                if(~fifo_full) begin
                    current_write_addr_buff = next_write_addr;
                    empty_buff = 1'b0;
                    if(next_write_addr == current_read_addr) begin
                        full_buff = 1'b1;
                    end
                end
            end

            2'b11 : begin //read and write pressed
                current_write_addr_buff = next_write_addr;
                current_read_addr_buff = next_read_addr;
            end
        endcase
    end

    assign empty = fifo_empty;
    assign full = fifo_full;
    
endmodule