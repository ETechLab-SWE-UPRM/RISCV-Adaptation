`timescale 1ns/1ps

module fp_control_tester ();
    logic clk, reset;
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    logic [1:0] fp_op;
    fp_alu_op_t fp_alu_op;
    rm_t rm;
    logic fp_alu_src;
    logic fp_reg_write;
    logic fp_load;
    logic fp_store;
    fp_fma_t fmat_type;

    fp_control control (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .fp_op(fp_op),
        .fp_alu_src(fp_alu_src),
        .fp_reg_write(fp_reg_write),
        .fp_load(fp_load),
        .fp_store(fp_store),
        .fmat_type(fmat_type)
    );

    fp_alu_control fp_alu_control (
        .fp_op(fp_op),
        .funct7(funct7),
        .funct3(funct3),
        .fp_alu_op(fp_alu_op),
        .rm(rm)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 1;
        #10;
        reset = 0;

        // Test FADD instruction
        opcode = 7'b1010011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #20;

        // Test FSUB instruction
        opcode = 7'b1010011;
        funct3 = 3'b000;
        funct7 = 7'b0000100;
        #20;

        // Test FLE instruction
        opcode = 7'b1010011;
        funct3 = 3'b000;
        funct7 = 7'b1010000;
        #20;

        // Test FLT instruction
        opcode = 7'b1010011;
        funct3 = 3'b001;
        funct7 = 7'b1010000;
        #20;

        // Test FEQ instruction
        opcode = 7'b1010011;
        funct3 = 3'b010;
        funct7 = 7'b1010000;
        #20;

        // Test Load instruction
        opcode = 7'b0000111;
        funct3 = 3'b010;
        funct7 = 7'b1010100; // Simulating garbage funct7 for load, should be ignored
        #20;

        // Test Store instruction
        opcode = 7'b0100111;
        funct3 = 3'b010;
        funct7 = 7'b0000000;
        #20;

        // Test FMADD instruction
        opcode = 7'b1000011;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        #20;
        $finish;
    end
endmodule