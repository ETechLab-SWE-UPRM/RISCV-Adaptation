module Data_memory #(
    parameter vec_length = 2,
    parameter data_base = 32'h1000_0000,
    parameter data_addresses = 8360 * 4,
    parameter UART_base = 32'h1000_82A0
) (
    input  logic clk,
    input  logic single_load,
    input  logic [31:0] address,
    input  logic [31:0] write_data [0:vec_length-1],
    input  logic [2:0] funct3,
    input  logic mem_write,
    input  logic mem_read,
    input  logic vec_op,

    output logic [31:0] read_data [0:vec_length-1]
);

    logic [31:0] bram_data [0:vec_length-1];
    logic [31:0] write_word [0:vec_length-1];
    logic [3:0]  write_enable [0:vec_length-1];
    logic [13:0] addresses [0:vec_length-1];
    logic vec_op_enable [0:vec_length-1];
    logic [31:0] byte_address;
    logic in_range [0:vec_length-1];
    logic read_result;
    logic result_range [0:vec_length-1];
    logic result_single_load;
    logic [2:0] funct3_internal;
    
    assign byte_address = address - data_base;
    assign vec_op_enable[0] = 1'b1;
    assign addresses[0] = byte_address[15:2];
    assign in_range[0] = (addresses[0] < data_addresses);
    // Calculate next addresses based on the current address and vector length
    genvar j;
    generate
        for (j = 1; j < vec_length; j++) begin
            assign addresses[j] = addresses[j-1] + 1;
            assign vec_op_enable[j] = vec_op;
            assign in_range[j] = addresses[j] < (data_addresses);
        end
    endgenerate

    always_ff @(posedge clk) begin
        read_result <= mem_read;
        result_range <= in_range;
        result_single_load <= single_load;
        funct3_internal <= funct3;
    end

    blk_mem_gen_0 mem_inst (
    .clka(clk),
    .ena(1'b1),
    .wea(write_enable[0]),
    .addra(addresses[0]),
    .dina(write_word[0]),
    .douta(bram_data[0]),
    .clkb(clk),
    .enb(vec_op_enable[1]),
    .web(write_enable[1]),
    .addrb(addresses[1]),
    .dinb(write_word[1]),
    .doutb(bram_data[1])
    );

    always_comb begin
        for (int i = 0; i < vec_length; i++) begin
            write_word[i]   = bram_data[i];
            write_enable[i] = 4'b0000;

            if (mem_write && in_range[i]) begin
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

            if (read_result && result_range[i]) begin
                unique case (funct3_internal)
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

                    3'b110, // LSW (vector)
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

            if(read_result && result_single_load) begin
                read_data[i] = bram_data[0]; // For single load, all read_data[i] should be the first address
            end

        end
    end
endmodule
