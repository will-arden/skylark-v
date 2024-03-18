`timescale 1ns / 1ps

module control(

    input logic                 clk, reset,
                                Z, N,
                                RegWE_W_W2,             // This control signal is input from the load stall buffer
    input [4:0]                 A1_E, A2_E,
                                A3_W, A4_W2,
    input logic [31:0]          InstrF,
    
    // Outputs to datapath
    output logic                RegWE_E_E,              // Execute Register Write Enable                    (Execute)
                                RegWE_W_W,              //                                                  (Writeback)
                                OpBSrcE,                // Select ALU operand B source                      (Execute)
                                en_threshold_E,         // Enable Activation Threshold for BNN unit         (Execute)
                                en_threshold_W,         //                                                  (Writeback)
                                ms_WE_E,                // Write Enable matrix_size for BNN unit            (Execute)
                                at_WE_E,                // Write Enable Activation Threshold for BNN unit   (Execute)
                                StallF,
                                StallD, FlushD,
                                StallE, FlushE,
                                StallW, FlushW,
    output logic [1:0]          fwdA_E, fwdB_E,
                                PCSrcE,                 // Selects branch target address or +4          (Execute)         
                                ExPathE,                // Select desired Execute stage path            (Execute)
                                ExPathW,                //                                              (Writeback)
                                ImmFormatD,             // Format of immediate value for Extend Unit    (Decode)
    output logic [2:0]          ALUFuncE,               // Controls the ALU's operation                 (Execute)
    
    // Outputs to external destinations
    output logic                MemWriteW
);

/*
  ___           _                   _   _               ____                     _      
 |_ _|_ __  ___| |_ _ __ _   _  ___| |_(_) ___  _ __   |  _ \  ___  ___ ___   __| | ___ 
  | || '_ \/ __| __| '__| | | |/ __| __| |/ _ \| '_ \  | | | |/ _ \/ __/ _ \ / _` |/ _ \
  | || | | \__ \ |_| |  | |_| | (__| |_| | (_) | | | | | |_| |  __/ (_| (_) | (_| |  __/
 |___|_| |_|___/\__|_|   \__,_|\___|\__|_|\___/|_| |_| |____/ \___|\___\___/ \__,_|\___|
                                                                                        
*/

// -------------- INTERMEDIATE SIGNALS -------------- //

    logic           RegWE_E_W, RegWE_W_E,
                    branch_D, branch_E,
                    jump_D, jump_E,
                    condition_met_D,
                    condition_met_E;
                    
    // Declare and assign signals to represent instruction fields
    logic           funct7b5_F, funct7b5_D;             assign funct7b5_F   = InstrF[30];
    logic [2:0]     funct3_F, funct3_D, funct3_E;       assign funct3_F     = InstrF[14:12];
    logic [6:0]     op_F, op_D;                         assign op_F         = InstrF[6:0];
    
    // Declare signals to carry Decode stage information to the pipeline register
    logic           RegWE_E_D,
                    RegWE_W_D,
                    OpBSrcD,
                    MemWriteD,
                    en_threshold_D,
                    ms_WE_D, at_WE_D;
    logic [1:0]     ExPathD;
    logic [2:0]     ALUFuncD;

// -------------- FETCH-DECODE PIPELINE REGISTER -------------- //

    c_if_id_pipeline_register c_if_id_pipeline_register(
        clk, reset,
        StallD, FlushD,
        funct7b5_F, funct3_F, op_F,
        funct7b5_D, funct3_D, op_D
    );

// -------------- DECODER -------------- //

    decoder decoder(
        branch_E,
        N, Z,
        funct7b5_D,
        funct3_D, funct3_E,
        op_D,
        RegWE_E_D, RegWE_W_D,                   // Outputs
        branch_D, jump_D,
        condition_met_E,
        OpBSrcD,
        MemWriteD,
        en_threshold_D,
        ms_WE_D,
        at_WE_D,
        ExPathD,
        PCSrcE,
        ImmFormatD,
        ALUFuncD
    );
    
/*
  _____                     _       
 | ____|_  _____  ___ _   _| |_ ___ 
 |  _| \ \/ / _ \/ __| | | | __/ _ \
 | |___ >  <  __/ (__| |_| | ||  __/
 |_____/_/\_\___|\___|\__,_|\__\___|
                                    
*/                  
                    
// -------------- DECODE-EXECUTE PIPELINE REGISTER -------------- //

    logic       MemWriteE;

    c_id_ex_pipeline_register c_id_ex_pipeline_register(
        clk,
        reset,
        StallE,
        FlushE,
        RegWE_E_D, RegWE_W_D,           // Inputs to register
        OpBSrcD,
        MemWriteD,
        en_threshold_D,
        ms_WE_D,
        at_WE_D,
        branch_D, jump_D,
        ExPathD,
        ALUFuncD,
        funct3_D,
        RegWE_E_E, RegWE_W_E,           // Outputs from register
        OpBSrcE,
        MemWriteE,
        en_threshold_E,
        ms_WE_E,
        at_WE_E,
        branch_E, jump_E,
        ExPathE,
        ALUFuncE,
        funct3_E
    );
    
/*
 __        __    _ _       _                _    
 \ \      / / __(_) |_ ___| |__   __ _  ___| | __
  \ \ /\ / / '__| | __/ _ \ '_ \ / _` |/ __| |/ /
   \ V  V /| |  | | ||  __/ |_) | (_| | (__|   < 
    \_/\_/ |_|  |_|\__\___|_.__/ \__,_|\___|_|\_\
                                                 
*/

// -------------- EXECUTE-WRITEBACK PIPELINE REGISTER -------------- //

    c_ex_wb_pipeline_register c_ex_wb_pipeline_register(
        clk,
        reset,
        StallW,
        FlushW,
        RegWE_E_E, RegWE_W_E,
        MemWriteE,
        en_threshold_E,
        ExPathE,
        RegWE_E_W, RegWE_W_W,
        MemWriteW,
        en_threshold_W,
        ExPathW
    );
    
/*
  _   _                        _    ____            _             _   _   _       _ _   
 | | | | __ _ ______ _ _ __ __| |  / ___|___  _ __ | |_ _ __ ___ | | | | | |_ __ (_) |_ 
 | |_| |/ _` |_  / _` | '__/ _` | | |   / _ \| '_ \| __| '__/ _ \| | | | | | '_ \| | __|
 |  _  | (_| |/ / (_| | | | (_| | | |__| (_) | | | | |_| | | (_) | | | |_| | | | | | |_ 
 |_| |_|\__,_/___\__,_|_|  \__,_|  \____\___/|_| |_|\__|_|  \___/|_|  \___/|_| |_|_|\__|
                                                                                        
*/

    hcu hcu(
        RegWE_E_W,                      // Detects RAW hazards
        RegWE_W_E,                      // Detects load operation in Execute stage
        RegWE_W_W,
        RegWE_W_W2,                     // Input from load stall buffer
        condition_met_E,
        branch_D, jump_D,
        branch_E,
        A1_E, A2_E,                     // Source registers
        A3_W, A4_W2,                    // Destination registers (Execute and Writeback 2, respectively)
        StallF,                         // Outputs (Stall, Flush and Forwarding signals)
        StallD, FlushD,
        StallE, FlushE,
        StallW, FlushW,
        fwdA_E, fwdB_E
    );

endmodule