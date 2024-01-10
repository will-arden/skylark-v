`timescale 1ns / 1ps

module tb_datapath;

    // -------------- TESTBENCH SIGNALS -------------- //

    // External inputs
    logic           clk, reset;
    logic [31:0]    InstrF, ReadData;

    // Internal inputs (from control)
    logic           RegWE_E, RegWE_W,
                    OpBSrcE,
                    ExPathE,
                    PCSrcE;
    logic [1:0]     ImmFormatD;
    logic [2:0]     ALUFuncE;
    
    // Output signals
    logic [31:0]    ALUResult,
                    WriteData,
                    PCF;
    logic           zero;
    
    // -------------- INSTANTIATE DUT -------------- //
    
    datapath dut(
        // Inputs
        clk, reset,
        InstrF, ReadData,
        RegWE_E, RegWE_W,
        OpBSrcE,
        ExPathE,
        PCSrcE,
        ImmFormatD,
        ALUFuncE,
        // Outputs
        ALUResult,
        WriteData,
        PCF,
        zero
    );
    
    // -------------- SIMULATE -------------- //

    initial begin
    
        // Initialize inputs
        clk = 1'b0; reset = 1'b0;
        InstrF = 32'h00000000;
        ReadData = 32'h00000000;
        RegWE_E = 1'b0; RegWE_W = 1'b0;         // No write enabled
        OpBSrcE = 1'b0;                         // Defualt OpB chosen
        ExPathE = 1'b0;                         // ALU path chosen (not BNN)
        PCSrcE = 1'b0;                          // No branching
        ImmFormatD = 2'b00;                     // Default extend format
        ALUFuncE = 3'b000;                      // Set to ADD by default
        
        // Reset device by toggling reset signal
        reset <= 1'b1;
        #10;
        reset <= 1'b0;
        
        #10;
        
        // Write something to the register file
        InstrF = 32'h00700093;              // ADDI x1, x0, #7
        OpBSrcE = 1'b1;                     // Choose sign-extended immediate
        RegWE_E = 1'b1;                     // Write operation
        #1; clk = !clk; #9; clk = !clk;     // Toggle clock
        
        #10;
        
        // Write something to another register
        InstrF = 32'h00300113;              // ADDI x2, x0, #3
        OpBSrcE = 1'b1;                     // Sign-extended immediate still required (I-type again)
        RegWE_E = 1'b1;                     // Write operation
        #1; clk = !clk; #9; clk = !clk;     // Toggle clock
        
        #10;
        
        // Demonstrate R-type instruction, writing to a third register
        InstrF = 32'h002081B3;              // ADD x3, x1, x2
        OpBSrcE = 1'b0;                     // OpB is register operand
        RegWE_E = 1'b1;                     // Write operation
        #1; clk = !clk; #9; clk = !clk;     // Toggle clock
    
    end

endmodule
