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
                    ms_WE_E,                                // Write Enable matrix_size for BNN unit        (Execute)
                    use_register;                           // Selects register data as base address        (Decode)
    logic [1:0]     PCSrcE;                                 // PC source select bit
    logic [1:0]     ExPathE, ExPathW, ExPathW2;             // Execute path to be used
    logic [2:0]     ImmFormatD,                             // Immediate value format (not pipelined, as it is used in the same stage)
                    ALUFuncE;                               // ALU operation select bits

    // Stall & Flush signals for pipeline registers
    logic           StallF, StallD, StallE, StallW;
    logic           FlushD, FlushE, FlushW;
    
    // Forwarding signals
    logic [1:0]     fwdA_E, fwdB_E;
    
    // Datapath signals
    logic           Z, N;
    logic [4:0]     A1_E, A2_E, A3_W, A4_W, A4_W2;
    logic [31:0]    BNNResultW2;

// -------------- CONTROL -------------- //

    control control(
        clk,                                // Inputs
        reset,
        Z, N,
        RegWE_W_W2,
        ExPathW2,
        A1_E, A2_E,
        A3_W, A4_W2,
        InstrF,
        RegWE_E_E, RegWE_W_W,               // Outputs
        OpBSrcE,
        ms_WE_E,
        use_register,
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
        ms_WE_E,
        use_register,
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
        BNNResultW2,
        RegWE_W_W2,                     // Internal outputs (to control)
        Z,
        N,
        ExPathW2,
        A1_E, A2_E,
        A3_W,
        A4_W2
    );

endmodule