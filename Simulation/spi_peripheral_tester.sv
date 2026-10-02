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
    logic wr_en = 0;
    logic [DATA_WIDTH-1:0] data_in = '0;
    wire [DATA_WIDTH-1:0] data_out;
    wire miso;
    wire tx_empty = dut.tx_fifo_empty;
    wire tx_full = dut.tx_fifo_full;
    localparam integer PTR_WIDTH = $clog2(FIFO_DEPTH) + 1;
    // TX payload awaiting master reception (includes any active shift word).
    logic [DATA_WIDTH-1:0] pending_words[$];
    integer errors = 0;
    integer tx_checked_words = 0;
    wire rx_empty = dut.rx_fifo_empty;
    wire rx_full  = dut.rx_fifo_full;

    // what SHOULD be in the FIFO
    logic [DATA_WIDTH-1:0] expected_fifo[$];
    integer checked_words = 0;

    always #10 clk = ~clk; // 50 MHz

    spi_peripheral #(
        .data_width(DATA_WIDTH), .spi_mode(0), .fifo_depth(FIFO_DEPTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .sclk(sclk),
        .cs_in(cs_in),
        .mosi(mosi),
        .rd_en(rd_en),
        .wr_en(wr_en),
        .data_in(data_in),
        .miso(miso),
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

    task automatic check(input logic condition, input string message);
        begin
            if (condition !== 1'b1) begin
                errors = errors + 1;
                $display("  FAIL: %s", message);
            end else
                $display("  PASS: %s", message);
        end
    endtask

    task automatic show_tx;
        integer i;
        begin
            $display("  Expected pending payload: %0d words / %0d bits",
                     pending_words.size(), pending_words.size()*DATA_WIDTH);
            $write("  Expected receive order: ");
            if (pending_words.size() == 0) $write("NONE");
            for (i=0; i<pending_words.size(); i=i+1)
                $write("0x%h ", pending_words[i]);
            $display("");
            $display("  Actual flags: tx_full=%b (CPU), tx_empty=%b (SPI)", tx_full, tx_empty);
            $display("  Actual pointers: write=%0d read=%0d; MISO=%b",
                     dut.tx_wr_ptr_bin, dut.tx_rd_ptr_bin, miso);
        end
    endtask

    task automatic reset_dut;
        begin
            @(negedge clk);
            cs_in=1; sclk=0; mosi=0; rd_en=0; wr_en=0; data_in='0;
            rst=1;
            pending_words.delete();
            expected_fifo.delete();
            repeat (4) @(negedge clk);
            rst=0;
            repeat (4) @(negedge clk);
            check(tx_empty === 1'b1 && tx_full === 1'b0, "reset: empty=1, full=0");
            check(dut.tx_rd_ptr_bin === '0 && dut.tx_wr_ptr_bin === '0,
                  "reset: both TX pointers are zero");
        end
    endtask

    // CPU presents a word for exactly one rising clk edge
    task automatic cpu_write(input logic [DATA_WIDTH-1:0] word,
                             input bit expect_accept);
        logic [PTR_WIDTH-1:0] old_ptr, next_ptr;
        logic [DATA_WIDTH-1:0] old_slot;
        integer address;
        begin
            @(negedge clk);
            old_ptr = dut.tx_wr_ptr_bin;
            next_ptr = old_ptr + 1'b1;
            address = old_ptr % FIFO_DEPTH;
            old_slot = dut.tx_fifo[address];
            $display("\n[%0t] CPU WRITE 0x%h (%0d bits / %0d bytes), expected %s",
                     $time, word, DATA_WIDTH, DATA_WIDTH/8,
                     expect_accept ? "STORE" : "REJECT: FULL");
            check(tx_full === !expect_accept, "CPU full flag matches expected acceptance");
            data_in=word; wr_en=1;
            @(negedge clk); // Write happened on intervening rising edge.
            wr_en=0;
            if (expect_accept) begin
                pending_words.push_back(word);
                check(dut.tx_wr_ptr_bin === next_ptr, "write pointer advanced once");
                check(dut.tx_wr_ptr_gray === (next_ptr ^ (next_ptr >> 1)),
                      "write Gray pointer matches binary pointer");
                check(dut.tx_fifo[address] === word, "FIFO slot contains submitted word");
            end else begin
                check(dut.tx_wr_ptr_bin === old_ptr, "full FIFO rejected write without advancing");
                check(dut.tx_fifo[address] === old_slot, "rejected write preserved FIFO slot");
            end
            show_tx();
        end
    endtask

    // One 32-clock transfer
    task automatic master_read(input logic [DATA_WIDTH-1:0] expected);
        logic [DATA_WIDTH-1:0] actual;
        integer b;
        begin
            actual='0;
            $display("\n[%0t] MASTER expects 0x%h (%0d bits)", $time, expected, DATA_WIDTH);
            for (b=DATA_WIDTH-1; b>=0; b=b-1) begin
                #(SPI_HALF_NS);
                sclk=1;
                actual[b]=miso;
                if (b == DATA_WIDTH-1)
                    $display("  First rising edge: expected MSB=%b, sampled MISO=%b",
                             expected[DATA_WIDTH-1], miso);
                #(SPI_HALF_NS);
                sclk=0;
            end
            // Allow final falling-edge register updates before reporting.
            #0.001;
            $display("  Expected=0x%h actual=0x%h", expected, actual);
            check(actual === expected, "complete MISO word matches (including first and last bits)");
            tx_checked_words=tx_checked_words+1;
        end
    endtask

    task automatic read_payload;
        logic [DATA_WIDTH-1:0] word;
        begin
            if (pending_words.size() == 0)
                $fatal(1, "Testbench error: no pending payload");
            word=pending_words.pop_front();
            master_read(word);
            show_tx();
        end
    endtask

    task automatic start_spi;
        begin
            cs_in=0;
            #(SPI_HALF_NS); // CS setup time; SCLK remains stopped here.
        end
    endtask

    task automatic stop_spi;
        begin
            #(SPI_HALF_NS);
            cs_in=1;
            repeat (4) @(negedge clk); // Read pointer crosses to CPU.
            check(tx_full === 1'b0, "CPU full flag clears after transmission");
        end
    endtask

    initial begin : test
        integer i, batch;
        $timeformat(-9, 3, " ns", 12);
        $display("SPI RX + TX: mode 0, MSB first, CPU=50 MHz, SPI=32 MHz");
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
        $display("\nRX TEST 1: Reset, then send and read one word");
        show_fifo();
        send_word(32'h1234_5678);
        read_word();

        $display("\nRX TEST 2: Fill FIFO, send an extra word, then read in order");
        for (i = 0; i < FIFO_DEPTH; i = i+1)
            send_word(32'hA000_0000 + i);
        send_word(32'hDEAD_BEEF); // Must NOT appear in later reads.
        repeat (FIFO_DEPTH) read_word();

        $display("\nRX TEST 3: Refill and drain again to exercise pointer wraparound");
        for (i = 0; i < FIFO_DEPTH; i = i+1)
            send_word(32'hB000_0000 + i);
        repeat (FIFO_DEPTH) read_word();

        $display("\nRX TEST 4: Reading while empty must not consume a future word");
        @(negedge clk); rd_en = 1;
        repeat (3) @(negedge clk);
        rd_en = 0;
        send_word(32'h8000_0001);
        read_word();

        $display("\nRX PASS: all %0d received words matched.", checked_words);

        $display("\nStarting TX tests: first-bit payload, no dummy clocks; empty response=0.");
        $display("TX pending payload is not FIFO occupancy; it includes any active shift word.");
        $display("\nTX TEST 1: Fill TX FIFO and reject an extra CPU write");
        reset_dut();
        for (i=0; i<FIFO_DEPTH; i=i+1)
            cpu_write(32'hA123_4500+i, 1);
        check(tx_full === 1'b1, "four CPU writes fill the FIFO");
        cpu_write(32'hDEAD_BEEF, 0);
        start_spi();
        repeat (FIFO_DEPTH) read_payload();
        master_read('0); // Must not transmit rejected DEADBEEF
        check(tx_empty === 1'b1, "TX FIFO is empty after burst");
        stop_spi();

        $display("\nTX TEST 2: First-bit correctness and separate CS transactions");
        reset_dut();
        cpu_write(32'h8000_0001, 1);
        start_spi(); read_payload(); stop_spi();
        cpu_write(32'hFFFF_FFFF, 1);
        start_spi(); read_payload(); stop_spi();

        $display("\nTX TEST 3: Repeated bursts exercise address and pointer wraparound");
        reset_dut();
        for (batch=0; batch<3; batch=batch+1) begin
            $display("\n  BATCH %0d", batch+1);
            for (i=0; i<FIFO_DEPTH; i=i+1)
                cpu_write(32'hC135_7900+batch*FIFO_DEPTH+i, 1);
            start_spi();
            repeat (FIFO_DEPTH) read_payload();
            stop_spi();
        end

        $display("\nTX TEST 4: Empty transfer must not consume a future word");
        reset_dut();
        start_spi(); master_read('0); stop_spi();
        check(dut.tx_rd_ptr_bin === '0, "empty transfer did not advance read pointer");
        cpu_write(32'hFEDC_BA98, 1);
        start_spi(); read_payload(); stop_spi();


        $display("\nSUMMARY: RX words=%0d, TX words=%0d, TX failed checks=%0d",
                 checked_words, tx_checked_words, errors);
        if (errors != 0)
            $fatal(1, "COMBINED TEST FAILED: review TX FAIL messages above");
        $display("PASS: all RX and TX tests passed");
        $finish;
    end

    initial begin
        #200000;
        $fatal(1, "Combined test timeout (200 us)");
    end
endmodule
