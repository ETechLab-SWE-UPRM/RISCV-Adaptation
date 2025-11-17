`timescale 1ns / 1ps

module dm_tester ();

    logic clk;
    logic fmac;
    logic [31:0] address [0:1];
    logic [31:0] write_data [0:1];
    logic mem_read;
    logic mem_write;
    logic vec_op;
    logic [31:0] read_data [0:1];
    logic [2:0] funct3;

    initial clk = 0;
    always #5 clk = ~clk; // Clock period of 10 time units

    Data_memory #( 
        .vec_length(2) 
    ) dm (
        .clk(~clk),
        .vec_op(vec_op),
        .fmac(fmac),
        .address(address),
        .write_data(write_data),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .funct3(funct3),
        .read_data(read_data)
    );

    initial begin
        #10;
        address[0] = 32'h1000_0000;
        address[1] = 32'h1000_0004;
        vec_op = 1'b1;
        fmac = 1'b0;
        write_data[0] = 32'h12345678;
        write_data[1] = 32'h87654321;
        mem_read = 1'b0;
        mem_write = 1'b1;
        funct3 = 3'b010; // SW
        #20; // Wait for 10 time units

        address[0] = 32'h1000_0008;
        address[1] = 32'h1000_000C;
        vec_op = 1'b1;
        fmac = 1'b0;
        write_data[0] = 32'h87654321;
        write_data[1] = 32'h12345678;
        mem_read = 1'b0;
        mem_write = 1'b1;
        funct3 = 3'b010; // SW
        #15; // Wait for 10 time units

        address[0] = 32'h1000_0000;
        address[1] = 32'h1000_0004;
        vec_op = 1'b0;
        fmac = 1'b1;
        mem_read = 1'b0;
        mem_write = 1'b0;
        funct3 = 3'b010; // LW
        #10; // Wait for 10 time units

        address[0] = 32'h1000_0008;
        address[1] = 32'h1000_000C;
        vec_op = 1'b0;
        fmac = 1'b1;
        mem_read = 1'b0;
        mem_write = 1'b0;
        funct3 = 3'b010; // LW

        #20;
        $display("Dumping data memory to data_tester_dump.hex");
        $writememh(
            "C:/Users/pizar/RISCV-Adaptation/Risc-V processor.srcs/sources_1/data_tester_dump.hex",
            dm_tester.dm.mem_inst.inst.native_mem_module.blk_mem_gen_v8_4_9_inst.memory
        );
        $finish;        
    end

endmodule