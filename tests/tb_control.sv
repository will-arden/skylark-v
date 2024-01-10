`timescale 1ns / 1ps

module tb_control;

    // -------------- SIGNALS -------------- //

    // Instruction fields (Inputs)
    logic [6:0]     op;
    logic [2:0]     funct3;
    logic           funct7b5;
    
    // Outputs
    logic           RegWE_E, RegWE_W,
                    OpBSrcE,
                    ExPathE,
                    PCSrcE;
    logic [1:0]     ImmFormatD;
    logic [2:0]     ALUFuncE;
    logic           MemWrite;
    
    // -------------- INSTANTIATE DUT -------------- //
    
    control control(
        op,
        funct3,
        funct7b5,
        RegWE_E, RegWE_W,
        OpBSrcE,
        ExPathE,
        PCSrcE,
        ImmFormatD,
        ALUFuncE,
        MemWrite
    );
    
    // -------------- SIMULATE -------------- //
    
    initial begin
        
        // ADDI x1, x0, #7
        op = 7'b0010011;        funct3 = 3'b000;        funct7b5 = 1'b0;
        
        #10;
        
        // ADD x3, x1, x2
        op = 7'b0110011;        funct3 = 3'b000;        funct7b5 = 1'b0;
        
        #10;
        
        // 
        
    end

endmodule
