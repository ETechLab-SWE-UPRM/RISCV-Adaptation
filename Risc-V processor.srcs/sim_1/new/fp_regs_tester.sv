`timescale 1ns/1ps

module fp_regs_tester ();

    logic clk;
    logic reset;
    logic [4:0] read_reg1, read_reg2, read_reg3, read_regdest, write_reg;
    logic [31:0] write_data;
    logic reg_write_enable;
    logic [31:0] read_data1, read_data2, read_data3, read_data4;

    Floating_Point_registers fp_reg_inst (
        .clk(clk),
        .reset(reset),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .read_reg3(read_reg3),
        .read_regdest(read_regdest),
        .write_reg(write_reg),
        .write_data(write_data),
        .reg_write_enable(reg_write_enable),
        .read_data1(read_data1),
        .read_data2(read_data2),
        .read_data3(read_data3),
        .read_data4(read_data4)
    );

    initial clk = 0;
    always #5 clk = ~clk; 

    initial begin
        reset = 1;
        #20;
        reset = 0;

        read_reg1 = 5'h2;
        read_reg2 = 5'h3;
        read_reg3 = 5'h5;
        read_regdest = 5'h4;
        write_reg = 5'h4;
        write_data = 32'h12345678;

        reg_write_enable = 1;
        #50;
        $display("Read Data 1: %h", read_data1);
        $display("Read Data 2: %h", read_data2);
        $display("Read Data 3: %h", read_data3);
        $display("Read Data 4: %h", read_data4);
        $finish;
    end
endmodule