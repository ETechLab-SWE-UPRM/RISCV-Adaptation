module spi_peripheral #(
    parameter data_width = 32,
    parameter spi_mode = 0, // sclk idle low, sample on rise and shift on fall
    parameter fifo_depth = 8
)(
    input logic clk,
    input logic rst,
    input logic sclk,
    input logic cs_in,
    input logic mosi,
    input logic rd_en, // read enable for fifo to update read pointer
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

    logic [data_width-1:0] rx_shift_reg;
    logic [bit_count-1:0] rx_bit_counter, tx_bit_counter;

    logic [data_width-1:0] rx_fifo [0: fifo_depth-1];
    logic [fifo_ptr_width-1:0] rx_rd_ptr_bin;
    logic [fifo_ptr_width-1:0] rx_rd_ptr_bin_next; // to simplify the logic for updating the read pointer
    logic [fifo_ptr_width-1:0] rx_rd_ptr_gray;

    (* ASYNC_REG = "TRUE" *)
    logic [fifo_ptr_width-1:0]rx_rd_ptr_gray_sync, rx_rd_ptr_gray_sync2;

    logic [fifo_ptr_width-1:0] rx_wr_ptr_bin;
    logic [fifo_ptr_width-1:0] rx_wr_ptr_bin_next; // to simplify the logic for updating the write pointer
    logic [fifo_ptr_width-1:0] rx_wr_ptr_gray;

    (* ASYNC_REG = "TRUE" *)
    logic [fifo_ptr_width-1:0] rx_wr_ptr_gray_sync, rx_wr_ptr_gray_sync2;

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

    // SPI RX and FIFO write logic
    always_ff @(posedge sclk or posedge rst) begin
        if(rst) begin
            rx_shift_reg   <= '0;
            rx_bit_counter <= '0;
            rx_wr_ptr_bin  <= '0;
            rx_wr_ptr_gray <= '0;
        end else if(cs_in) begin // in case a word gets interrupted midway
            rx_shift_reg   <= '0;
            rx_bit_counter <= '0;
        end else begin
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

    // FINISH TX FIFO LOGIC AND MISO OUTPUT LOGIC

    logic [data_width-1:0] tx_shift_reg;
    logic [fifo_ptr_width-1:0] tx_rd_ptr, tx_wr_ptr;

    assign miso = tx_shift_reg[data_width-1]; // miso = MSB of tx_shift_reg
    assign tx_fifo_empty = (tx_rd_ptr == tx_wr_ptr);
    assign tx_fifo_full = (tx_wr_ptr - tx_rd_ptr == fifo_depth);

    always_ff @(negedge sclk) begin
        if(rst || cs_in) begin
            tx_shift_reg <= '0;
            tx_bit_counter <= '0;
        end else begin
            tx_shift_reg <= {tx_shift_reg[data_width-2:0], 1'b0}; // slice bit 31 and concatenate with 0
            tx_bit_counter <= tx_bit_counter + 1'b1;
        end
    end

endmodule