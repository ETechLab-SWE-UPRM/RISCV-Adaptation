

module MEM_WB_reg (
    input logic clk,
    input logic reset,
    input logic ex_mem_memtoreg,
    input logic ex_mem_regwrite,
    input logic ex_mem_jal,
    input logic ex_mem_jalr,
    input logic [31:0] ex_mem_alu_result,
    input logic [31:0] memory_data_read,
    input logic [4:0] ex_mem_reg_dest,
    input logic [31:0] ex_mem_link_address_reg,

    output logic mem_wb_memtoreg,
    output logic mem_wb_regwrite,
    output logic mem_wb_jal,
    output logic mem_wb_jalr,
    output logic [31:0] mem_wb_alu_result,
    output logic [31:0] mem_wb_memory_data_read,
    output logic [4:0] mem_wb_reg_dest,
    output logic [31:0] mem_wb_link_address,
    output logic [31:0] mem_wb_write_data
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            mem_wb_memtoreg <= 1'b0;
            mem_wb_regwrite <= 1'b0;
            mem_wb_jal <= 1'b0;
            mem_wb_jalr <= 1'b0;
            mem_wb_alu_result <= 32'b0;
            mem_wb_memory_data_read <= 32'b0;
            mem_wb_reg_dest <= 5'b0;
            mem_wb_link_address <= 32'b0;

        end else begin
            mem_wb_memtoreg <= ex_mem_memtoreg;
            mem_wb_regwrite <= ex_mem_regwrite;
            mem_wb_jal <= ex_mem_jal;
            mem_wb_jalr <= ex_mem_jalr;
            mem_wb_alu_result <= ex_mem_alu_result;
            mem_wb_memory_data_read <= memory_data_read;
            mem_wb_reg_dest <= ex_mem_reg_dest;
            mem_wb_link_address <= ex_mem_link_address_reg; 
        end
    end


    always_comb begin 
        if (mem_wb_jal || mem_wb_jalr) begin
            mem_wb_write_data = mem_wb_link_address;
        end else if(mem_wb_memtoreg) begin
            mem_wb_write_data = mem_wb_memory_data_read; 
        end else begin
            mem_wb_write_data = mem_wb_alu_result; 
        end
    end

endmodule