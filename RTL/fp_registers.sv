`timescale 1ns/1ps

module Floating_Point_registers #(
    parameter data_width = 32,
    parameter vec_length = 2
) (
    input logic clk, 
    input logic reset, 
    input logic [4:0] read_reg1,
    input logic [4:0] read_reg2,
    input logic [4:0] read_reg3,
    input logic [4:0] read_regdest,
    input logic [4:0] conv_write_reg_rs1,
    input logic [4:0] conv_write_reg_rs2,
    input logic [4:0] write_reg,
    input logic [data_width-1:0] write_data,
    input logic reg_write_enable,
    input logic conv_write_enable,
    input logic [data_width-1:0] conv_data_write [0:vec_length-1],
    input logic fp_mac_finished,
    input logic [4:0] fp_mac_reg_dest,
    input logic [31:0] fp_mac_data,

    output logic [data_width-1:0] read_data1,
    output logic [data_width-1:0] read_data2,
    output logic [data_width-1:0] read_data3,
    output logic [data_width-1:0] read_data4
);

    logic [data_width-1:0] fp_regs [0:31];

    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < 32; i++) begin
                fp_regs[i] <= 0;
            end
        end else begin
            if (reg_write_enable && conv_write_enable) begin
                fp_regs[write_reg] <= write_data;
                fp_regs[conv_write_reg_rs1] <= conv_data_write[0];
                fp_regs[conv_write_reg_rs2] <= conv_data_write[1];
            end else if (reg_write_enable) begin
                fp_regs[write_reg] <= write_data;
            end else if (conv_write_enable) begin
                fp_regs[conv_write_reg_rs1] <= conv_data_write[0];
                fp_regs[conv_write_reg_rs2] <= conv_data_write[1];
            end else if (fp_mac_finished) begin
                fp_regs[fp_mac_reg_dest] <= fp_mac_data;
            end
        end
    end

    always_comb begin
        if(reg_write_enable && (read_reg1 == write_reg)) begin
            read_data1 = write_data;
        end else begin
            read_data1 = fp_regs[read_reg1];
        end

        if(reg_write_enable && (read_reg2 == write_reg)) begin
            read_data2 = write_data;
        end else begin
            read_data2 = fp_regs[read_reg2];
        end

        if(reg_write_enable && (read_reg3 == write_reg)) begin
            read_data3 = write_data;
        end else begin
            read_data3 = fp_regs[read_reg3];
        end

        if(reg_write_enable && (read_regdest == write_reg)) begin
            read_data4 = write_data;
        end else begin
            read_data4 = fp_regs[read_regdest];
        end
    end
endmodule