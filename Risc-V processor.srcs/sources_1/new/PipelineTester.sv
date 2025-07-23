`timescale 1ns/1ps

module PipelineTester;

    logic clk = 0; 
    logic rst;

    RISCV_PIPELINED processor (
        .clk(clk),
        .reset(rst)
    );

    always #5 clk = ~clk; // Clock period of 10 time units
    
    initial begin 
        rst = 1'b1; // Start with reset high
        #20; 
        rst = 1'b0; 
        #700000;
        // Change this to our own path if you want to use it
        $display("Dumping instruction memory to memory_dump.hex");
        $writememh(
            "C:/Users/pizar/RISCV-Adaptation/Risc-V processor.srcs/sources_1/memory_dump.hex",
            processor.im.im_inst.inst.native_mem_module.blk_mem_gen_v8_4_9_inst.memory
        );

        $display("Dumping data memory to memory_dump.hex");
        $writememh(
            "C:/Users/pizar/RISCV-Adaptation/Risc-V processor.srcs/sources_1/memory_dump.hex",
            processor.data_mem.memory_block[0].mem_inst.inst.native_mem_module.blk_mem_gen_v8_4_9_inst.memory
        );
        $finish;
    end
endmodule