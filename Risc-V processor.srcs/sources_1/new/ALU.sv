
module ALU (
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [3:0] alu_control,

    output logic [31:0] result,    
    output logic zero
);

    always_comb begin
        unique case (alu_control)
            4'b0000: result = a & b;   
            4'b0001 : result = a | b;
            4'b0010: result = a + b;
            4'b0011: result = a << b[4:0];
            4'b0100: result = a ^ b;
            4'b0101: result = a >> b[4:0];
            4'b0110: result = a - b;
            4'b0111: result = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
            4'b1001: result = (a < b) ? 32'b1 : 32'b0;
            4'b1010: result = a >>> b[4:0];
            4'b1011: result = 32'b0;
            4'b1100: result = 32'b0; 
            4'b1101: result = 32'b0;
            
            default: result = 32'b0;
        endcase
        
        zero = (result == 32'b0);
    end

endmodule