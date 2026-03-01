`timescale 1ns / 1ps

module v_ALU_tester ();

    logic clk, reset;

    logic [31:0] a [0:1], b [0:1], c [0:1];
    logic [3:0] alu_control;
    logic [31:0] result [0:1];

    vector_ALU #(
        .vec_length(2)
    ) v_alu (
        .a(a),
        .b(b),
        .c(c),
        .alu_control(alu_control),
        .result(result)
    );

    initial clk = 0; 
    always #5 clk = ~clk;

    initial begin
        reset = 1;
        #20; 
        reset = 0;

        a[0] = 32'h00000001; 
        a[1] = 32'h00000002;
        b[0] = 32'h00000003; 
        b[1] = 32'h00000004;
        c[0] = 32'h00000005; 
        c[1] = 32'h00000006;

        alu_control = 4'b0000; 
        #10;
        
        alu_control = 4'b0001; 
        #10;

        alu_control = 4'b0010; 
        #10;

        alu_control = 4'b0011; 
        #10;

        alu_control = 4'b0100; 
        #10;

        alu_control = 4'b0101; 
        #10;

        alu_control = 4'b0110; 
        #10;

        alu_control = 4'b0111; 
        #10;

        alu_control = 4'b1001; 
        #10;

        alu_control = 4'b1010; 
        #10;

        alu_control = 4'b1011; 
        #10;

        $finish;
    end

endmodule