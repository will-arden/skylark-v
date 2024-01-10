/*
RISC-V Core
------------
This module includes the datapath and control signals of the RISC-V processor; it does not include memory and access
to other peripherals, as these would be part of a SoC, not a standalone core.
*/

`timescale 1ns/1ps

module rv_core(
    input logic                 clk, reset,
    input logic [31:0]          Instr, ReadData,
    
    output logic                MemWrite,
    output logic [31:0]         ALUResult, WriteData, PCF
);
    
    // -------------- DATAPATH -------------- //
    
    // Internal signals for datapath module (explained within module)
    logic           RegWE_E, RegWE_W, OpBSrcE, ExPathE, PCSrcE, zero;
    logic [1:0]     ImmFormatD;
    logic [2:0]     ALUFuncE;
    
    // Instantiate the datapath
    datapath dp(
        clk,                            // External inputs
        reset,
        Instr,
        ReadData,
        RegWE_E,                        // Internal inputs (from control)
        RegWE_W,
        OpBSrcE,
        ExPathE,
        PCSrcE,
        ImmFormatD,
        ALUFuncE,
        ALUResult,                      // External outputs
        WriteData,
        PCF,
        zero                            // Internal outputs (to control)
    );
    
    // -------------- CONTROL -------------- //
    
    // Internal signals for control module (explained within module)
    logic [6:0]     op;
    logic [2:0]     funct3;
    logic           funct7b5;
    
    assign op = Instr[6:0];
    assign funct3 = Instr[14:12];
    assign funct7b5 = Instr[30];
    
    control control(
        op,                             // Instruction fields for RV32I
        funct3,
        funct7b5,
        RegWE_E,                         // Outputs to internal destinations (to datapath)
        RegWE_W,
        OpBSrcE,
        ExPathE,
        PCSrcE,
        ImmFormatD,
        ALUFuncE,
        MemWrite                        // Outputs to external destinations
    );

endmodule
