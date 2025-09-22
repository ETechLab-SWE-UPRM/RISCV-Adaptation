`timescale 1ns/1ps

module fp_alu_testing ();
    
    logic clk;
    logic reset;
    logic [31:0] a, b;
    fp_alu_op_t fp_alu_op;
    rm_t rm;
    logic [31:0] result;

    fp_alu fp_alu (
        .clk(clk),
        .a(a),
        .b(b),
        .fp_alu_op(fp_alu_op),
        .rm(rm),
        .result(result)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 1;
        #10;
        reset = 0;

        // Test FADD operation
        a = 32'h414a6666; // 12.65
        b = 32'h41026666; // 8.15
        fp_alu_op = FADD;
        rm = RTZ;
        #100;
        fp_alu_op = FSUB;
        #100;
        fp_alu_op = FLT;
        #100;
        fp_alu_op = FLE;
        #100;
        fp_alu_op = FEQ;
        #100;
        $finish;
    end

endmodule