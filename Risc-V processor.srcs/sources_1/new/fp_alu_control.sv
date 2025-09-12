`timescale 1ns/1ps
import fp_alu_pkg::*;

module fp_alu_control (
    input logic [1:0] fp_op,
    input logic [6:0] funct7, 
    input logic [2:0] funct3,

    output fp_alu_op_t fp_alu_op,
    output logic [2:0] rm
);

    always_comb begin
        rm = funct3;
        fp_alu_op = '0;
        unique case (fp_op)
            2'b00: ;

            2'b01: begin
                fp_alu_op = FADD;
            end

            2'b10: begin
                case (funct7)
                    7'b0: fp_alu_op = FADD;
                    7'b1: fp_alu_op = FSUB;
                    7'b1010000: begin
                        case (funct3)
                            3'b0 : fp_alu_op = FLE;
                            3'b1 : fp_alu_op = FLT;
                            3'b010: fp_alu_op = FEQ;
                            default: ; 
                        endcase
                    end 
                    default: ;
                endcase
            end
        endcase
    end
endmodule