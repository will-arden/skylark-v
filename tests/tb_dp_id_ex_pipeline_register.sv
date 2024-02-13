`timescale 1ns / 1ps

module tb_dp_id_ex_pipeline_register;

    // Declare inputs
    logic               clk,
                        reset,
                        StallE,
                        FlushE;
    logic [4:0]         A3_D, A4_D;
    logic [31:0]        RD1_D, RD2_D,
                        PCD,
                        PCNextD,
                        ExtImmD;
                        
    // Declare outputs
    logic [4:0]         A3_E, A4_E;
    logic [31:0]        RD1_E, RD2_E,
                        PCE,
                        PCNextE,
                        ExtImmE;
                        
    // Instantiate DUT
    dp_id_ex_pipeline_register dut(
        clk,
        reset,
        StallE,
        FlushE,
        A3_D, A4_D,
        RD1_D, RD2_D,
        PCD,
        PCNextD,
        ExtImmD,
        A3_E, A4_E,
        RD1_E, RD2_E,
        PCE,
        PCNextE,
        ExtImmE
    );
    
// -------------- SIMULATION -------------- //

    initial begin
    
        // Define initial signal states
        clk <= 0;       reset <= 1;     StallE <= 0;    FlushE <= 0;
        A3_D <= 0;      A4_D <= 0;      RD1_D <= 0;     RD2_D <= 0;     PCD <= 0;       PCNextD <= 0;       ExtImmD <= 0;
        #20;
        
        // Begin
        reset = 1'b0;
        
        // Update some inputs, and observe the outputs changing on the next positive clock edge
        A3_D <= 5'b01010;               A4_D <= 5'b10101;
        #20;
        
        // Assert the StallE signal, and observe no change in output when the inputs are changed
        StallE = 1'b1;
        A3_D <= 5'b11111;               A4_D <= 5'b11111;
        #20;
        
        // Update again
        StallE = 1'b0;
        #20;
        
        // Flush the pipeline register, before returning to normal
        FlushE = 1'b1;
        #20;
        FlushE = 1'b0;
        #20;
        
        // Flush and Stall at the same time (shouldn't happen, but testing anyway)
        FlushE <= 1'b1;
        StallE <= 1'b1;
        A3_D <= 5'b01010;               A4_D <= 5'b10101;
        
    end
    
    always begin
        clk <= 0;   #10;    clk <= 1;   #10;
    end

endmodule
