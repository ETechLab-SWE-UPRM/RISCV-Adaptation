`timescale 1ns/1ps

module PipelineTester;

    logic clk = 0; 
    logic rst, rx, tx;
    logic [3:0] an;
    logic [6:0] seg;
    logic led;

    localparam int CLKS_per_bit = 868;
    localparam int BIT_TIME_NS = CLKS_per_bit * 10;

    RISCV_PIPELINED processor (
        .clk(clk),
        .reset(rst),
        .rx(rx),
        .tx(tx),
        .seg(seg),
        .an(an),
        .led(led)
    );

    always #5 clk = ~clk; // Clock period of 10 time units

    task automatic uart_send_byte(input byte b);
    int i;
    begin
      // Start bit
      rx = 1'b0; #(BIT_TIME_NS);

      // Data bits (LSB first)
      for (i = 0; i < 8; i++) begin
        rx = b[i];
        #(BIT_TIME_NS);
      end

      // Stop bit
      rx = 1'b1; #(BIT_TIME_NS);
    end
  endtask
    
    initial begin
    // Initialize
    rx = 1'b1;   // idle high
    rst = 1'b1;
    #100;
    rst = 1'b0;
    #100000;

    $display("Dumping data memory to data_tester_dump.hex");
        $writememh(
            "C:/Users/pizar/RISCV-Adaptation/Risc-V processor.srcs/sources_1/memory_dump.hex",
            processor.data_mem.mem_inst.inst.native_mem_module.blk_mem_gen_v8_4_9_inst.memory
        );

    $finish;
  end
endmodule