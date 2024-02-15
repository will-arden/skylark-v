/*
      _          _            _                    
  ___| | ___   _| | __ _ _ __| | __         __   __
 / __| |/ / | | | |/ _` | '__| |/ /  _____  \ \ / /
 \__ \   <| |_| | | (_| | |  |   <  |_____|  \ V / 
 |___/_|\_\\__, |_|\__,_|_|  |_|\_\           \_/  
           |___/                                   
*/

module skylark_core(
    input logic             clk, reset,
    input logic [31:0]      InstrF, ReadData,
    
    output logic            MemWriteW,
    output logic [31:0]     ALUResultW, WriteData, PCF
);

// -------------- INTERMEDIATE SIGNALS -------------- //

    // Control signals
    logic           RegWE_E_E, RegWE_E_W,                   // Execute Register Write Enable control bits
                    RegWE_W_E, RegWE_W_W;                   // Writeback Register Write Enable control bits
    logic           condition_met_E,
                    branch_D, jump_D,                       // Branch/Jump signals                  (Decode)
                    branch_E, jump_E,                       //                                      (Execute)
                    branched_flag_F, branched_flag_D,       // Flag asserted after branch/jump
                    OpBSrcE;                                // ALU Operand B select bits
    logic [1:0]     PCSrcE;                                 // PC source select bit
    logic [1:0]     ExPathE,                                // Execute path to be used
                    ImmFormatD;                             // Immediate value format (not pipelined, as it is used in the same stage)
    logic [2:0]     ALUFuncE;                               // ALU operation select bits

    // Stall & Flush signals for pipeline registers
    logic           StallF, StallD, StallE, StallW;
    logic           FlushD, FlushE, FlushW;
    
    // Forwarding signals
    logic           fwdA_E, fwdB_E;
    
    // Datapath signals
    logic Z, N;
    logic [4:0] A1_E, A2_E, A3_W, A4_W;
    

    
// -------------- CONTROL -------------- //

    control control(
        clk,                                // Inputs
        reset,
        branched_flag_F,
        Z, N,
        A1_E, A2_E,
        A3_W,
        InstrF,
        RegWE_E_E, RegWE_W_W,               // Outputs
        OpBSrcE,
        StallF,
        StallD, FlushD,
        StallE, FlushE,
        StallW, FlushW,
        fwdA_E, fwdB_E,
        PCSrcE,
        ExPathE,
        ImmFormatD,
        ALUFuncE,
        MemWriteW
    );

// -------------- DATAPATH -------------- //

    // Instantiate the datapath
    datapath dp(
        clk,                            // External inputs
        reset,
        InstrF,
        ReadData,
        RegWE_E_E,                      // Internal inputs (from control)
        RegWE_W_W,
        OpBSrcE,
        PCSrcE,
        StallF,
        StallD,
        StallE,
        StallW,
        FlushD,
        FlushE,
        FlushW,
        fwdA_E, fwdB_E,
        ExPathE,
        ImmFormatD,
        ALUFuncE,
        ALUResultW,                     // External outputs
        WriteData,
        PCF,
        Z,                              // Internal outputs (to control)
        N,
        branched_flag_F,
        A1_E, A2_E,
        A3_W
    );

endmodule