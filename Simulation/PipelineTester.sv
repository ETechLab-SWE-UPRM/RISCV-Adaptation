`timescale 1ns/1ps

module PipelineTester;
    logic clk = 0;
    logic rst = 1;
    logic rx = 1;
    wire tx;
    wire [3:0] an;
    wire [6:0] seg;
    wire led;

    logic sclk = 0;
    logic cs_in = 1;
    logic mosi = 0;
    wire miso;

    // Command names use the FPGA perspective: READ receives, WRITE transmits
    localparam logic [7:0] CMD_READ  = 8'h01;
    localparam logic [7:0] CMD_WRITE = 8'h02;
    localparam logic [7:0] CMD_RDWR  = 8'h03;

    localparam realtime SPI_HALF_NS = 15.625;
    localparam integer PREP_CLOCKS = 8;
    localparam time CS_DELAY = 1_000;
    localparam time WORD_GAP = 1_000_000;
    localparam time BOOT_WAIT = 100_000;
    localparam integer MAX_POLLS = 20;
    localparam integer QUIET_READS = 3;

    integer transaction_count = 0;

    RISCV_WEARABLE processor (
        .clk(clk), .reset(rst), .rx(rx), .tx(tx),
        .seg(seg), .an(an), .led(led),
        .sclk(sclk), .cs_in(cs_in), .mosi(mosi), .miso(miso)
    );

    always #10 clk = ~clk;

    task automatic spi_prepare;
        integer i;
        begin
            cs_in = 1;
            sclk = 0;
            mosi = 0;
            #(CS_DELAY);
            $display("[%0t] PREP: %0d clocks with CS high", $time, PREP_CLOCKS);
            for (i = 0; i < PREP_CLOCKS; i = i + 1) begin
                #(SPI_HALF_NS); sclk = 1;
                #(SPI_HALF_NS); sclk = 0;
            end
            #(CS_DELAY);
        end
    endtask

    task automatic spi_bit(input logic outgoing, output logic incoming);
        begin
            mosi = outgoing;
            #(SPI_HALF_NS);
            incoming = miso;
            sclk = 1;
            #(SPI_HALF_NS);
            sclk = 0;
        end
    endtask

    task automatic spi_exchange_word(
        input logic [7:0] command,
        input logic [31:0] outgoing,
        output logic [31:0] incoming
    );
        integer b;
        logic sampled;
        logic [7:0] command_rx;
        begin
            incoming = '0;
            command_rx = '0;
            spi_prepare();
            cs_in = 0;
            mosi = command[7];
            #(CS_DELAY);

            for (b = 7; b >= 0; b = b - 1) begin
                spi_bit(command[b], sampled);
                command_rx[b] = sampled;
            end

            for (b = 31; b >= 0; b = b - 1) begin
                spi_bit(outgoing[b], sampled);
                incoming[b] = sampled;
            end

            #(CS_DELAY);
            cs_in = 1;
            mosi = 0;
            transaction_count = transaction_count + 1;
            $display("[%0t] TRANSFER %0d CMD=0x%02h MOSI=0x%08h MISO=0x%08h (command MISO=0x%02h ignored)",
                     $time, transaction_count, command, outgoing,
                     incoming, command_rx);

            // FPGA READ-only MISO is not protocol data and is intentionally ignored.
            if ((command == CMD_WRITE || command == CMD_RDWR) &&
                $isunknown(incoming))
                $fatal(1, "X/Z in response payload: check TX preload/reset/wiring.");
        end
    endtask

    initial begin : test
        logic [31:0] received;
        integer poll;
        integer quiet;
        bit passed;

        $timeformat(-6, 3, " us", 12);
        $display("==========================================");
        $display("CPU + command-aware SPI test: mode 0, 32 MHz");
        $display("Each transaction: 8 command + 32 payload clocks");
        $display("FPGA READ(0x80000000), FPGA WRITE until 0x80000001");
        $display("Assumes empty TX returns zero and firmware emits only one response.");
        $display("==========================================");

        repeat (10) @(negedge clk);
        rst = 0;
        #(BOOT_WAIT);

        $display("\n[%0t] FPGA READ input 0x80000000", $time);
        spi_exchange_word(CMD_READ, 32'h80000000, received);

        passed = 0;
        for (poll = 1; poll <= MAX_POLLS && !passed; poll = poll + 1) begin
            #(WORD_GAP);
            $display("\n[%0t] FPGA WRITE poll %0d", $time, poll);
            spi_exchange_word(CMD_WRITE, 32'h00000000, received);
            if (received === 32'h80000001) begin
                passed = 1;
                $display("PASS: received 0x80000001 after %0d poll(s)", poll);
            end else if (received === 32'd0) begin
                $display("  Empty response placeholder; keep polling.");
            end else begin
                $fatal(1, "Unexpected response 0x%08h: expected empty zero or 0x80000001.", received);
            end
        end

        if (!passed)
            $fatal(1, "Expected 0x80000001 after %0d polls; last response=0x%08h",
                   MAX_POLLS, received);

        for (quiet = 1; quiet <= QUIET_READS; quiet = quiet + 1) begin
            #(WORD_GAP);
            spi_exchange_word(CMD_WRITE, 32'hDEADBEEF, received);
            if (received !== 32'd0)
                $fatal(1, "Unexpected extra response after 0x80000001: 0x%08h", received);
        end

        $display("\nPASS: command/payload framing and CPU response sequence passed.");
        $display("RX dummy suppression and FPGA READ TX-pointer preservation require internal FIFO assertions.");
        $display("FULL DUPLEX is supported by the transfer task but not exercised by this firmware sequence.");
        #(CS_DELAY);
        $finish;
    end

    initial begin
        #25_000_000;
        $fatal(1, "Simulation watchdog expired.");
    end
endmodule
