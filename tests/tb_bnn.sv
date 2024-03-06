`timescale 1ns / 1ps

module tb_bnn;

    // Declare signals
    logic               clk, reset, ms_WE, at_WE, en_threshold_E;
    logic [31:0]        ExtImmE, ALUResultE, result;
    
    // Instantiate module
    bnn dut(
        clk, reset,
        en_threshold_E,     // Enable activation threshold
        ms_WE,              // Write Enable for matrix_size
        at_WE,
        ExtImmE,            // Activation threshold
        ALUResultE,         // XOR computation
        result
    );
    
    initial begin
    
        // Reset and initialize
        reset <= 1'b1;      clk <= 1'b0;
        #20;
        reset <= 1'b0;
        
        // Write a value to the activation threshold register
        at_WE <= 1'b1;
        ExtImmE <= 32'h00000001;
        #20;
        
        // Write a value to the matrix size register
        at_WE <= 1'b0;
        ExtImmE <= 32'h00000004;
        ms_WE <= 1'b1;
        #20;
        
        // Reset again
        reset <= 1'b1;      #20;        reset <= 1'b0;      ms_WE <= 1'b0;      at_WE <= 1'b0;
        
        // Test 1
        ms_WE <= 1'b0;
        en_threshold_E      <= 1'b1;
        ExtImmE             <= 32'h00000000;
        ALUResultE          <= (32'b00000000000000000000000_011001110 ^
                                32'b00000000000000000000000_101010101 );
        #20;
        
        // Test 2
        en_threshold_E      <= 1'b1;
        ExtImmE             <= 32'h00000000;
        ALUResultE          <= (32'b00000000000000000000000_111100101 ^
                                32'b00000000000000000000000_101100111 );
        #20;
        
    end
    
    // Generate clock signal
    always begin
        clk <= 1'b0;    #25;
        clk <= 1'b1;    #25;
    end

endmodule
