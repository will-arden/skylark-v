`timescale 1ns / 1ps

module tb_extend_unit;

    // Create testbench signals
    logic [1:0]     ImmFormatD;
    logic [31:7]    bits_in;
    logic [31:0]    ExtImmD;
    
    // Instantiate dut
    extend_unit dut(
        ImmFormatD,
        bits_in,
        ExtImmD
    );
    
    // Simulation
    initial begin
    
        // Initialize all signals
        ImmFormatD = '0;
        bits_in = '0;
        
        #10;
        
        // Extend an I-type immediate (14 = 1110)
        ImmFormatD = 2'b00;
        bits_in = 25'b000000001110_0000000000000;
        
        #10;
        
        
        // Extend a negative I-type immediate (-10 = 11110110)
        ImmFormatD = 2'b00;
        bits_in = 25'b111111110110_0000000000000;
        
        # 10;
        
        
        // Extend an S-type immediate (72 = 000001001000)
        ImmFormatD = 2'b01;
        bits_in = 25'b0000010_00000_00000_000_01000;
        
        #10;
        
        
        // Extend a B-type immediate (48 = 0000000110000)
        ImmFormatD = 2'b10;
        bits_in = 25'b0_000001_00000_00000_000_1000_0;
        
        #10;
        
        // Extend a J-type immediate (28 = 000000000000000011100)
        ImmFormatD = 2'b11;
        bits_in = 25'b0_0000001110_0_00000000_00000;

    end

endmodule
