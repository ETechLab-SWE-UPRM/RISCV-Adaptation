`timescale 1ns / 1ps

// For the tx side, currently for synchronization, 2 cycles must be sent for preparation before the first bit is sent.
module spi_peripheral #(
    parameter data_width = 32,
    parameter spi_mode = 0, // sclk idle low, sample on rise and shift on fall
    parameter fifo_depth = 8,
    parameter command_width = 8
)(
    input logic clk,
    input logic rst,
    input logic sclk,
    input logic cs_in,
    input logic mosi,
    input logic rd_en, // read enable for fifo to update read pointer
    input logic wr_en, // write enable for fifo to update write pointer
    input logic [data_width-1:0] data_in,

    output logic miso,
    output logic rx_fifo_empty, // can be used to indicate if a word can be read from the fifo
    output logic rx_fifo_full, // Master can use this to know if it can write a word to the fifo
    output logic tx_fifo_empty, // Master can use this to know if it can read a word from the fifo
    output logic tx_fifo_full, // can be used to indicate if a word can be written to the fifo
    output logic [data_width-1:0] data_out
);
    localparam bit_count = $clog2(data_width);
    localparam fifo_addr_width = $clog2(fifo_depth);
    localparam fifo_ptr_width = fifo_addr_width + 1;
    localparam read_cmd = 8'h1;
    localparam write_cmd = 8'h2;
    localparam rd_wr_cmd = 8'h3;

    logic comm_done, rx_enable, tx_enable;
    logic [7:0] comm_shift_reg;

    logic [data_width-1:0] rx_shift_reg;
    logic [bit_count-1:0] rx_bit_counter, tx_bit_counter;

    logic [data_width-1:0] rx_fifo [0: fifo_depth-1];
    logic [fifo_ptr_width-1:0] rx_rd_ptr_bin;
    logic [fifo_ptr_width-1:0] rx_rd_ptr_bin_next; // to simplify the logic for updating the read pointer
    logic [fifo_ptr_width-1:0] rx_rd_ptr_gray;

    (* ASYNC_REG = "TRUE" *) logic [fifo_ptr_width-1:0]rx_rd_ptr_gray_sync, rx_rd_ptr_gray_sync2;

    logic [fifo_ptr_width-1:0] rx_wr_ptr_bin;
    logic [fifo_ptr_width-1:0] rx_wr_ptr_bin_next; // to simplify the logic for updating the write pointer
    logic [fifo_ptr_width-1:0] rx_wr_ptr_gray;

    (* ASYNC_REG = "TRUE" *) logic [fifo_ptr_width-1:0] rx_wr_ptr_gray_sync, rx_wr_ptr_gray_sync2;

    assign rx_rd_ptr_bin_next = rx_rd_ptr_bin + 1;
    assign rx_wr_ptr_bin_next = rx_wr_ptr_bin + 1;
    assign rx_fifo_empty = (rx_rd_ptr_gray == rx_wr_ptr_gray_sync2);

    // Inverting top 2 bits is + 8 to the pointer in gray code, effectively calculating wr_ptr == rd_ptr + 8
    assign rx_fifo_full = (rx_wr_ptr_gray == {~rx_rd_ptr_gray_sync2[fifo_ptr_width-1:fifo_ptr_width-2], rx_rd_ptr_gray_sync2[fifo_ptr_width-3:0]});

    assign data_out = rx_fifo[rx_rd_ptr_bin[fifo_addr_width-1:0]];

    // Synchronize write pointer  SPI -> CPU clock
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            rx_wr_ptr_gray_sync <= '0;
            rx_wr_ptr_gray_sync2 <= '0;
        end else begin
            rx_wr_ptr_gray_sync <= rx_wr_ptr_gray;
            rx_wr_ptr_gray_sync2 <= rx_wr_ptr_gray_sync;
        end
    end

    // CPU -> SPI clock
    always_ff @(posedge sclk or posedge rst) begin
        if(rst) begin
            rx_rd_ptr_gray_sync <= '0;
            rx_rd_ptr_gray_sync2 <= '0;
        end else begin
            rx_rd_ptr_gray_sync <= rx_rd_ptr_gray;
            rx_rd_ptr_gray_sync2 <= rx_rd_ptr_gray_sync;
        end
    end

    // RX FIFO read logic
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            rx_rd_ptr_bin <= '0;
            rx_rd_ptr_gray <= '0;
        end else if(rd_en && !rx_fifo_empty) begin
            rx_rd_ptr_bin <= rx_rd_ptr_bin_next;
            rx_rd_ptr_gray <= rx_rd_ptr_bin_next ^ (rx_rd_ptr_bin_next >> 1);
        end
    end

    logic [command_width-1:0] command_word;
    assign command_word = {comm_shift_reg[command_width-2:0], mosi };

    // SPI RX and FIFO write logic
    always_ff @(posedge sclk or posedge rst) begin
        if(rst) begin
            rx_shift_reg   <= '0;
            rx_bit_counter <= '0;
            rx_wr_ptr_bin  <= '0;
            rx_wr_ptr_gray <= '0;
            comm_shift_reg <= '0;
            comm_done <= 'b0;
            rx_enable <= '0;
            tx_enable <= '0;
            for (integer i = 0; i < fifo_depth; i = i + 1) begin
                rx_fifo[i] <= '0;
            end
        end else if(cs_in) begin // in case a word gets interrupted midway
            rx_shift_reg   <= '0;
            rx_bit_counter <= '0;
            comm_shift_reg <= '0;
            comm_done <= 'b0;
            rx_enable <= '0;
            tx_enable <= '0;
        end else if(!comm_done) begin
            comm_shift_reg <= command_word;

            if(rx_bit_counter == command_width-1) begin
                comm_done <= 'b1;
                rx_bit_counter <= '0;
                case (command_word)
                    read_cmd: begin
                        rx_enable <= 1'b1;
                        tx_enable <= 1'b0;
                    end

                    write_cmd: begin
                        rx_enable <= 1'b0;
                        tx_enable <= 1'b1;
                    end

                    rd_wr_cmd: begin
                        rx_enable <= 1'b1;
                        tx_enable <= 1'b1;
                    end

                    default: begin
                        rx_enable <= 1'b0;
                        tx_enable <= 1'b0;
                    end
                endcase
            end else begin
                rx_bit_counter <= rx_bit_counter + 1'b1;
            end
        end else if(rx_enable) begin
            rx_shift_reg <= {rx_shift_reg[data_width-2:0], mosi}; // slice bit 31 and concatenate with mosi bit

            if(rx_bit_counter == data_width-1) begin
                rx_bit_counter <= '0;

                if(!rx_fifo_full) begin // if full, word lost
                    rx_fifo[rx_wr_ptr_bin[fifo_addr_width-1:0]] <= {rx_shift_reg[data_width-2:0], mosi};

                    rx_wr_ptr_bin <= rx_wr_ptr_bin_next;
                    rx_wr_ptr_gray <= rx_wr_ptr_bin_next ^ (rx_wr_ptr_bin_next >> 1);
                end
            end else begin
                rx_bit_counter <= rx_bit_counter + 1'b1;
            end
        end
    end

    logic first_bit = 1; // preload flag
    logic [data_width-1:0] tx_shift_reg;
    logic [data_width-1:0] tx_fifo [0: fifo_depth-1];
    logic [data_width-1:0] fifo_word;

    logic [fifo_ptr_width-1:0] tx_rd_ptr_bin;
    logic [fifo_ptr_width-1:0] tx_rd_ptr_bin_next; // to simplify the logic for updating the read pointer
    logic [fifo_ptr_width-1:0] tx_rd_ptr_gray;

    (* ASYNC_REG = "TRUE" *) logic [fifo_ptr_width-1:0]tx_rd_ptr_gray_sync, tx_rd_ptr_gray_sync2;

    logic [fifo_ptr_width-1:0] tx_wr_ptr_bin;
    logic [fifo_ptr_width-1:0] tx_wr_ptr_bin_next; // to simplify the logic for updating the write pointer
    logic [fifo_ptr_width-1:0] tx_wr_ptr_gray;

    (* ASYNC_REG = "TRUE" *) logic [fifo_ptr_width-1:0] tx_wr_ptr_gray_sync, tx_wr_ptr_gray_sync2;

    assign tx_rd_ptr_bin_next = tx_rd_ptr_bin + 1;
    assign tx_wr_ptr_bin_next = tx_wr_ptr_bin + 1;
    assign tx_fifo_empty = (tx_rd_ptr_gray == tx_wr_ptr_gray_sync2);

    // Inverting top 2 bits is + 8 to the pointer in gray code, effectively calculating wr_ptr == rd_ptr + 8
    assign tx_fifo_full = (tx_wr_ptr_gray == {~tx_rd_ptr_gray_sync2[fifo_ptr_width-1:fifo_ptr_width-2], tx_rd_ptr_gray_sync2[fifo_ptr_width-3:0]});

    // Synchronize write pointer  CPU -> SPI clock
    always_ff @(posedge sclk or posedge rst) begin
        if(rst) begin
            tx_wr_ptr_gray_sync <= '0;
            tx_wr_ptr_gray_sync2 <= '0;
        end else begin
            tx_wr_ptr_gray_sync <= tx_wr_ptr_gray;
            tx_wr_ptr_gray_sync2 <= tx_wr_ptr_gray_sync;
        end
    end

    // SPI -> CPU clock
    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            tx_rd_ptr_gray_sync <= '0;
            tx_rd_ptr_gray_sync2 <= '0;
        end else begin
            tx_rd_ptr_gray_sync <= tx_rd_ptr_gray;
            tx_rd_ptr_gray_sync2 <= tx_rd_ptr_gray_sync;
        end
    end

    // TX FIFO write logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_wr_ptr_bin <= '0;
            tx_wr_ptr_gray <= '0;
            for (integer i = 0; i < fifo_depth; i = i + 1) begin
                tx_fifo[i] <= '0;
            end
        end else if(wr_en && !tx_fifo_full) begin
            tx_fifo[tx_wr_ptr_bin[fifo_addr_width-1:0]] <= data_in;
            tx_wr_ptr_bin <= tx_wr_ptr_bin_next;
            tx_wr_ptr_gray <= tx_wr_ptr_bin_next ^ (tx_wr_ptr_bin_next >> 1);
        end
    end

    assign fifo_word = tx_fifo[tx_rd_ptr_bin[fifo_addr_width-1:0]];
    assign miso = tx_shift_reg[data_width-1]; // miso = MSB of tx_shift_reg

    // SPI TX and FIFO read logic
    always_ff @(negedge sclk or posedge rst) begin
        if (rst) begin
            tx_shift_reg   <= '0;
            tx_bit_counter <= '0;
            tx_rd_ptr_bin  <= '0;
            tx_rd_ptr_gray <= '0;
            first_bit      <= 1'b1;
        end else if (cs_in) begin
            tx_bit_counter <= '0;
            tx_shift_reg <= '0;
        end else if(tx_enable) begin
            if (tx_bit_counter == 0) begin
                if (!tx_fifo_empty) begin
                    tx_shift_reg <= fifo_word;
                    tx_rd_ptr_bin <= tx_rd_ptr_bin_next;
                    tx_rd_ptr_gray <= tx_rd_ptr_bin_next ^ (tx_rd_ptr_bin_next >> 1);
                    tx_bit_counter <= tx_bit_counter + 1'b1;
                end
            end else begin
                tx_shift_reg <= {tx_shift_reg[data_width-2:0], 1'b0};
                
                if (tx_bit_counter == data_width - 1) begin
                    tx_bit_counter <= '0;
                    first_bit <= 1'b1;
                end else begin
                    tx_bit_counter <= tx_bit_counter + 1'b1;
                end
            end
        end
    end

endmodule