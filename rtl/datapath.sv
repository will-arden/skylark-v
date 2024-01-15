`timescale 1ns/1ps

module datapath(

    // Inputs from external sources
    input logic                 clk, reset,
    input logic [31:0]          InstrF, ReadData,
    
    // Inputs from internal sources (from control)
    input logic                 RegWE_E,                // Register Write Enable                        (Execute)
                                RegWE_W,                //                                              (Writeback)
                                OpBSrcE,                // Select ALU operand B source                  (Execute)
                                PCSrcE,                 // Selects branch target address or +4          (Execute)
    input logic [1:0]           ExPathE,                // Select desired Execute stage path            (Execute)
                                ImmFormatD,             // Format of immediate value for Extend Unit    (Decode)
    input logic [2:0]           ALUFuncE,               // Controls the ALU's operation                 (Execute)
    
    // Outputs to external devices
    output logic [31:0]         ALUResult, WD, PCF,
    
    // Outputs to internal devices (to control)
    output logic                zero,
                                negative

);

    // Program counter signals
    logic [31:0] PCNextF, PCNextE;

    // Internal signals associated with Extend Unit
    logic [31:7] bits_in;
    logic [31:0] ExtImmD;
    
    // Address Generation Unit signals
    logic [31:0] PCE, TargetAddr;
    
    // BNN signals
    logic [31:0] BNNResult;
    assign BNNResult = 32'h00000000;

    // -------------- PROGRAM COUNTER -------------- //

    pc pc(
        clk,
        reset,
        PCSrcE,
        TargetAddr,
        PCF,
        PCNextF
    );
    
    assign PCNextE = PCNextF;
    
    // -------------- REGISTER FILE -------------- //
    
    // Internal signals input to register file
    logic [4:0] A1, A2, A3, A4;
    logic [31:0] WD3, WD4, RD1, RD2;
    
    // Extract correct bits from instruction
    assign A1 = InstrF[19:15];                  // rs1
    assign A2 = InstrF[24:20];                  // rs2
    assign A3 = InstrF[11:7];                   // rd
    assign A4 = InstrF[11:7];                   // rd for Writeback (same for now, because there is no pipelining)
    
    
    // Choose result from Execute stage
    logic [31:0] ExResultE;
    
    mux3to1 path_select(
        ALUResult,                              // ALU path result
        32'h00000000,                           // BNN path result (FOR NOW, THIS IS ZERO)
        PCF + 32'h00000004,                     // JAL path result
        ExPathE,                                // 2-bit signal selects between the above options
        ExResultE                               // Selected value, to be written to register file
    );
    
    assign WD3 = ExResultE;
    assign WD4 = ReadData;
    
    register_file register_file(
        clk,
        reset,
        RegWE_E,
        RegWE_W,
        A1, A2, A3, A4,
        WD3, WD4,
        RD1, RD2
    );
    
    // -------------- ALU -------------- //
    
    // Internal signals input to ALU
    logic [31:0] OpA, OpB, ExtImmE;
    assign OpA = RD1;
    assign OpB = RD2;
    assign ExtImmE = ExtImmD;
    
    ALU ALU(
        OpA, OpB, ExtImmE,
        ALUFuncE,
        OpBSrcE,
        ALUResult,
        zero,
        negative
    );
    
    /*mux3to1 path_mux(
        ALUResult,
        BNNResult,
        PCNextE,
        ExPathE,
        ExResultE
    );*/
    
    // -------------- EXTEND UNIT -------------- //
    
    assign bits_in = InstrF[31:7];
    
    extend_unit extend_unit(
        ImmFormatD,
        bits_in,
        ExtImmD
    );
    
    // -------------- ADDRESS GENERATION UNIT -------------- //
    
    assign PCE = PCF;
    
    agu agu(
        ExtImmE,
        PCE,
        TargetAddr
    );
    
    // -------------- DATA MEMORY -------------- //
    
    assign WD = RD2;                                // WriteData is output to the external data memory.
                                                    // This is handled in the layer above (top level).

endmodule
