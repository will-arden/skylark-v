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

    logic Z, N;

    // Instruction Fields (for Control module)
    logic [6:0]     op_F;
    logic [2:0]     funct3_F;
    logic           funct7b5_F;
    
    assign op_F         = InstrF[6:0];
    assign funct3_F     = InstrF[14:12];
    assign funct7b5_F   = InstrF[30];
    
// -------------- HAZARD CONTROL UNIT -------------- //

    // Control signals (some of which may be used for HCU)
    logic           RegWE_E_D, RegWE_E_E, RegWE_E_W,        // Execute Register Write Enable control bits
                    RegWE_W_D, RegWE_W_E, RegWE_W_W,        // Writeback Register Write Enable control bits
                    OpBSrcD, OpBSrcE;                       // ALU Operand B select bits
    logic [1:0]     PCSrcE;                                 // PC source select bit
    logic           MemWriteE;                              // External memory write enable bits
    logic [1:0]     ExPathD, ExPathE,                       // Execute path to be used
                    ImmFormatD;                             // Immediate value format (not pipelined, as it is used in the same stage)
    logic [2:0]     ALUFuncD, ALUFuncE;                     // ALU operation select bits

    // Stall & Flush signals for pipeline registers
    logic           StallF, StallD, StallE, StallW;
    logic           FlushD, FlushE, FlushW;
    
    // Forwarding signals
    logic           fwdA_E, fwdB_E;
    
    logic [4:0] A1_E, A2_E, A3_W, A4_W;
    logic condition_met_E, branch_D, jump_D, branch_E, jump_E, branched_flag_F, branched_flag_D;
    
    hcu hcu(
        clk, reset,
        A1_E, A2_E,                     // Source registers
        A3_W, A4_W,                     // Destination registers (Execute and Writeback, respectively)
        RegWE_E_W,                      // Detects RAW hazards
        RegWE_W_E,                      // Detects load operation in Execute stage
        RegWE_W_W,
        condition_met_E,
        branch_D, jump_D,
        branch_E, jump_E,
        branched_flag_F,
        StallF,
        StallD, FlushD,
        StallE, FlushE,
        StallW, FlushW,
        fwdA_E, fwdB_E
    );
    
// -------------- CONTROL -------------- //

    control control(
        clk,
        reset,
        StallD,
        StallE,
        StallW,
        FlushD,
        FlushE,
        FlushW,
        op_F,
        funct3_F,
        funct7b5_F,
        branched_flag_F,
        Z,
        N,
        RegWE_E_E, RegWE_E_W,
        RegWE_W_E, RegWE_W_W,
        condition_met_E,
        OpBSrcE,
        PCSrcE,
        branch_D, jump_D,
        branch_E, jump_E,
        branched_flag_D,
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
        A1_E, A2_E,                     // Internal outputs (to HCU)
        A3_W, A4_W
    );

endmodule