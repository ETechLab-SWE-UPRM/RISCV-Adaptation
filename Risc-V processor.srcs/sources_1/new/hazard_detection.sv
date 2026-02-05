
module Hazard_Detection (
    input logic clk, 
    input logic reset,
    input logic [4:0] if_id_rs1, if_id_rs2,
    input logic [4:0] reg_dest_id_ex,
    input logic id_ex_mem_read, id_ex_vec_op,
    input logic if_id_vec_op,

    output logic stall, pc_write, if_id_write
);

    logic hazard1, hazard2;
    logic stall_pending;

    always_ff @(posedge clk) begin
        if (reset) begin
            stall_pending <= 1'b0;
        end else begin
            if ((hazard1 || hazard2) && !stall_pending) begin
                stall_pending <= 1'b1;
            end else if (stall_pending) begin
                stall_pending <= 1'b0;
            end
        end
    end

    assign hazard1 =  (id_ex_mem_read && (if_id_vec_op == id_ex_vec_op) && 
        (((if_id_rs1 != 5'b0) && (if_id_rs1 == reg_dest_id_ex))));
    
    assign hazard2 =  (id_ex_mem_read && (if_id_vec_op == id_ex_vec_op) && 
        (((if_id_rs2 != 5'b0) && (if_id_rs2 == reg_dest_id_ex))));

    always_comb begin
        stall = 1'b0;
        pc_write = 1'b1;
        if_id_write = 1'b1;

        if(hazard1 || hazard2 || stall_pending) begin
            stall = 1'b1; 
            pc_write = 1'b0; 
            if_id_write = 1'b0; 
        end
    end

endmodule