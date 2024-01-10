`timescale 1ns/1ps

module datapath(

    // Inputs from external sources
    input logic                 clk, reset,
    input logic [31:0]          InstrF, ReadData,
    
    // Inputs from internal sources (from control)
    input logic                 RegWE_E,                // Register Write Enable                        (Execute)
                                RegWE_W,                //                                              (Writeback)
                                OpBSrcE,                // Select ALU operand B source                  (Execute)
                                ExPathE,                // Select desired Execute stage path            (Execute)
                                PCSrcE,                 // Selects branch target address or +4          (Execute)
    input logic [1:0]           ImmFormatD,             // Format of immediate value for Extend Unit    (Decode)
    input logic [2:0]           ALUFuncE,               // Controls the ALU's operation                 (Execute)
    
    // Outputs to external devices
    output logic [31:0]         ALUResult, WD, PCF,
    
    // Outputs to internal devices (to control)
    output logic                zero

);

    // Internal signals associated with Extend Unit
    logic [31:7] bits_in;
    logic [31:0] ExtImmD;

    // -------------- PROGRAM COUNTER -------------- //

    always_ff @(posedge reset, posedge clk) begin
        
        if (reset == 1'b1)
            PCF <= 32'h00000000;                        // PC is zero upon reset
        else if (clk == 1'b1 && reset == 1'b0)
            PCF <= PCF + 32'h00000004;                  // PC is incremented upon every rising clock edge
            
    end
    
    // -------------- REGISTER FILE -------------- //
    
    // Internal signals input to register file
    logic [4:0] A1, A2, A3, A4;
    logic [31:0] WD3, WD4, RD1, RD2;
    
    // Extract correct bits from instruction
    assign A1 = InstrF[19:15];                  // rs1
    assign A2 = InstrF[24:20];                  // rs2
    assign A3 = InstrF[11:7];                   // rd
    assign A4 = InstrF[11:7];                   // rd for Writeback (same for now, because there is no pipelining)
    
    logic [31:0] ExResultE;
    assign ExResultE = ALUResult;       // FOR NOW, JUST SET THIS TO ALURESULT - later this should be either that or BNN result
    assign WD3 = ExResultE;
    assign WD4 = ReadData;
    
    register_file rf(
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
        zero
    );
    
    // -------------- EXTEND UNIT -------------- //
    
    assign bits_in = InstrF[31:7];
    
    extend_unit extend_unit(
        ImmFormatD,
        bits_in,
        ExtImmD
    );
    
    // -------------- DATA MEMORY -------------- //
    
    assign WD = RD2;                                // WriteData is output to the external data memory.
                                                    // This is handled in the layer above (top level).

endmodule
