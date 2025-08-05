`timescale 1ns / 1ps

module hd_tester ();

    logic clk; 
    logic [4:0] if_id_rs1, if_id_rs2, if_id_rs3;
    logic [4:0] reg_dest_id_ex;
    logic id_ex_mem_read;
    logic stall, pc_write_, if_id_write;

    Hazard_Detection hd (
        .if_id_rs1(if_id_rs1),
        .if_id_rs2(if_id_rs2),
        .if_id_rs3(if_id_rs3),
        .reg_dest_id_ex(reg_dest_id_ex),
        .id_ex_mem_read(id_ex_mem_read),
        .stall(stall),
        .pc_write_(pc_write_),
        .if_id_write(if_id_write)
    );

    initial clk = 0;
    always #5 clk = ~clk; // Clock toggles every 5 time units

    initial begin
        // No hazard
        if_id_rs1 = 5'b00001; // rs1
        if_id_rs2 = 5'b00010; // rs2
        if_id_rs3 = 5'b00011; // rs3
        reg_dest_id_ex = 5'b00100; // Destination register in ID/EX stage
        id_ex_mem_read = 1'b0; // No memory read in ID/EX stage
        #10; // Wait for a clock cycle

        // Hazard detected
        if_id_rs1 = 5'b00001; // rs1
        if_id_rs2 = 5'b00010; // rs2
        if_id_rs3 = 5'b00011; // rs3
        reg_dest_id_ex = 5'b00001; // Destination register in ID/EX stage matches rs1
        id_ex_mem_read = 1'b1; // Memory read in ID/EX stage
        #10; // Wait for a clock cycle
        
        // Another hazard detected
        if_id_rs1 = 5'b00001; // rs1
        if_id_rs2 = 5'b00010; // rs2
        if_id_rs3 = 5'b00011; // rs3
        reg_dest_id_ex = 5'b00010; // Destination register in ID/EX stage matches rs2
        id_ex_mem_read = 1'b1; // Memory read in ID/EX stage
        #10; // Wait for a clock cycle
    
        // No hazard in between
        reg_dest_id_ex = 5'b00011;
        id_ex_mem_read = 1'b0;
        #10;
    
        // Third Hazard detected 
        reg_dest_id_ex = 5'b00011;
        id_ex_mem_read = 1'b1;
        #10;
    end

endmodule