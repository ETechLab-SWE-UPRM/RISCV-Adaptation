import fp_fma_pkg::*;

module MEM_WB_reg #(
    parameter vec_length = 2
) (
    input logic clk,
    input logic reset,
    input logic ex_mem_vec_op,
    input logic ex_mem_fp_instruction,
    input logic ex_mem_rd_is_int,
    input fp_fma_t ex_mem_fmat_type,
    input logic ex_mem_fp_reg_write,
    input logic ex_mem_vec_reg_write,
    input logic ex_mem_memtoreg,
    input logic uart_instruction,
    input logic timer_instruction,
    input logic spi_instruction,
    input logic ex_mem_regwrite,
    input logic ex_mem_jal,
    input logic ex_mem_jalr,
    input logic [31:0] ex_mem_alu_result [0:vec_length-1],
    input logic [31:0] memory_data_read [0:vec_length-1],
    input logic [31:0] uart_memory [0:vec_length-1],
    input logic [31:0] timer_value,
    input logic [31:0] spi_memory,
    input logic [4:0] ex_mem_rs1,
    input logic [4:0] ex_mem_rs2,
    input logic [4:0] ex_mem_reg_dest,
    input logic [31:0] ex_mem_link_address_reg,
    input logic [31:0] ex_mem_conv_addr,
    input logic [31:0] ex_mem_weights_addr,

    output logic mem_wb_vec_op,
    output logic mem_wb_fp_instruction,
    output logic mem_wb_rd_is_int,
    output fp_fma_t mem_wb_fmat_type,
    output logic mem_wb_fp_reg_write,
    output logic mem_wb_vec_reg_write,
    output logic mem_wb_memtoreg,
    output logic mem_wb_regwrite,
    output logic mem_wb_jal,
    output logic mem_wb_jalr,
    output logic [31:0] mem_wb_alu_result [0:vec_length-1],
    output logic [31:0] mem_wb_memory_data_read [0:vec_length-1],
    output logic [31:0] mem_wb_uart_memory [0:vec_length-1],
    output logic [31:0] mem_wb_timer_value,
    output logic [4:0] mem_wb_rs1,
    output logic [4:0] mem_wb_rs2,
    output logic [4:0] mem_wb_reg_dest,
    output logic [31:0] mem_wb_link_address,
    output logic [31:0] mem_wb_write_data [0:vec_length-1],
    output logic [31:0] mem_wb_conv_addr,
    output logic [31:0] mem_wb_weights_addr
);
    logic uart_instruction_reg;
    logic timer_instruction_reg;
    logic spi_instruction_reg;

    logic [31:0] mem_wb_spi_memory;

    always_ff @(posedge clk) begin
        if (reset) begin
            mem_wb_vec_op <= 1'b0;
            mem_wb_fp_instruction <= 1'b0;
            mem_wb_rd_is_int <= 1'b0;
            mem_wb_fmat_type <= FM_NONE;
            mem_wb_fp_reg_write <= 1'b0;
            mem_wb_vec_reg_write <= 1'b0;
            mem_wb_memtoreg <= 1'b0;
            uart_instruction_reg <= 1'b0;
            timer_instruction_reg <= 1'b0;
            spi_instruction_reg <= 1'b0;
            mem_wb_regwrite <= 1'b0;
            mem_wb_jal <= 1'b0;
            mem_wb_jalr <= 1'b0;
            mem_wb_alu_result <= '{default: 32'b0};
            mem_wb_rs1 <= 5'b0;
            mem_wb_rs2 <= 5'b0;
            mem_wb_reg_dest <= 5'b0;
            mem_wb_link_address <= 32'b0;
            mem_wb_memory_data_read <= '{default: 32'b0};
            mem_wb_uart_memory <= '{default: 32'b0};
            mem_wb_spi_memory <= '0;
            mem_wb_timer_value <= 32'b0;
            mem_wb_conv_addr <= 32'b0;
            mem_wb_weights_addr <= 32'b0;

        end else begin
            mem_wb_vec_op <= ex_mem_vec_op;
            mem_wb_fp_instruction <= ex_mem_fp_instruction;
            mem_wb_rd_is_int <= ex_mem_rd_is_int;
            mem_wb_fmat_type <= ex_mem_fmat_type;
            mem_wb_fp_reg_write <= ex_mem_fp_reg_write;
            mem_wb_vec_reg_write <= ex_mem_vec_reg_write;
            mem_wb_memtoreg <= ex_mem_memtoreg;
            uart_instruction_reg <= uart_instruction;
            timer_instruction_reg <= timer_instruction;
            spi_instruction_reg <= spi_instruction;
            mem_wb_regwrite <= ex_mem_regwrite;
            mem_wb_jal <= ex_mem_jal;
            mem_wb_jalr <= ex_mem_jalr;
            mem_wb_alu_result <= ex_mem_alu_result;
            mem_wb_rs1 <= ex_mem_rs1;
            mem_wb_rs2 <= ex_mem_rs2;
            mem_wb_reg_dest <= ex_mem_reg_dest;
            mem_wb_link_address <= ex_mem_link_address_reg; 
            mem_wb_memory_data_read <= memory_data_read;
            mem_wb_uart_memory <= uart_memory;
            mem_wb_timer_value <= timer_value;
            mem_wb_spi_memory <= spi_memory;
            mem_wb_conv_addr <= ex_mem_conv_addr;
            mem_wb_weights_addr <= ex_mem_weights_addr;
        end
    end

    always_comb begin 
        if (mem_wb_jal || mem_wb_jalr) begin
            mem_wb_write_data[0] = mem_wb_link_address;
            for (int i = 1; i < vec_length; i++) begin
                mem_wb_write_data[i] = 32'b0; // Other vector elements are not used in JAL/JALR
            end
        end else if(mem_wb_memtoreg && timer_instruction_reg) begin
            mem_wb_write_data[0] = mem_wb_timer_value;
            for (int i = 1; i < vec_length; i++) begin
                mem_wb_write_data[i] = 32'b0;
            end
        end else if(mem_wb_memtoreg && uart_instruction_reg) begin
            mem_wb_write_data = mem_wb_uart_memory; 
        end else if(mem_wb_memtoreg && spi_instruction_reg) begin
            mem_wb_write_data[0] = mem_wb_spi_memory;

            for (int i = 1; i < vec_length; i++) begin
                mem_wb_write_data[i] = 32'b0;
            end
        end else if (mem_wb_memtoreg) begin // Regular load instructions get value directly from memory; cause read_latency = 1
            mem_wb_write_data = memory_data_read;
        end else begin
            mem_wb_write_data = mem_wb_alu_result; 
        end
    end

endmodule