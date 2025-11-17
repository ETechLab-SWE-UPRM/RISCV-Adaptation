`timescale 1ns/1ps
import fp_alu_pkg::*;

module fp_alu (
    input logic clk,
    input logic [31:0] a,
    input logic [31:0] b,
    input fp_alu_op_t fp_alu_op,
    input rm_t rm,

    output logic [31:0] result,
    output logic result_valid
);
    // Branching bits
    logic comp_a_valid, comp_b_valid;
    logic comp_a_ready, comp_b_ready;
    logic [7:0] comp_op;
    logic comp_op_valid, comp_op_ready;

    logic [7:0] comp_result;
    logic comp_result_valid;

    logic [31:0] itf_result;
    logic itf_a_valid, itf_result_valid;

    floating_point_branching fpbranch (
        .s_axis_a_tdata(a),
        .s_axis_b_tdata(b),
        .s_axis_a_tvalid(comp_a_valid),
        .s_axis_b_tvalid(comp_b_valid),
        .s_axis_operation_tdata(comp_op),
        .s_axis_operation_tvalid(comp_op_valid),
        .m_axis_result_tdata(comp_result),
        .m_axis_result_tvalid(comp_result_valid)
    );

    always_comb begin
        comp_a_valid = 1'b0;
        comp_b_valid = 1'b0;
        comp_op_valid = 1'b0;
        comp_op = 8'd64; // Default to NaN
        itf_a_valid = 1'b0;
        result = 32'd0;
        result_valid = 1'b0;

        unique case (fp_alu_op)
            FADD, FSUB : begin
            end

            FLT : begin
                comp_a_valid = 1'b1;
                comp_b_valid = 1'b1;
                comp_op_valid = 1'b1;
                comp_op = 8'b0;
            end

            FLE : begin
                comp_a_valid = 1'b1;
                comp_b_valid = 1'b1;
                comp_op_valid = 1'b1;
                comp_op = 8'b1;
            end

            FEQ : begin
                comp_a_valid = 1'b1;
                comp_b_valid = 1'b1;
                comp_op_valid = 1'b1;
                comp_op = 8'd2;
            end

            FMVWX : begin
                result = a;
            end

            FMEM : result = $signed(a) + $signed(b); 
            
        endcase

        if (comp_result_valid) begin
            result[7:0] = comp_result;
            result_valid = 1'b1;
        end

    end
endmodule