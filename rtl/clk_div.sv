`timescale 1ns / 1ps

module clk_div #(
    parameter HALF_PER = 6250000
)(

    input logic         clk, reset,
    output logic        low_speed_clk
    
);
     
    logic [31:0] counter;
 
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            counter         <= 32'b0;
            low_speed_clk   <= 1'b0;
        end
        else if (counter == HALF_PER-1) begin
            counter         <= 32'b0;
            low_speed_clk   <= !low_speed_clk;
        end
        else    counter <= counter + 1;
    end
 
endmodule
