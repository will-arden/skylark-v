`timescale 1ns / 1ps

module bnn(

    input logic [31:0]      OpA_E, OpB_E,
    output logic [31:0]     BNNResult

);

    logic [31:0] int_sig;
    assign int_sig = ~(OpA_E ^ OpB_E);          // Bitwise XNOR operation
    
    // Popcount operation
    logic [5:0] c;
    integer i;
    always_comb begin
        c = '0;
        for(i = 0; i < 32; i++) begin
            c += int_sig[i];
        end
    end
    
    assign BNNResult = c;

endmodule



