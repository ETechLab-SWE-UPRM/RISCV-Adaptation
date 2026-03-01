
module Immediate_generator #(
  parameter int XLEN = 32   // data-path width
) (
  input  logic [31:0] instruction,     
  output logic [XLEN-1:0] immediate     // sign-extended, properly shifted
);

  always_comb begin
    unique case (instruction[6:0])
      // I-type: loads, OP-IMM, JALR
      7'b0000011, // LOAD
      7'b0010011, // OP-IMM
      7'b0001011, // OP-IMM (vector)
      7'b0101011, // STORE (vector)
      7'b1100111: // JALR
        immediate = {{(XLEN-12){instruction[31]}}, instruction[31:20]};

      // stores
      7'b0100011:
        immediate = {{(XLEN-12){instruction[31]}},
                     instruction[31:25], instruction[11:7]};

      // branches, includes shifted bit
      7'b1100011:
        immediate = {{(XLEN-13){instruction[31]}},  // sign-extend bit 12
                     instruction[31],               // imm[12]
                     instruction[7],                // imm[11]
                     instruction[30:25],            // imm[10:5]
                     instruction[11:8],             // imm[4:1]
                     1'b0};                         // imm[0] = 0

      // U-type: LUI / AUIPC (upper 20 bits, low 12 = 0)
      7'b0110111, // LUI
      7'b1111011, // AUIPC (vector)
      7'b0010111: // AUIPC
        immediate = {{(XLEN-32){instruction[31]}},
                     instruction[31:12], 12'b0};

      // J-type: JAL
      7'b1101111:
        immediate = {{(XLEN-21){instruction[31]}},  // sign-extend bit 20
                     instruction[31],               // imm[20]
                     instruction[19:12],            // imm[19:12]
                     instruction[20],               // imm[11]
                     instruction[30:21],            // imm[10:1]
                     1'b0};                         // imm[0] = 0

      // FLW
      7'b0000111:
        immediate = {{(XLEN-12){instruction[31]}},
                     instruction[31:20]};

      // FSW
      7'b0100111:
        immediate = {{(XLEN-12){instruction[31]}},
                     instruction[31:25], instruction[11:7]};

      default:
        immediate = '0;
    endcase
  end

endmodule
