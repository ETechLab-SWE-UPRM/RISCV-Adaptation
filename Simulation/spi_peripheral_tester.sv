`timescale 1ns/1ps

module spi_peripheral_tester;
    localparam integer DATA_WIDTH = 32;
    localparam integer FIFO_DEPTH = 4;
    localparam realtime SPI_HALF_NS = 15.625; // 32 MHz SCLK

    logic clk = 0;
    logic rst = 0;
    logic sclk = 0;
    logic cs_in = 1;
    logic mosi = 0;
    logic rd_en = 0;
    logic [DATA_WIDTH-1:0] data_in = '0;
    wire [DATA_WIDTH-1:0] data_out;
    wire rx_empty = dut.rx_fifo_empty;
    wire rx_full  = dut.rx_fifo_full;

    // what SHOULD be in the FIFO
    logic [DATA_WIDTH-1:0] expected_fifo[$];
    integer checked_words = 0;

    always #10 clk = ~clk; // 50 MHz

    spi_peripheral #(
        .data_width(DATA_WIDTH), .spi_mode(0), .fifo_depth(FIFO_DEPTH)
    ) dut (
        .clk(clk), .rst(rst), .sclk(sclk), .cs_in(cs_in),
        .mosi(mosi), .rd_en(rd_en), .data_in(data_in),
        .data_out(data_out)
    );

    task automatic show_fifo;
        integer i;
        begin
            $display("  Expected occupancy: %0d/%0d words (%0d valid bits)",
                     expected_fifo.size(), FIFO_DEPTH,
                     expected_fifo.size()*DATA_WIDTH);
            $write("  Expected FIFO [oldest -> newest]: ");
            if (expected_fifo.size() == 0) $write("EMPTY");
            for (i = 0; i < expected_fifo.size(); i = i+1)
                $write("0x%h ", expected_fifo[i]);
            $display("");
            $display("  Actual flags: empty=%b full=%b", rx_empty, rx_full);
            if (rx_empty === 1'b0)
                $display("  Actual data_out: 0x%h", data_out);
            else
                $display("  Actual data_out: not valid while empty");
        end
    endtask

    task automatic send_word(input logic [DATA_WIDTH-1:0] word);
        integer bit_index;
        begin
            $display("\n[%0t] SEND 0x%h (%0d bits, unsigned decimal %0d)",
                     $time, word, DATA_WIDTH, word);
            cs_in = 0;
            for (bit_index = DATA_WIDTH-1; bit_index >= 0; bit_index = bit_index-1) begin
                mosi = word[bit_index];
                #(SPI_HALF_NS); sclk = 1; // Slave samples MOSI
                #(SPI_HALF_NS); sclk = 0;
            end
            #(SPI_HALF_NS);
            cs_in = 1;
            mosi = 0;

            if (expected_fifo.size() < FIFO_DEPTH) begin
                expected_fifo.push_back(word);
                $display("  Expected action: STORE word");
            end else begin
                $display("  Expected action: DROP word because FIFO is full");
            end

            // Allow the write pointer to synchronize into the CPU domain
            repeat (4) @(negedge clk);
            if (rx_empty !== 1'b0)
                $fatal(1, "FAIL: FIFO should contain received data");
            if (rx_full !== (expected_fifo.size() == FIFO_DEPTH))
                $fatal(1, "FAIL: incorrect full flag after SPI word");
            show_fifo();
        end
    endtask

    task automatic read_word;
        logic [DATA_WIDTH-1:0] expected_word;
        logic [DATA_WIDTH-1:0] actual_word;
        begin
            if (expected_fifo.size() == 0)
                $fatal(1, "Test error: read_word called with no expected data");
            @(negedge clk);
            if (rx_empty !== 1'b0)
                $fatal(1, "FAIL: FIFO unexpectedly empty or unknown");
            expected_word = expected_fifo[0];
            rd_en = 1;
            @(posedge clk);
            // Capture before the DUT advances its read pointer (NBA update)
            actual_word = data_out;
            $display("\n[%0t] READ expected=0x%h actual=0x%h (%0d bits)",
                     $time, expected_word, actual_word, DATA_WIDTH);
            if (actual_word !== expected_word)
                $fatal(1, "FAIL: received word does not match expected word");
            expected_word = expected_fifo.pop_front();
            checked_words = checked_words + 1;
            @(negedge clk);
            rd_en = 0;
            if (rx_empty !== (expected_fifo.size() == 0))
                $fatal(1, "FAIL: incorrect empty flag after CPU read");
            $display("  PASS: word matches");
            show_fifo();
        end
    endtask

    initial begin
        integer i;
        $timeformat(-9, 3, " ns", 12);
        $display("SPI RX: mode 0, MSB first, CPU=50 MHz, SPI=32 MHz");
        $display("Word size: %0d bits (%0d bytes)", DATA_WIDTH, DATA_WIDTH/8);
        $display("FIFO capacity: %0d words = %0d bits = %0d bytes",
                 FIFO_DEPTH, FIFO_DEPTH*DATA_WIDTH, FIFO_DEPTH*DATA_WIDTH/8);
        $display("SPI shifting time: 1000 ns per 32-bit word, excluding test gaps");
        $display("NOTE: full can remain high after CPU reads until SCLK resumes.");

        #1; rst = 1;
        repeat (4) @(negedge clk);
        rst = 0;
        repeat (4) @(negedge clk);
        if (rx_empty !== 1'b1 || rx_full !== 1'b0)
            $fatal(1, "FAIL: reset flags incorrect; check both Gray pointer resets");
        $display("\nTEST 1: Reset, then send and read one word");
        show_fifo();
        send_word(32'h1234_5678);
        read_word();

        $display("\nTEST 2: Fill FIFO, send an extra word, then read in order");
        for (i = 0; i < FIFO_DEPTH; i = i+1)
            send_word(32'hA000_0000 + i);
        send_word(32'hDEAD_BEEF);
        repeat (FIFO_DEPTH) read_word();

        $display("\nTEST 3: Refill and drain again to exercise pointer wraparound");
        for (i = 0; i < FIFO_DEPTH; i = i+1)
            send_word(32'hB000_0000 + i);
        repeat (FIFO_DEPTH) read_word();

        $display("\nTEST 4: Reading while empty must not consume a future word");
        @(negedge clk); rd_en = 1;
        repeat (3) @(negedge clk);
        rd_en = 0;
        send_word(32'h8000_0001);
        read_word();

        $display("\nPASS: all %0d words matched; FIFO is empty.", checked_words);
        $finish;
    end


    initial begin
        #100000;
        $fatal(1, "FAIL: test timeout");
    end
endmodule
