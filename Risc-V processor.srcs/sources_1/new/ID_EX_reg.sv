
module ID_EX_reg (
    input logic clk, 
    input logic reset, 
    input logic flush,
    input logic branch,
    input logic beq,
    input logic bne,
    input logic blt,
    input logic bge,
    input logic mem_read,
    input logic memtoreg,
    input logic mem_write,
    input logic alu_src,
    input logic reg_write,
    input logic jal,
    input logic jalr,
    input logic auipc,
    input logic [1:0] alu_op,
    input logic [31:0] pc_if_id,
    input logic [31:0] instruction_if_id,
    input logic [31:0] big_immediate,
    input logic [4:0] reg1,
    input logic [4:0] reg2,
    input logic [4:0] reg_dest,
    input logic [2:0] funct3,
    input logic [6:0] funct7,
    input logic [31:0] data_read1,
    input logic [31:0] data_read2,
    input logic [31:0] data_read3,

    output logic [31:0] pc_id_ex,
    output logic [31:0] instruction_id_ex,
    output logic id_ex_branch,
    output logic id_ex_beq,
    output logic id_ex_bne,
    output logic id_ex_blt,
    output logic id_ex_bge,
    output logic id_ex_mem_read,
    output logic id_ex_memtoreg,
    output logic id_ex_mem_write,
    output logic id_ex_alu_src,
    output logic id_ex_reg_write,
    output logic id_ex_jal,
    output logic id_ex_jalr,
    output logic id_ex_auipc,
    output logic [1:0] id_ex_alu_op,
    output logic [31:0] data_read1_id_ex,
    output logic [31:0] data_read2_id_ex,
    output logic [31:0] data_read3_id_ex,
    output logic [31:0] big_immediate_id_ex,
    output logic [4:0] reg_dest_id_ex,
    output logic [4:0] reg2_id_ex,
    output logic [4:0] reg1_id_ex,
    output logic [2:0] funct3_id_ex,
    output logic [6:0] funct7_id_ex
    
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_id_ex <= 32'b0;
            instruction_id_ex <= 32'b0;
            id_ex_branch <= 1'b0;
            id_ex_beq <= 1'b0;
            id_ex_bne <= 1'b0;
            id_ex_blt <= 1'b0;
            id_ex_bge <= 1'b0;
            id_ex_mem_read <= 1'b0;
            id_ex_memtoreg <= 1'b0;
            id_ex_mem_write <= 1'b0;
            id_ex_alu_src <= 1'b0;
            id_ex_reg_write <= 1'b0;
            id_ex_jal <= 1'b0;
            id_ex_jalr <= 1'b0;
            id_ex_auipc <= 1'b0;
            id_ex_alu_op <= 2'b0;
            data_read1_id_ex <= 32'b0;
            data_read2_id_ex <= 32'b0;
            data_read3_id_ex <= 32'b0; 
            big_immediate_id_ex <= 32'b0;
            reg_dest_id_ex <= 5'b0;
            reg2_id_ex <= 5'b0;
            reg1_id_ex <= 5'b0;
            funct3_id_ex <= 3'b0;
            funct7_id_ex <= 7'b0;
            
        end else if (flush) begin
            pc_id_ex <= 32'b0;
            instruction_id_ex <= 32'h13;
            id_ex_branch <= 1'b0;
            id_ex_beq <= 1'b0;
            id_ex_bne <= 1'b0;
            id_ex_blt <= 1'b0;
            id_ex_bge <= 1'b0;
            id_ex_mem_read <= 1'b0;
            id_ex_memtoreg <= 1'b0;
            id_ex_mem_write <= 1'b0;
            id_ex_alu_src <= 1'b0;
            id_ex_reg_write <= 1'b0;
            id_ex_jal <= 1'b0;
            id_ex_jalr <= 1'b0;
            id_ex_auipc <= 1'b0;
            id_ex_alu_op <= 2'b0;
            data_read1_id_ex <= 32'b0;
            data_read2_id_ex <= 32'b0;
            data_read3_id_ex <= 32'b0; 
            big_immediate_id_ex <= 32'b0;
            reg_dest_id_ex <= 5'b0;
            reg2_id_ex <= 5'b0;
            reg1_id_ex <= 5'b0;
            funct3_id_ex <= 3'b0;
            funct7_id_ex <= 7'b0;

        end else begin

            pc_id_ex <= pc_if_id; 
            instruction_id_ex <= instruction_if_id;
            id_ex_branch <= branch;
            id_ex_beq <= beq;
            id_ex_bne <= bne;
            id_ex_blt <= blt;
            id_ex_bge <= bge;
            id_ex_mem_read <= mem_read;
            id_ex_memtoreg <= memtoreg;
            id_ex_mem_write <= mem_write;
            id_ex_alu_src <= alu_src;
            id_ex_reg_write <= reg_write;
            id_ex_jal <= jal;
            id_ex_jalr <= jalr;
            id_ex_auipc <= auipc;
            id_ex_alu_op <= alu_op;
            data_read1_id_ex <= data_read1;
            data_read2_id_ex <= data_read2;
            data_read3_id_ex <= data_read3;
            big_immediate_id_ex <= big_immediate;
            reg_dest_id_ex <= reg_dest;
            reg1_id_ex <= reg1;
            reg2_id_ex <= reg2;
            funct3_id_ex <= funct3;
            funct7_id_ex <= funct7;
        end
    end
endmodule