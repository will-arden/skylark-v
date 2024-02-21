`timescale 1ns / 1ps

module lsb(

    input logic             clk, reset,
                            RegWE_W_W,          // Will be asserted if load operation
    input logic [4:0]       A4_W,               // Destination register
    input logic [31:0]      ReadData,           // Value of loaded data
    
    output logic            RegWE_W_W2,         // Outputs will equal the inputs at the next clock cycle
    output logic [4:0]      A4_W2,
    output logic [31:0]     ReadData2

);

    always_ff @(posedge clk, posedge reset) begin
        if(reset) begin
            RegWE_W_W2      <= 1'b0;
            A4_W2           <= 5'b00000;
            ReadData2       <= 32'h00000000;
        end
        else if(clk) begin
            RegWE_W_W2      <= RegWE_W_W;
            A4_W2           <= A4_W;
            ReadData2       <= ReadData;
        end
    end

endmodule