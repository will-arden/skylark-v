`timescale 1ns / 1ps

module dmem #(
    parameter MEM_SIZE = 64)
(
    input logic                 clk, reset,
                                WE,
    input logic [31:0]          A,
                                WD,
    output logic [31:0]         RD
);

    logic [31:0] data[MEM_SIZE-1:0];            // Create memory space
    
    integer i;
    always_ff @(posedge clk, posedge reset) begin
    
        // Initialize RAM on reset
        if(reset) begin
            for(i=0; i<MEM_SIZE; i++) begin
                data[i] <= 32'h00000000;
            end
        end
        
        // Writing to external memory
        else if(WE)     data[A] <= WD;
    end
    
    // Reading from external memory
    assign RD = data[A];

endmodule