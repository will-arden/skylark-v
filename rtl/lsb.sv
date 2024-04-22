`timescale 1ns / 1ps

module lsb(

    input logic             clk, reset,
                            RegWE_W_W,          // Will be asserted if load operation
    input logic [1:0]       ExPathW,            // Used for the HCU to determine between load/bcnv
    input logic [4:0]       A4_W,               // Destination register
    input logic [31:0]      ReadData,           // Value of loaded data
                            BNNResult,          // Result from the BNN (also written back in final stage)
    
    output logic            RegWE_W_W2,         // Outputs will equal the inputs at the next clock cycle
    output logic [1:0]      ExPathW2,
    output logic [4:0]      A4_W2,
    output logic [31:0]     ReadData2,
                            BNNResultW2

);

    always_ff @(posedge clk, posedge reset) begin : seq_proc
        if(reset) begin
            RegWE_W_W2      <= 1'b0;
            ExPathW2        <= 2'b00;
            A4_W2           <= 5'b00000;
            ReadData2       <= 32'h00000000;
            BNNResultW2     <= 32'h00000000;
        end
        else if(clk) begin
            RegWE_W_W2      <= RegWE_W_W;
            ExPathW2        <= ExPathW;
            A4_W2           <= A4_W;
            ReadData2       <= ReadData;
            BNNResultW2     <= BNNResult;
        end
    end

endmodule