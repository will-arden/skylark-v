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
    
    // Writing to external memory
    always_ff @(posedge clk) begin
        if(WE) data[A] <= WD;
    end
    
    // Reading from external memory
    assign RD = data[A];

endmodule