module vector_registers #(
    parameter int vec_length = 2 
) (
    input logic clk, 
    input logic reset, 
    input logic [4:0] read_reg1,
    input logic [4:0] read_reg2,
    input logic [4:0] read_reg3,
    input logic [4:0] write_reg,
    input logic [31:0] write_data [0:vec_length-1],
    input logic reg_write_enable,

    output logic [31:0] read_data1 [0:vec_length-1],
    output logic [31:0] read_data2 [0:vec_length-1],
    output logic [31:0] read_data3 [0:vec_length-1]
);

logic [31:0] v_regs [0:31][0:vec_length-1];

always_ff @(posedge clk) begin
    for(int i = 0; i < vec_length; i++) begin
        if(reset) begin
            for (int j = 0; j < 32; j++) begin
                v_regs[j][i] <= 32'b0;
            end
        end else if (reg_write_enable) begin
            if (write_reg != 5'h0) begin
                v_regs[write_reg][i] <= write_data[i];
            end
        end
    end
end

always_comb begin
    for(int i = 0; i < vec_length; i++) begin
        if(reg_write_enable && (read_reg1 == write_reg)) begin
            read_data1[i] = write_data[i];
        end else begin
            read_data1[i] = v_regs[read_reg1][i];
        end

        if(reg_write_enable && (read_reg2 == write_reg)) begin
            read_data2[i] = write_data[i];
        end else begin
            read_data2[i] = v_regs[read_reg2][i];
        end

        if(reg_write_enable && (read_reg3 == write_reg)) begin
            read_data3[i] = write_data[i];
        end else begin
            read_data3[i] = v_regs[read_reg3][i];
        end
    end
end

endmodule