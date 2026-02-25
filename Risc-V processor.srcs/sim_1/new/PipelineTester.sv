`timescale 1ns/1ps

module PipelineTester;

    logic clk = 0; 
    logic rst, rx, tx;
    logic [3:0] an;
    logic [6:0] seg;
    logic led;

    localparam int CLKS_per_bit = 868;
    localparam time BIT_TIME_NS = CLKS_per_bit * 10;

  task automatic uart_rx_send_byte(input byte b);
    int i;
    begin
      // idle high before start
      rx <= 1'b1;
      #(BIT_TIME_NS);

      // start bit
      rx <= 1'b0;
      #(BIT_TIME_NS);
      // 8 data bits, LSB first
      for (i = 0; i < 8; i++) begin
        rx <= b[i];
        #(BIT_TIME_NS);
      end

      // stop bit
      rx <= 1'b1;
      #(BIT_TIME_NS);

      // inter-byte idle (optional but helps)
      #(BIT_TIME_NS);
      $display("[%0t] UART RX sent byte 0x%02h '%s'", $time, b,
              (b >= 32 && b < 127) ? {b} : ".");
    end
  endtask

  task automatic uart_rx_send_string(input string s);
    int k;
    begin
      for (k = 0; k < s.len(); k++) begin
        uart_rx_send_byte(s[k]);
      end
    end
  endtask

    // -------------------------
  // UART TX receiver (from DUT)
  // -------------------------
  task automatic uart_tx_print_byte;
  int i;
  byte b;
  bit stop_bit;

  begin
    // Wait for idle-high then start bit
    wait (tx === 1'b1);
    wait (tx === 1'b0); // start bit detected

    // Move to center of first data bit (1.5 bit times)
    #(BIT_TIME_NS + (BIT_TIME_NS/2));

    // Sample 8 data bits (LSB first)
    b = 8'h00;
    for (i = 0; i < 8; i++) begin
      b[i] = tx;
      #(BIT_TIME_NS);
    end

    // Sample stop bit
    stop_bit = tx;

    // Print result
    if (stop_bit !== 1'b1) begin
      $display("[%0t] TX RX framing error: byte=0x%02h stop=%b",
               $time, b, stop_bit);
    end else begin
      $display("[%0t] TX RX byte: 0x%02h '%s'",
               $time, b,
               (b >= 32 && b < 127) ? {b} : ".");
    end

    // Small guard time before next frame
    #(BIT_TIME_NS/2);
  end
endtask

    RISCV_WEARABLE processor (
        .clk(clk),
        .reset(rst),
        .rx(rx),
        .tx(tx),
        .seg(seg),
        .an(an),
        .led(led)
    );

    always #10 clk = ~clk; // Clock period of 10 time units
    
    initial begin
    // Initialize
    rx = 1'b1;   // idle high
    rst = 1'b1;
    #100;
    rst = 1'b0;
    #1000;
    // Send test string via UART
    uart_rx_send_string("boot");
    #800000;

     $display("Dumping data memory to data_tester_dump.hex");
         $writememh(
            "/home/dr4gui/Repos/RISCV-Adaptation/Risc-V processor.srcs/sources_1/memory_dump.hex",
            processor.data_mem.mem_inst.inst.native_mem_module.blk_mem_gen_v8_4_9_inst.memory
         );

    $finish;
  end
endmodule