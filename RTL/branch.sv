
module branch (
    input logic [31:0] pc, read_data1, read_data2,
    input logic [31:0] big_immediate, 
    input logic branch, beq, bne, blt, bge, jal, jalr,
    output logic [31:0] next_pc,
    output logic branch_taken
);

    logic less, greater, nequal, equal;
    logic [31:0] branch_target;
    logic [31:0] jalr_target;

    assign less = (read_data1 < read_data2);
    assign greater = (read_data1 >= read_data2);
    assign nequal = (read_data1 != read_data2);
    assign equal = (read_data1 == read_data2);

    assign branch_target = pc + big_immediate; 
    assign jalr_target = (read_data1 + big_immediate) & ~32'b1;

    assign branch_taken = ((branch && 
        ((beq && equal) || (bne && nequal) || (less && blt) || (greater && bge))) || jal || jalr);

    assign next_pc = (jal ? branch_target : 
                    jalr ? jalr_target : 
                    branch_taken ? branch_target : 
                    pc + 4);
endmodule