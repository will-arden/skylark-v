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
        
            // Zero data at every address
            for(i=0; i<MEM_SIZE; i++) begin
                data[i] = 32'h00000000;
            end
            
            // Add any custom data on initialization
            data[0]     = 32'h00023BFF;                     // Mountain Definition
            data[1]     = 32'h000239DF;                     // mnt_test_A
            data[2]    = 32'h000231DF;                     // mnt_test_B
            data[3]    = 32'h000011DF;                     // mnt_test_C
            data[4]    = 32'h000211CF;                     // mnt_test_D
            data[5]    = 32'h01F71000;                     // false_test_A
            data[6]    = 32'h01101011;                     // false_test_B
            data[7]    = 32'h01FFB880;                     // false_test_C
            data[8]    = 32'h01FFFFFF;                     // false_test_D
            
        end
        
        // Writing to external memory
        else if(WE)     data[A] <= WD;
    end
    
    // Reading from external memory
    assign RD = data[A];

endmodule