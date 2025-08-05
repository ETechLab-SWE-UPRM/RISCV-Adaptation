
module baud_rate_generator #( 
    // 9600 baud rate with 100 MHz clock
    parameter counter = 10, // derived from slides? 
    parameter counter_limit = 651
) (
    input logic clk, 
    input logic reset, 

    output logic tick
);
    
    logic [counter-1:0] counter_reg, counter_next;

    always_ff @(posedge clk or posedge reset) begin
        if(reset) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_next;
        end
    end

    assign counter_next = (counter_reg == counter_limit - 1) ? 0 : counter_reg + 1;
    assign tick = (counter_reg == counter_limit - 1) ? 1'b1 : 1'b0;

endmodule