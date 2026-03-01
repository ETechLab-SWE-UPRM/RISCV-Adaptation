`timescale 1ns/1ps

module Reg_testbench ();

    logic [4:0] read_reg1, read_reg2, read_reg3, write_reg;
    logic [31:0] write_data;
    logic reg_write_enable;
    logic [31:0] read_data1, read_data2, read_data3;

    Registers r_inst (
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .read_reg3(read_reg3),
        .write_reg(write_reg),
        .write_data(write_data),
        .reg_write_enable(reg_write_enable),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .read_data3(read_data3)
    );

    initial clk = 0;
    always #5 clk = ~clk; // Clock toggles every 5 time units

    initial begin
        read_reg1 = 5'h2;
        read_reg2 = 5'h3;
        read_reg3 = 5'h4;
        write_reg = 5'h4;
        write_data = 32'h12345678;

        reg_write_enable = 1;
        #10; // Wait for a clock cycle
        $display("Read Data 1: %h", read_data1);
        $display("Read Data 2: %h", read_data2);
        $display("Read Data 3: %h", read_data3);
        
    end
    
endmodule