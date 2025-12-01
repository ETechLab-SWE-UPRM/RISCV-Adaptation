`timescale 1ns / 1ps


module MB_tester();

logic clk;
logic rst_n;

initial clk = 0;
always #5 clk = ~clk;

MB_CPU_wrapper cpu_inst (
    .Clk   (clk),
    .reset (rst_n)
);

initial begin
    rst_n = 1;
    #20;
    rst_n = 0;
    #20000000;

    $display("Dumping data memory to MB_data_dump.hex");
    $display("Data content starts at line 1958 I guess");
        $writememh(
            "C:/Users/pizar/RISCV-Adaptation/Risc-V processor.srcs/sim_1/MB_data_dump.hex",
            cpu_inst.MB_CPU_i.microblaze_riscv_0_local_memory.lmb_bram.inst.native_mem_mapped_module.blk_mem_gen_v8_4_9_inst.memory
        );

    $finish;
end

endmodule
