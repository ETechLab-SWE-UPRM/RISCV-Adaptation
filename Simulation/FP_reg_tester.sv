`timescale 1ns / 1ps

module Floatingg_Point_Reg_Tester();

logic clk, reset;
logic [4:0] read_reg1, read_reg2, read_reg3, read_regdest;
logic [4:0] conv_write_reg_rs1, conv_write_reg_rs2;
logic [4:0] write_reg;
logic [31:0] write_data;
logic reg_write_enable;
logic conv_write_enable;
logic [31:0] conv_data_write [0:1];
logic [31:0] read_data1, read_data2, read_data3, read_data4;

Floating_Point_registers #(
    .data_width(32),
    .vec_length(2)
) FP_Reg (
    .clk(clk), 
    .reset(reset), 
    .read_reg1(read_reg1),
    .read_reg2(read_reg2),
    .read_reg3(read_reg3),
    .read_regdest(read_regdest),
    .conv_write_reg_rs1(conv_write_reg_rs1),
    .conv_write_reg_rs2(conv_write_reg_rs2),
    .write_reg(write_reg),
    .write_data(write_data),
    .reg_write_enable(reg_write_enable),
    .conv_write_enable(conv_write_enable),
    .conv_data_write(conv_data_write),

    .read_data1(read_data1),
    .read_data2(read_data2),
    .read_data3(read_data3),
    .read_data4(read_data4)
);

initial clk = 0;
always #5 clk = ~clk;

initial begin
    reset = 1;
    #10;
    reset = 0;

    // Test normal write and read
    write_reg = 5'd1;
    write_data = 32'h3F800000; // 1.0 in IEEE 754
    reg_write_enable = 1;
    #10;
    reg_write_enable = 0;
    read_reg1 = 5'd1;
    #10;
    $display("Read Data1: %h (Expected: 3F800000)", read_data1);

    // Test conv write and read
    conv_write_reg_rs1 = 5'd0; // f0
    conv_write_reg_rs2 = 5'd1; // f1
    conv_data_write[0] = 32'h40000000; // 2.0 in IEEE 754
    conv_data_write[1] = 32'h40400000; // 3.0 in IEEE 754
    conv_write_enable = 1;
    #10;
    conv_write_enable = 0;
    read_reg2 = 5'd0; // f0
    read_reg3 = 5'd1; // f1
    #10;
    $display("Conv Read Data1 (f0): %h (Expected: 40000000)", read_data2);
    $display("Conv Read Data2 (f1): %h (Expected: 40400000)", read_data3);

    $finish;    
end

endmodule
