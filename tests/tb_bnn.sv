`timescale 1ns / 1ps

module tb_bnn;

    // Declare signals
    logic [31:0]        OpA, OpB;
    logic [5:0]         result;
    
    // Instantiate module
    bnn dut(
        OpA, OpB,
        result
    );
    
    initial begin
        OpA <= 32'h00000000;
        OpB <= 32'h00000000;
        #10;
        
        OpA <= 32'h00F0F0F;
        OpB <= 32'h0A00B00C;
        #10;
        
        OpA <= 32'h00010001;
        OpB <= 32'h00000001;
        #10;
    end

endmodule
