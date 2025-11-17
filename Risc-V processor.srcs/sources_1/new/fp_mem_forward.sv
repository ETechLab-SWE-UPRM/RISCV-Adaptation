`timescale 1ns/1ps

module fp_mem_forward (
    input logic [4:0] ex_mem_mac_dest,
    input logic mem_wb_fp_mac,
    input logic [4:0] mem_wb_rd,

    output logic forward_mem_fp
);

    always_comb begin
        forward_mem_fp = mem_wb_fp_mac && (mem_wb_rd == ex_mem_mac_dest);
    end

endmodule