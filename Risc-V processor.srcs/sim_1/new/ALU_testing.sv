`timescale 1ns/1ps

module ALU_stimulus ();

    logic clk, reset;
    logic [31:0] a, b, c;
    logic [3:0] alu_control;
    logic [31:0] result;
    logic zero;

    ALU alu_inst (
        .a(a),
        .b(b),
        .c(c),
        .alu_control(alu_control),
        .result(result),
        .zero(zero)
    );

    initial clk = 0;
    always #5 clk = ~clk; // Clock period of 10 time units

    initial begin
        a = 32'h5;
        b = 32'h2;
        c = 32'h0;
        alu_control = 4'b1011; // MAC

        #10;

        c = 32'ha;

        #10;

        c = 32'h14;

        #10;

        a = 32'h2;
        b = 32'h0;
        c = 32'h0;
        alu_control = 4'b0010; // Addition
    end

endmodule