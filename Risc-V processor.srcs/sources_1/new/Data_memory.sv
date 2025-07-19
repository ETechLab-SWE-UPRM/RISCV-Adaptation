module Data_memory #(
    parameter vec_length = 2
) (
    input  logic clk,
    input  logic [31:0] address,
    input  logic [31:0] write_data [0:1],
    input  logic [2:0] funct3,
    input  logic mem_write,
    input  logic mem_read,
    input  logic vec_op,

    output logic [31:0] read_data [0:1]
);

    localparam data_base = 32'h1000_0000; 
    localparam data_words = 8360;
    logic [31:0] byte_address;
    logic [31:0] bram_data [0:1];
    logic [31:0] write_word [0:1];
    logic [3:0]  write_enable [0:1];
    logic [13:0] word_address;
    logic [31:0] next_address;
    
    assign byte_address = address - data_base;
    assign word_address = byte_address[15:2];
    assign next_address = word_address + 14'h1;

    blk_mem_gen_0 mem_inst (
        .clka(clk),
        .ena(1'b1),
        .wea(write_enable[0]),
        .addra(word_address),
        .dina(write_word[0]),
        .douta(bram_data[0]),
        .clkb(clk),
        .enb(vec_op),
        .web(write_enable[1]),
        .addrb(next_address),
        .dinb(write_word[1]),
        .doutb(bram_data[1])
    );

    always_comb begin
        for (int i = 0; i < vec_length; i++) begin
            write_word[i]   = bram_data[i];
            write_enable[i] = 4'b0000;

            if (mem_write) begin
                case (funct3)
                    3'b000: begin // SB
                        unique case (address[1:0])
                            2'd0: begin write_word[i] = { bram_data[i][31:8], write_data[i][7:0] };    write_enable[i] = 4'b0001; end
                            2'd1: begin write_word[i] = { bram_data[i][31:16], write_data[i][7:0], bram_data[i][7:0] }; write_enable[i] = 4'b0010; end
                            2'd2: begin write_word[i] = { bram_data[i][31:24], write_data[i][7:0], bram_data[i][15:0] }; write_enable[i] = 4'b0100; end
                            2'd3: begin write_word[i] = { write_data[i][7:0], bram_data[i][23:0] };              write_enable[i] = 4'b1000; end
                        endcase
                    end

                    3'b001: begin // SH
                        unique if (address[1:0] == 2'd0) begin
                            write_word[i]   = { bram_data[i][31:16], write_data[i][15:0] };
                            write_enable[i] = 4'b0011;
                        end else if (address[1:0] == 2'b10) begin
                            write_word[i]   = { write_data[i][15:0], bram_data[i][15:0] };
                            write_enable[i] = 4'b1100;
                        end
                    end

                    3'b010: begin // SW
                        write_word[i]   = write_data[i];
                        write_enable[i] = 4'b1111;
                    end

                    default: begin
                        write_word[i]   = bram_data[i];
                        write_enable[i] = 4'b0000;
                    end
                endcase
            end
        end
    end

    always_comb begin
        for (int i = 0; i < vec_length; i++) begin
            read_data[i] = 32'h0;
            
            if (mem_read) begin
                unique case (funct3)
                    3'b000: // LB (sign-extend)
                        case (address[1:0])
                            2'd0: read_data[i] = {{24{bram_data[i][7]}},  bram_data[i][7:0]};
                            2'd1: read_data[i] = {{24{bram_data[i][15]}}, bram_data[i][15:8]};
                            2'd2: read_data[i] = {{24{bram_data[i][23]}}, bram_data[i][23:16]};
                            default: read_data[i] = {{24{bram_data[i][31]}}, bram_data[i][31:24]};
                        endcase

                    3'b001: // LH (sign-extend)
                        if (address[1:0] == 2'd0)
                            read_data[i] = {{16{bram_data[i][15]}}, bram_data[i][15:0]};
                        else if (address[1:0] == 2'b10)
                            read_data[i] = {{16{bram_data[i][31]}}, bram_data[i][31:16]};

                    3'b010: // LW
                        read_data[i] = bram_data[i];

                    3'b100: // LBU (zero-extend)
                        case (address[1:0])
                            2'd0: read_data[i] = {24'd0, bram_data[i][7:0]};
                            2'd1: read_data[i] = {24'd0, bram_data[i][15:8]};
                            2'd2: read_data[i] = {24'd0, bram_data[i][23:16]};
                            default: read_data[i] = {24'd0, bram_data[i][31:24]};
                        endcase

                    3'b101: // LHU (zero-extend)
                        if (address[1:0] == 2'd0)
                            read_data[i] = {16'd0, bram_data[i][15:0]};
                        else
                            read_data[i] = {16'd0, bram_data[i][31:16]};

                    default:
                        read_data[i] = 32'd0;
                endcase
            end
        end
    end
endmodule
