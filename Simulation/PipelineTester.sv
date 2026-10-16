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

    // Directions are from the FPGA's perspective.
    localparam logic [7:0] CMD_READ  = 8'h01;
    localparam logic [7:0] CMD_WRITE = 8'h02;
    localparam logic [7:0] CMD_RDWR  = 8'h03;
    localparam logic [31:0] END_MARKER = 32'hBF800000;
    localparam integer SAMPLE_COUNT = 1024;
    localparam integer TEST_RUNS = 2;
    localparam integer MAX_RESULTS = 2048;
    localparam realtime SPI_HALF_NS = 15.625;
    localparam integer PREP_CLOCKS = 8;
    localparam time CS_DELAY = 1_000;
    localparam time BOOT_WAIT = 100_000;
    localparam time CONVOLUTION_WAIT = 2_000_000; // 2 ms
    // After the computation wait, read results without inter-word gaps.
    localparam time WORD_GAP = 0;
    localparam time RESPONSE_TIMEOUT = 100_000_000; // 100 ms simulation budget
    // Set only when the exact expected count is known. Zero disables checking.
    localparam integer EXPECTED_RESULTS = 1014;

    integer transaction_count = 0;
    logic [31:0] results [0:MAX_RESULTS-1];

    RISCV_WEARABLE processor (
        .clk(clk), .reset(rst), .rx(rx), .tx(tx),
        .seg(seg), .an(an), .led(led),
        .sclk(sclk), .cs_in(cs_in), .mosi(mosi), .miso(miso)
    );
    always #10 clk = ~clk;

    function automatic logic [31:0] sample_bits(input integer value);
        integer exponent;
        integer temporary;
        logic [31:0] normalized;
        logic [7:0] biased_exponent;
        begin
            exponent = 0;
            temporary = value;
            while (temporary > 1) begin
                temporary = temporary >> 1;
                exponent = exponent + 1;
            end
            normalized = value << (23 - exponent);
            biased_exponent = 127 + exponent;
            sample_bits = {1'b0, biased_exponent, normalized[22:0]};
        end
    endfunction

    function automatic real fp32_to_real(input logic [31:0] bits);
        integer exponent;
        real magnitude;
        begin
            exponent = bits[30:23];
            if (exponent == 0)
                magnitude = ($itor(bits[22:0]) / 8388608.0) * (2.0 ** (-126));
            else
                magnitude = (1.0 + $itor(bits[22:0]) / 8388608.0)
                            * (2.0 ** (exponent - 127));
            fp32_to_real = bits[31] ? -magnitude : magnitude;
        end
    endfunction

    task automatic spi_prepare;
        integer i;
        begin
            cs_in = 1;
            sclk = 0;
            mosi = 0;
            #(CS_DELAY);
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
        begin
            incoming = '0;
            spi_prepare();
            cs_in = 0;
            mosi = command[7];
            #(CS_DELAY);
            for (b = 7; b >= 0; b = b - 1)
                spi_bit(command[b], sampled);
            for (b = 31; b >= 0; b = b - 1) begin
                spi_bit(outgoing[b], sampled);
                incoming[b] = sampled;
            end
            #(CS_DELAY);
            cs_in = 1;
            mosi = 0;
            transaction_count = transaction_count + 1;
            $display("[%0t] TRANSFER %0d CMD=%02h TX=%08h RX=%08h", $time, transaction_count, command, outgoing, incoming);
            if ((command == CMD_WRITE || command == CMD_RDWR) &&
                $isunknown(incoming))
                $fatal(1, "X/Z in response payload: check TX preload/reset/wiring.");
        end
    endtask

    task automatic spi_send_inputs(output realtime payload_duration);
        integer i, b;
        logic sampled;
        logic [31:0] outgoing;
        realtime payload_start;
        begin
            spi_prepare();
            cs_in = 0;
            mosi = CMD_READ[7];
            #(CS_DELAY);
            for (b = 7; b >= 0; b = b - 1)
                spi_bit(CMD_READ[b], sampled);
            payload_start = $realtime;
            for (i = 1; i <= SAMPLE_COUNT; i = i + 1) begin
                outgoing = sample_bits(i);
                for (b = 31; b >= 0; b = b - 1)
                    spi_bit(outgoing[b], sampled);
                $display("[%0t] SENT word TX=%08h; input burst finished", $time, outgoing);
            end
            payload_duration = $realtime - payload_start;
            for (b = 31; b >= 0; b = b - 1)
                spi_bit(END_MARKER[b], sampled);
            #(CS_DELAY);
            cs_in = 1;
            mosi = 0;
            transaction_count = transaction_count + 1;
            $display("[%0t] SENT end marker 0xBF800000; input burst finished", $time);
        end
    endtask

    initial begin : test
        logic [31:0] received;
        integer count, polls, zeros, i, run;
        bit finished;
        realtime started, sent, receive_started, ended, payload_duration;

        $timeformat(-6, 3, " us", 12);
        $display("==========================================");
        $display("CPU + SPI full float-input transaction, mode 0, 32 MHz");
        $display("ONE READ command + floats 1.0..1024.0 + raw 0xBF800000");
        $display("WRITE polls receive raw 32-bit results until 0xBF800000");
        $display("Zeros are retained, including indistinguishable empty-FIFO placeholders.");
        $display("==========================================");

        repeat (10) @(negedge clk);
        rst = 0;
        #(BOOT_WAIT);
        for (run = 0; run < TEST_RUNS; run = run + 1) begin
            $display("\n========== CONVOLUTION RUN %0d OF %0d ==========", run + 1, TEST_RUNS);
            started = $realtime;
            spi_send_inputs(payload_duration);
            sent = $realtime;

            $display("1024-word payload time: %0.3f us", payload_duration / 1000.0);
            $display("Complete send time:    %0.3f us (includes command, marker, preparation and CS delays)",
                     (sent - started) / 1000.0);
            // FPGA firmware executes convolution after receiving the input.
            // This is a fixed allowance, not a measurement of CPU completion.
            $display("[%0t] Waiting 2 ms for FPGA computation", $time);
            #(CONVOLUTION_WAIT);
            receive_started = $realtime;
            $display("[%0t] 2 ms wait finished; reading results", $time);

                        count = 0;
            polls = 0;
            zeros = 0;
            finished = 0;

            // One CMD_WRITE for the entire FPGA -> master payload.
            // Keep CS low until the end marker is received.
            begin : receive_burst
                integer b;
                logic sampled;

                spi_prepare();
                cs_in = 0;
                mosi = CMD_WRITE[7];
                #(CS_DELAY);

                for (b = 7; b >= 0; b = b - 1)
                    spi_bit(CMD_WRITE[b], sampled);

                while (!finished) begin
                    if (($realtime - receive_started) >= RESPONSE_TIMEOUT)
                        $fatal(1,
                            "Response timeout: %0d words captured, %0d polls",
                            count, polls);

                    // Clock one complete word without another command
                    // or a CS transition between words.
                    for (b = 31; b >= 0; b = b - 1) begin
                        spi_bit(1'b0, sampled);
                        received[b] = sampled;
                    end

                    polls = polls + 1;

                    if ($isunknown(received))
                        $fatal(1,
                            "X/Z in response payload: check TX preload/reset/wiring.");

                    if (VERBOSE_TRANSFERS)
                        $display("[%0t] BURST word %0d RX=%08h",
                                 $time, polls, received);

                    if (received == END_MARKER) begin
                        finished = 1;
                    end else begin
                        if (count >= MAX_RESULTS)
                            $fatal(1,
                                "Capture buffer full before END: %0d words, %0d zeros",
                                count, zeros);

                        results[count] = received;
                        count = count + 1;

                        if (received == 0)
                            zeros = zeros + 1;
                    end
                end

                #(CS_DELAY);
                cs_in = 1;
                mosi = 0;
                transaction_count = transaction_count + 1;
            end

            ended = $realtime;

            $display("\nEND marker received: captured=%0d, zeros=%0d, polls=%0d",
                     count, zeros, polls);
            $display("Send time:      %0.3f us", (sent - started) / 1000.0);
            $display("Fixed compute wait: %0.3f us", (receive_started - sent) / 1000.0);
            $display("Receive time:       %0.3f us", (ended - receive_started) / 1000.0);
            $display("Wait + receive:     %0.3f us", (ended - sent) / 1000.0);
            $display("Total time:     %0.3f us", (ended - started) / 1000.0);
            for (i = 0; i < count; i = i + 1) begin
                if (results[i][30:23] == 8'hFF)
                    $display("RESULT[%0d] bits=0x%08h (NaN/Infinity)", i, results[i]);
                else
                    $display("RESULT[%0d] bits=0x%08h float=%0.9g",
                             i, results[i], fp32_to_real(results[i]));
            end
            if (EXPECTED_RESULTS != 0 && count != EXPECTED_RESULTS)
                $fatal(1, "Expected %0d results, captured %0d (including placeholders)",
                       EXPECTED_RESULTS, count);
            $display("TRANSACTION COMPLETE: end marker observed; numerical convolution correctness not checked.");
            $display("Kernel/output specification and internal FIFO signals are needed for numerical/overflow assertions.");
            #(CS_DELAY);
        end
        $display("Completed %0d convolution runs", TEST_RUNS);
        $finish;
    end

    initial begin
        #(BOOT_WAIT + TEST_RUNS * (CONVOLUTION_WAIT + RESPONSE_TIMEOUT + 10_000_000));
        $fatal(1, "Simulation watchdog expired.");
    end
endmodule
