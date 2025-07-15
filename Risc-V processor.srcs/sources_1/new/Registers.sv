

module Registers(
    input logic clk,
    input logic reset,
    input logic [4:0] read_reg1,
    input logic [4:0] read_reg2,
    input logic [4:0] read_reg3, 
    input logic [4:0] write_reg,
    input logic [31:0] write_data,
    input logic reg_write_enable,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2,
    output logic [31:0] read_data3
);
    logic [31:0] regs [31:0];

    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            for (int i = 0; i < 32; i++) begin
                regs[i] <= 32'b0;
            end
        end else if(reg_write_enable) begin
            if (write_reg != 5'h0) begin
                regs[write_reg] <= write_data;
            end
        end
    end

    always_comb begin
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
    end
endmodule