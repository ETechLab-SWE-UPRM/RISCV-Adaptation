
module vector_ALU #(
    parameter vec_length = 2
) (
    input logic [31:0] a [0:vec_length-1],
    input logic [31:0] b [0:vec_length-1],
    input logic [31:0] c [0:vec_length-1],
    input logic [3:0] alu_control,
    output logic [31:0] result [0:vec_length-1]
);

logic [31:0] mac_result [0:vec_length-1];

genvar mac_num;
generate 
    for (mac_num = 0; mac_num < vec_length; mac_num++) begin : mac_block
        MAC_dsp vector_mac (
            .A(a[mac_num]),
            .B(b[mac_num]),
            .C(c[mac_num]),
            .P(mac_result[mac_num])
        );
    end
endgenerate

always_comb begin
    for(int i = 0; i < vec_length; i++) begin
        unique case (alu_control)
            4'b0000: result[i] = a[i] & b[i];   
            4'b0001: result[i] = a[i] | b[i];
            4'b0010: result[i] = a[i] + b[i];
            4'b0011: result[i] = a[i] << b[i][4:0];
            4'b0100: result[i] = a[i] ^ b[i];
            4'b0101: result[i] = a[i] >> b[i][4:0];
            4'b0110: result[i] = a[i] - b[i];
            4'b0111: result[i] = ($signed(a[i]) < $signed(b[i])) ? 32'b1 : 32'b0;
            4'b1001: result[i] = (a[i] < b[i]) ? 32'b1 : 32'b0;
            4'b1010: result[i] = a[i] >>> b[i][4:0];
            4'b1011: result[i] = mac_result[i];
            4'b1100: result[i] = 0;
            4'b1101: result[i] = 0;

            default: result[i] = 32'b0;
        endcase
    end
end

endmodule