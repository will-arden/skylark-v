/*
      _          _            _                    
  ___| | ___   _| | __ _ _ __| | __         __   __
 / __| |/ / | | | |/ _` | '__| |/ /  _____  \ \ / /
 \__ \   <| |_| | | (_| | |  |   <  |_____|  \ V / 
 |___/_|\_\\__, |_|\__,_|_|  |_|\_\           \_/  
           |___/                                   
*/

`timescale 1ns / 1ps

module skylark_core(
    input logic             clk, reset,
    input logic [31:0]      InstrF, ReadData,
    
    output logic            MemWriteW,
    output logic [31:0]     ALUResultW, WriteData, PCF
);

// -------------- INTERMEDIATE SIGNALS -------------- //

    // Control signals
    logic           RegWE_E_E, RegWE_E_W,                   // Execute Register Write Enable control bits
                    RegWE_W_E, RegWE_W_W,                   // Writeback Register Write Enable control bits
                    RegWE_W_W2;
    logic           condition_met_E,
                    branch_D, jump_D,                       // Branch/Jump signals                          (Decode)
                    branch_E, jump_E,                       //                                              (Execute)
                    OpBSrcE,                                // ALU Operand B select bits                    (Execute)
                    en_threshold_E,                         // Enable activation threshold for BNN unit     (Execute)
                    en_threshold_W,                         //                                              (Writeback)
                    ms_WE_E,                                // Write Enable matrix_size for BNN unit        (Execute)
                    at_WE_E;                                // Write Enable activation_threshold            (Execute)
    logic [1:0]     PCSrcE;                                 // PC source select bit
    logic [1:0]     ExPathE, ExPathW,                       // Execute path to be used
                    ImmFormatD;                             // Immediate value format (not pipelined, as it is used in the same stage)
    logic [2:0]     ALUFuncE;                               // ALU operation select bits

    // Stall & Flush signals for pipeline registers
    logic           StallF, StallD, StallE, StallW;
    logic           FlushD, FlushE, FlushW;
    
    // Forwarding signals
    logic [1:0]     fwdA_E, fwdB_E;
    
    // Datapath signals
    logic Z, N;
    logic [4:0] A1_E, A2_E, A3_W, A4_W, A4_W2;
    

    
// -------------- CONTROL -------------- //

    control control(
        clk,                                // Inputs
        reset,
        Z, N,
        RegWE_W_W2,
        A1_E, A2_E,
        A3_W, A4_W2,
        InstrF,
        RegWE_E_E, RegWE_W_W,               // Outputs
        OpBSrcE,
        en_threshold_E, en_threshold_W,
        ms_WE_E,
        at_WE_E,
        StallF,
        StallD, FlushD,
        StallE, FlushE,
        StallW, FlushW,
        fwdA_E, fwdB_E,
        PCSrcE,
        ExPathE,
        ExPathW,
        ImmFormatD,
        ALUFuncE,
        MemWriteW
    );

// -------------- DATAPATH -------------- //

    // Instantiate the datapath
    datapath datapath(
        clk,                            // External inputs
        reset,
        InstrF,
        ReadData,
        RegWE_E_E,                      // Internal inputs (from control)
        RegWE_W_W,
        OpBSrcE,
        en_threshold_E, en_threshold_W,
        ms_WE_E,
        at_WE_E,
        PCSrcE,
        StallF, StallD, StallE, StallW,
        FlushD, FlushE, FlushW,
        fwdA_E, fwdB_E,
        ExPathE, ExPathW,
        ImmFormatD,
        ALUFuncE,
        ALUResultW,                     // External outputs
        WriteData,
        PCF,
        RegWE_W_W2,                     // Internal outputs (to control)
        Z,
        N,
        A1_E, A2_E,
        A3_W,
        A4_W2
    );

endmodule