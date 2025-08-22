
module Control (
    input logic [6:0] opcode,
    input logic [2:0] funct3,

    output logic vec_op,
    output logic vec_reg_write,
    output logic continous_addr,
    output logic single_load,
    output logic branch,
    output logic beq,
    output logic bne,
    output logic blt, 
    output logic bge, 
    output logic mem_read,
    output logic memtoreg,
    output logic [1:0] alu_op,
    output logic mem_write,
    output logic alu_src,
    output logic reg_write,
    output logic jal,
    output logic jalr,
    output logic auipc,
    output logic lui
);

    always_comb begin

        vec_op = 1'b0;
        vec_reg_write = 1'b0;
        continous_addr = 1'b0;
        single_load = 1'b0;
        branch = 1'b0;
        mem_read = 1'b0;
        memtoreg = 1'b0;
        alu_op = 2'b10; 
        mem_write = 1'b0;
        alu_src = 1'b0;
        reg_write = 1'b0;
        jal = 1'b0;
        jalr = 1'b0; 
        beq = 1'b0;
        bne = 1'b0;
        blt = 1'b0;
        bge = 1'b0;
        auipc = 1'b0;
        lui = 0;


        case (opcode)
            7'b0110011 : begin 
                alu_op = 2'b10; 
                reg_write = 1'b1;
            end

            7'b1011011 : begin 
                vec_op = 1'b1; 
                alu_op = 2'b10; 
                vec_reg_write = 1'b1;
            end
        
            7'b0010011 : begin 
                alu_op = 2'b10; 
                alu_src = 1'b1; 
                reg_write = 1'b1;
            end

            7'b0001011 : begin 
                vec_op = 1'b1; 
                alu_src = 1'b1; 
                vec_reg_write = 1'b1;
                unique case(funct3)
                    // Put VLOAD in I-types, because I need the other opcode for U-types
                    // imm in I-types is too small      
                    // Replaced slti in I-types
                    3'b010 : begin
                        alu_op = 2'b00;
                        mem_read = 1'b1;
                        memtoreg = 1'b1;
                    end

                    3'b011 : begin
                        alu_op = 2'b00;
                        continous_addr = 1'b1; // This is to add the continuation of the immediate value
                    end

                    3'b110 : begin
                        alu_op = 2'b00;
                        single_load = 1'b1; // This is to load a single value from memory into a vector register (kernel computations)
                        mem_read = 1'b1;
                        memtoreg = 1'b1;
                    end

                    default: alu_op = 2'b10;
                endcase
            end

            7'b0000011 : begin 
                mem_read = 1'b1;
                memtoreg = 1'b1;
                alu_op = 2'b00; 
                alu_src = 1'b1; 
                reg_write = 1'b1;
            end

            7'b1111011 : begin 
                vec_op = 1'b1;
                auipc = 1'b1;
                alu_op = 2'b00;
                alu_src = 1'b1;
                vec_reg_write = 1'b1;
            end

            7'b0100011 : begin 
                alu_op = 2'b00; 
                mem_write = 1'b1; 
                alu_src = 1'b1; 
            end

            7'b0101011 : begin
                vec_op = 1'b1; 
                alu_op = 2'b00; 
                mem_write = 1'b1; 
                alu_src = 1'b1; 
            end

            7'b1100011 : begin
                branch = 1'b1;
                alu_op = 2'b01; 
                case (funct3) 
                    3'b000 : beq = 1'b1;
                    3'b001 : bne = 1'b1;
                    3'b100 : blt = 1'b1;
                    3'b101 : bge = 1'b1;
                endcase
            end

            7'b1101111 : begin 
                alu_op = 2'b00; 
                alu_src = 1'b1; 
                reg_write = 1'b1; 
                jal = 1'b1;
            end

            7'b1100111 : begin 
                alu_op = 2'b00; 
                alu_src = 1'b1; 
                reg_write = 1'b1; 
                jalr = 1'b1;
            end

            7'b0110111 : begin // LUI
                lui = 1'b1;
                alu_op = 2'b00; 
                alu_src = 1'b1; 
                reg_write = 1'b1;                 
            end

            7'b0010111 : begin
                auipc = 1'b1;
                alu_op = 2'b00; 
                alu_src = 1'b1; 
                reg_write = 1'b1;                 
            end

            default: begin
                vec_op = 1'b0;
                vec_reg_write = 1'b0;
                continous_addr = 1'b0;
                single_load = 1'b0;
                branch = 1'b0;
                mem_read = 1'b0;
                memtoreg = 1'b0;
                alu_op = 2'b00; 
                mem_write = 1'b0;
                alu_src = 1'b0; 
                reg_write = 1'b0;
                jal = 1'b0;
                jalr = 1'b0;
                beq = 1'b0;
                bne = 1'b0;
                blt = 1'b0;
                bge = 1'b0;
                auipc = 1'b0;
                lui = 1'b0;
            end
        endcase
    end 
endmodule