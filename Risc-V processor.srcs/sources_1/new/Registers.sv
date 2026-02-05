import fp_fma_pkg::*;

module Registers(
    input logic clk,
    input logic reset,
    input fp_fma_t fp_mac,
    input logic [4:0] read_reg1,
    input logic [4:0] read_reg2,
    input logic [4:0] read_reg3, 
    input logic [4:0] write_reg,
    input logic [31:0] write_data,
    input logic conv_write_enable,
    input logic [31:0] conv_data_write,
    input logic [31:0] conv_weights_write,
    input logic reg_write_enable,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2,
    output logic [31:0] read_data3,
    output logic [31:0] conv_data_read,
    output logic [31:0] conv_weights_read
);
    logic [31:0] regs [31:0];
    localparam a0 = 5'd10;
    localparam a1 = 5'd11;

    always_ff @(posedge clk) begin
        if(reset) begin
            for (int i = 0; i < 32; i++) begin
                regs[i] <= 32'b0;
            end
        end else begin
            if (reg_write_enable && write_reg != 5'h0) begin
                regs[write_reg] <= write_data;
            end 
            
            // Has priority over normal register writes for a0 and a1
            if(conv_write_enable) begin
                regs[a0] <= conv_data_write;
                regs[a1] <= conv_weights_write;
            end
        end
    end

    always_comb begin
        conv_data_read = 32'b0;
        conv_weights_read = 32'b0;
        
        if(reg_write_enable && (read_reg1 == write_reg)) begin
            read_data1 = write_data;
        end else begin
            read_data1 = regs[read_reg1];
        end

        if(reg_write_enable && (read_reg2 == write_reg)) begin
            read_data2 = write_data;
        end else begin
            read_data2 = regs[read_reg2];
        end

        if(reg_write_enable && (read_reg3 == write_reg)) begin
            read_data3 = write_data;
        end else begin
            read_data3 = regs[read_reg3];
        end

        if(fp_mac == FMADD) begin
            if(reg_write_enable && (a0 == write_reg)) begin
                conv_data_read = write_data;
            end else begin
                conv_data_read = regs[a0];
            end

            if(reg_write_enable && (a1 == write_reg)) begin
                conv_weights_read = write_data;
            end else begin
                conv_weights_read = regs[a1];
            end
            end
    end
endmodule