`timescale 1ns/1ps
import fp_alu_pkg::*;

typedef struct packed {
    logic sign;
    logic [7:0] exp;
    logic [23:0] frac;
    logic is_zero;
    logic is_inf;
    logic is_nan;
} unpacked_float_t;

typedef struct packed {
    logic [23:0] frac1;
    logic [23:0] frac2;
    logic [7:0] exp;
    logic [2:0] grs;
    logic sign1;
    logic sign2;
} aligned_pair_t;

// NaN yet to be implemented

function automatic unpacked_float_t unpack(input logic [31:0] num);
    unpacked_float_t result;
    result.sign = num[31];
    result.exp = num[30:23];
    result.frac = (result.exp == 0) ? {1'b0, num[22:0]} : {1'b1, num[22:0]};
    result.is_zero = (result.exp == '0 && num[22:0] == '0);
    result.is_inf = (result.exp == 8'hFF && num[22:0] == '0);
    result.is_nan = (result.exp == 8'hFF && num[22:0] != '0);

    $display("Unpacked: sign=%b, exp=%d, frac=%h, is_zero=%b, is_inf=%b, is_nan=%b", 
             result.sign, result.exp, result.frac, result.is_zero, result.is_inf, result.is_nan);

    return result;
endfunction

function automatic logic [31:0] round_func(
    input logic [23:0] mantissa, // Includes implicit leading 1
    input logic [7:0] exp,
    input logic sign,
    input logic [2:0] grs,
    input rm_t rm
);
    logic guard, round, sticky;
    logic round_up;

    {guard, round, sticky} = grs;

    unique case (rm)
        RNE : begin
            if(guard) begin
                if(round | sticky | mantissa[0]) begin
                    round_up = 1;
                end
            end
        end
        RTZ : begin
            round_up = 0;
        end
        RDN : begin
            if(sign && (guard | round | sticky)) begin
                round_up = 1;
            end
        end
        RUP : begin
            if(!sign && (guard | round | sticky)) begin
                round_up = 1;
            end
        end
        RMM : begin
            if(guard) begin
                round_up = 1;
            end
        end
        default: ;
    endcase

    // Overflow edge case
    if(round_up) begin
        mantissa = mantissa + 1;
        if(mantissa[24]) begin
            mantissa = mantissa >> 1;
            exp = exp + 1;
        end
    end

    return {sign, exp, mantissa[22:0]};
endfunction

function automatic aligned_pair_t align_exponents(input logic [31:0] num1, input logic [31:0] num2);
    aligned_pair_t result;
    unpacked_float_t uf1, uf2;
    logic [26:0] shifted_frac;
    logic [7:0] exp_diff;
    logic guard, round, sticky;

    uf1 = unpack(num1);
    uf2 = unpack(num2);

    // Align exponents
    if (uf1.exp > uf2.exp) begin
        exp_diff = uf1.exp - uf2.exp;
        shifted_frac = {uf2.frac, 3'b0} >> exp_diff;
        guard = shifted_frac[2];
        round = shifted_frac[1];
        sticky = |shifted_frac[2:0];
    
        result.frac1 = uf1.frac;
        result.frac2 = shifted_frac[26:3];
        result.grs = {guard, round, sticky};
        result.exp = uf1.exp;
    
    end else if (uf2.exp > uf1.exp) begin
        exp_diff = uf2.exp - uf1.exp;
        shifted_frac = {uf1.frac, 3'b0} >> exp_diff;
        guard = shifted_frac[2];
        round = shifted_frac[1];
        sticky = |shifted_frac[2:0];

        result.frac1 = shifted_frac[26:3];
        result.frac2 = uf2.frac;
        result.grs = {guard, round, sticky};
        result.exp = uf2.exp;
        
    end else begin // Not necessary
        result.frac1 = uf1.frac;
        result.frac2 = uf2.frac;
        result.grs = 3'b0;
        result.exp = uf1.exp;
    end

    result.sign1 = uf1.sign;
    result.sign2 = uf2.sign;

    $display("Aligned: frac1=%h, frac2=%h, grs=%b, exp=%d, sign1=%b, sign2=%b",
             result.frac1, result.frac2, result.grs, result.exp, result.sign1, result.sign2);

    return result;
endfunction

module fp_alu (
    input logic [31:0] a,
    input logic [31:0] b,
    input fp_alu_op_t fp_alu_op,
    input rm_t rm,

    output logic [31:0] result
);
    aligned_pair_t aligned_numbers;
    // Added 1 extra bit for potential overflow
    logic [24:0] mant_result;
    logic result_sign;
    logic [8:0] result_exp;

    assign result_exp = aligned_numbers.exp;

    always_comb begin
        aligned_numbers = align_exponents(a, b);

        unique case (fp_alu_op)
            FADD : begin
                if(aligned_numbers.sign1 == aligned_numbers.sign2) begin
                    mant_result = aligned_numbers.frac1 + aligned_numbers.frac2;
                    result_sign = aligned_numbers.sign1;

                end else begin
                    // Different signs, subtract smaller mantissa from larger mantissa
                    if (aligned_numbers.frac1 > aligned_numbers.frac2 ||
                        (aligned_numbers.frac1 == aligned_numbers.frac2 )) begin
                        
                        mant_result = aligned_numbers.frac1 - aligned_numbers.frac2;
                        result_sign = aligned_numbers.sign1;
                   
                    end else begin
                        mant_result = aligned_numbers.frac2 - aligned_numbers.frac1;
                        result_sign = aligned_numbers.sign2;
                    end
                end
                $display("FADD Mantissa Result: %b", mant_result);
            end

            FSUB : begin
                aligned_numbers.sign2 = ~aligned_numbers.sign2;
                if(aligned_numbers.sign1 == aligned_numbers.sign2) begin
                    mant_result = aligned_numbers.frac1 + aligned_numbers.frac2;
                    result_sign = aligned_numbers.sign1;
                end else begin
                    if (aligned_numbers.frac1 > aligned_numbers.frac2) begin
                        mant_result = aligned_numbers.frac1 - aligned_numbers.frac2;
                        result_sign = aligned_numbers.sign1;
                    end else begin
                        mant_result = aligned_numbers.frac2 - aligned_numbers.frac1;
                        result_sign = aligned_numbers.sign2;
                    end
                end
                $display("FSUB Mantissa Result: %b", mant_result);
            end

            FLE : begin
                
            end

            FLT : begin
                
            end

            FEQ : begin
                
            end
        endcase

        if(mant_result[24]) begin
            // Overflow, right shift and increment exponent
            mant_result = mant_result >> 1;
            aligned_numbers.exp = aligned_numbers.exp + 1;
        end else if (~mant_result[23]) begin
            // Underflow, Normalize by left shifting and decrementing exponent
            while(~mant_result[23] && aligned_numbers.exp >= 0) begin
                mant_result = mant_result << 1;
                aligned_numbers.exp = aligned_numbers.exp - 1;
            end
        end

        result = round_func(mant_result[23:0], aligned_numbers.exp, result_sign, aligned_numbers.grs, rm);
        $display("Final Result: %b", result);
    end
endmodule