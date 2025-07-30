

module ALU_control (
   input logic [1:0] alu_op,
   input logic [2:0] funct3,
   input logic alu_src,
   input logic funct7,
   input logic funct7_mac,

   output logic is_mac,
   output logic [3:0] alu_control  
);
    
    always_comb begin
        alu_control = 4'b0;
        is_mac = 1'b0;
        case (alu_op)
            2'b00 : alu_control = 4'b0010;

            2'b01 : alu_control = 4'b0110;

            2'b10: begin
                if(!alu_src) begin
                    unique case ({funct7, funct7_mac, funct3})
                        5'b00_111 : alu_control = 4'b0000;
                        5'b00_110 : alu_control = 4'b0001;
                        5'b00_000 : alu_control = 4'b0010;
                        5'b00_001 : alu_control = 4'b0011;
                        5'b00_100 : alu_control = 4'b0100;
                        5'b00_101 : alu_control = 4'b0101;
                        5'b10_000 : alu_control = 4'b0110;
                        5'b00_010 : alu_control = 4'b0111;
                        5'b00_011 : alu_control = 4'b1001;
                        5'b10_101 : alu_control = 4'b1010;
                        5'b01_000 : begin
                            is_mac = 1'b1;
                            alu_control = 4'b1011;                        
                        end
                        5'b01_100 : alu_control = 4'b1100; // not used
                        5'b01_101 : alu_control = 4'b1101; // not used
                        default: alu_control = 4'b0;
                    endcase
                end else begin
                    unique case (funct3)
                        3'b000: alu_control = 4'b0010;
                        3'b001: alu_control = 4'b0011;
                        3'b010: alu_control = 4'b0111;
                        3'b011: alu_control = 4'b1001;
                        3'b100: alu_control = 4'b0100;
                        3'b101: alu_control = 4'b0101;
                        3'b110: alu_control = 4'b0001;
                        3'b111: alu_control = 4'b0000;
                        3'b110: alu_control = 4'b1010;
                        default: alu_control = 4'b0;
                    endcase
                end
            end

            // 11 not used
            default: alu_control = '0; 
        endcase
    end
endmodule