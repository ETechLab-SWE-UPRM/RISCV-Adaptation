`timescale 1ns/1ps
import fp_fma_pkg::*;

module fp_control (
    input logic [6:0] opcode,
    input logic [2:0] funct3,
    input logic [6:0] funct7,

    output logic fp_instruction,
    output logic [1:0] fp_op,
    output logic fp_alu_src,
    output logic fp_reg_write, 
    output logic fp_load, 
    output logic fp_store,
    output fp_fma_t fmat_type
);

    always_comb begin
        fp_alu_src = 1'b0;
        fp_reg_write = 1'b0;
        fp_load = 1'b0;
        fp_store = 1'b0;
        fp_op = '0;
        fmat_type = FM_NONE;
        fp_instruction = 1'b0;
        
        case (opcode)
            7'b0100111 : begin
                fp_op = 2'b01;
                fp_alu_src = 1'b1;
                fp_store = 1'b1;
                fp_instruction = 1'b1;
            end

            7'b0000111: begin
                fp_op = 2'b01;
                fp_alu_src = 1'b1;
                fp_load = 1'b1;
                fp_reg_write = 1'b1;
                fp_instruction = 1'b1;
            end

            7'b1000011: begin
                fp_op = 2'b00;
                fmat_type = FMADD;
                fp_reg_write = 1'b1;
                fp_instruction = 1'b1;
            end

            7'b1001111: begin
                fp_op = 2'b00;
                fmat_type = FNMADD;
                fp_reg_write = 1'b1;
                fp_instruction = 1'b1;
            end

            7'b1010011: begin
                fp_op = 2'b10;
                fp_reg_write = 1'b1;
                fp_instruction = 1'b1;
            end

            default : begin
                fp_alu_src = 1'b0;
                fp_reg_write = 1'b0;
                fp_load = 1'b0;
                fp_store = 1'b0;
                fp_op = 1'b0;
                fmat_type = FM_NONE;
                fp_instruction = 1'b0;
            end
        endcase
    end
endmodule