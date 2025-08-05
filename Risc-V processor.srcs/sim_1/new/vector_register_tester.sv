`timescale 1ns / 1ps

module vreg_tester ();

    logic clk, reset;
    logic [4:0] read_reg1, read_reg2, read_reg3, write_reg;
    logic [31:0] write_data [0:1];
    logic reg_write_enable;
    logic [31:0] read_data1 [0:1], read_data2 [0:1], read_data3 [0:1];

    vector_registers #(
        .vec_length(2)
    ) v_test (
        .clk(clk),
        .reset(reset),
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
    always #5 clk = ~clk;

    initial begin 
        reset = 1;
        #10;
        reset = 0; 

        write_reg = 5'h1;
        write_data[0] = 32'hA1A1A1A1;
        write_data[1] = 32'hB2B2B2B2;
        reg_write_enable = 1;
        #20;
        
        write_reg = 5'h2;
        write_data[0] = 32'hC3C3C3C3;
        write_data[1] = 32'hD4D4D4D4;
        #20;

        write_reg = 5'h3;
        write_data[0] = 32'hE5E5E5E5;
        write_data[1] = 32'hF6F6F6F6;
        
        #20;
        reg_write_enable = 0;
        
        read_reg1 = 5'h1;
        read_reg2 = 5'h2;
        read_reg3 = 5'h3;
        #100;

        $finish;
    end

endmodule