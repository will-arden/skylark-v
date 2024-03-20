`timescale 1ns / 1ps

module datapath(

    // Inputs from external sources
    input logic                 clk, reset,
    input logic [31:0]          InstrF, ReadData,
    
    // Inputs from internal sources (from control)
    input logic                 RegWE_E_E,              // Execute Register Write Enable                (Execute)
                                RegWE_W_W,              // Writeback Register Write Enable              (Writeback)
                                OpBSrcE,                // Select ALU operand B source                  (Execute)
                                en_threshold_E,         // Enable activation threshold (BNN unit)       (Execute)
                                en_threshold_W,         //                                              (Writeback)
                                ms_WE_E,                // Write enable matrix_size (BNN unit)          (Execute)
                                at_WE_E,                // Write enable Activation Threshold            (Execute)
    input logic [1:0]           PCSrcE,                 // Selects branch target address or +4          (Execute)
    input logic                 StallF,                 // Stalls the pipeline                          (Fetch)
                                StallD,                 // Stalls the pipeline                          (Decode)
                                StallE,                 // Stalls the pipeline                          (Execute)
                                StallW,                 // Stalls the pipeline                          (Writeback)
                                FlushD,                 // Flushes the pipeline                         (Decode)
                                FlushE,                 // Flushes the pipeline                         (Execute)
                                FlushW,                 // Flushes the pipeline                         (Writeback)
    input logic [1:0]           fwdA_E,                 // Forward select for operand A                 (Execute)
                                fwdB_E,                 // Forward select for operand B                 (Execute)
                                ExPathE,                // Select desired Execute stage path            (Execute)
                                ExPathW,                //                                              (Writeback)
    input logic [2:0]           ImmFormatD,             // Format of immediate value for Extend Unit    (Decode)
                                ALUFuncE,               // Controls the ALU's operation                 (Execute)
    
    // Outputs to external devices
    output logic [31:0]         ALUResultW, WD, PCF,
    
    // Outputs to internal devices (to control)
    output logic                RegWE_W_W2,             // Load Stall Buffer
                                Z,
                                N,
    output logic [4:0]          A1_E, A2_E,             // Source registers (for HCU)                   (Execute)
                                A3_W,                   // Destination registers (for HCU)              (Writeback)
                                A4_W2

);

    // Program counter signals
    logic [31:0] PCNextF, PCNextD, PCNextE;

    // Internal signals associated with Extend Unit
    logic [31:7] bits_in;
    logic [31:0] ExtImmD;
    
    // Address Generation Unit signals
    logic [31:0] PCE, TargetAddr;
    
/*
  ___           _                   _   _               _____    _       _     
 |_ _|_ __  ___| |_ _ __ _   _  ___| |_(_) ___  _ __   |  ___|__| |_ ___| |__  
  | || '_ \/ __| __| '__| | | |/ __| __| |/ _ \| '_ \  | |_ / _ \ __/ __| '_ \ 
  | || | | \__ \ |_| |  | |_| | (__| |_| | (_) | | | | |  _|  __/ || (__| | | |
 |___|_| |_|___/\__|_|   \__,_|\___|\__|_|\___/|_| |_| |_|  \___|\__\___|_| |_|
                                                                                               
*/
    
// -------------- PROGRAM COUNTER -------------- //

    pc pc(
        clk,
        reset,
        StallF,
        PCSrcE,
        TargetAddr,
        PCNextE,
        PCF,
        PCNextF
    );

/*
  ___           _                   _   _               ____                     _      
 |_ _|_ __  ___| |_ _ __ _   _  ___| |_(_) ___  _ __   |  _ \  ___  ___ ___   __| | ___ 
  | || '_ \/ __| __| '__| | | |/ __| __| |/ _ \| '_ \  | | | |/ _ \/ __/ _ \ / _` |/ _ \
  | || | | \__ \ |_| |  | |_| | (__| |_| | (_) | | | | | |_| |  __/ (_| (_) | (_| |  __/
 |___|_| |_|___/\__|_|   \__,_|\___|\__|_|\___/|_| |_| |____/ \___|\___\___/ \__,_|\___|
                                                                                        
*/
    
// -------------- FETCH-DECODE PIPELINE REGISTER -------------- //
                    
    logic [31:0] InstrD, PCD;

    dp_if_id_pipeline_register dp_if_id_pipeline_register(
        clk,
        reset,
        StallD,
        FlushD,
        InstrF,
        PCF,
        PCNextF,
        InstrD,
        PCD,
        PCNextD
    );

// -------------- REGISTER FILE -------------- //

    // Internal signals input to register file
    logic [4:0]     A1_D, A2_D, A3_D, A4_D,             // Decode signals
                    A3_E, A4_E,                         // Execute signals
                    A4_W;                               // Writeback signal
                    
    logic [31:0]    WD3, WD4, RD1_D, RD2_D;
    
    // Extract correct bits from instruction
    assign A1_D = InstrD[19:15];        // rs1
    assign A2_D = InstrD[24:20];        // rs2
    assign A3_D = InstrD[11:7];         // rd (Execute)
    assign A4_D = InstrD[11:7];         // rd (Writeback)   -   this occupies the same space as A3_D, as it is just the destination address

    register_file register_file(
        clk,
        reset,
        RegWE_E_E,
        RegWE_W_W,
        A1_D, A2_D, A3_E, A4_W,
        WD3, WD4,
        RD1_D, RD2_D
    );
    
// -------------- EXTEND UNIT -------------- //
    
    assign bits_in = InstrD[31:7];
    
    extend_unit extend_unit(
        ImmFormatD,
        bits_in,
        ExtImmD
    );
    
// -------------- ADDRESS GENERATION UNIT -------------- //
    
    agu agu(
        ExtImmD,
        PCD,
        TargetAddr
    );

/*
  _____                     _       
 | ____|_  _____  ___ _   _| |_ ___ 
 |  _| \ \/ / _ \/ __| | | | __/ _ \
 | |___ >  <  __/ (__| |_| | ||  __/
 |_____/_/\_\___|\___|\__,_|\__\___|
                                    
*/

// -------------- DECODE-EXECUTE PIPELINE REGISTER -------------- //

    logic [31:0]    RD1_E, RD2_E, ExtImmE;

    dp_id_ex_pipeline_register dp_id_ex_pipeline_register(
        clk,
        reset,
        StallE,
        FlushE,
        A1_D, A2_D,             // Inputs to registers
        A3_D, A4_D,             
        RD1_D, RD2_D,
        PCD,
        PCNextD,
        ExtImmD,
        A1_E, A2_E,             // Outputs from registers
        A3_E, A4_E,             
        RD1_E, RD2_E,
        PCE,
        PCNextE,
        ExtImmE
    );
    
// -------------- FORWARDING SWITCHES -------------- //

    logic [31:0]    OpA_E, OpB_E;
    
    logic [31:0]    ReadData2;

    mux3to1 fwd_mux_a(
        RD1_E,                      // a
        ALUResultW,                 // b
        ReadData2,                  // c            // Output from Load Stall Buffer
        fwdA_E,                     // sel
        OpA_E                       // y
    );
    
    mux3to1 fwd_mux_b(
        RD2_E,                      // a
        ALUResultW,                 // b
        ReadData2,                  // c            // Output from Load Stall Buffer
        fwdB_E,                     // sel
        OpB_E                       // y
    );
    
// -------------- ARITHMETIC LOGIC UNIT -------------- //
    
    logic [31:0] ALUResultE;
    
    alu alu(
        OpA_E, OpB_E, ExtImmE,
        ALUFuncE,
        OpBSrcE,
        ALUResultE,
        Z,
        N
    );
    
// -------------- BNN UNIT -------------- //

/*
    Note:   The BNN unit is split across two pipeline stages: Execute and Writeback. This is done
            in an attempt to meet the timing constraints of the 100MHz Basys 3 clock.
*/

    // BNN signals
    logic [31:0]    length_adjusted_E, length_adjusted_W,
                    BNNResult;
    bnn bnn(
        clk, reset,                 // Inputs
        en_threshold_E,
        en_threshold_W,
        ms_WE_E,
        at_WE_E,
        ExtImmE,
        ALUResultE,
        length_adjusted_W,
        length_adjusted_E,          // Outputs
        BNNResult
    );
    
// -------------- EXECUTE PATH SELECTOR -------------- //

    logic [31:0]        ExResultE;
    assign WD3      =   ExResultE;

    mux3to1 path_select(
        ALUResultE,                              // ALU path result
        BNNResult,                              // BNN path result
        PCNextE,                                // JAL path result
        ExPathE,                                // 2-bit signal selects between the above options
        ExResultE                               // Selected value, to be written to register file
    );

/*
 __        __    _ _       _                _    
 \ \      / / __(_) |_ ___| |__   __ _  ___| | __
  \ \ /\ / / '__| | __/ _ \ '_ \ / _` |/ __| |/ /
   \ V  V /| |  | | ||  __/ |_) | (_| | (__|   < 
    \_/\_/ |_|  |_|\__\___|_.__/ \__,_|\___|_|\_\
                                                 
*/

    //logic               RegWE_W_W2;
    //logic [4:0]         A4_W2;
    logic [31:0]        RD2_W, PCNextW;
                        
// -------------- EXECUTE-WRITEBACK PIPELINE REGISTER -------------- //

    dp_ex_wb_pipeline_register dp_ex_wb_pipeline_register(
        clk,
        reset,
        StallW,
        FlushW,
        A3_E, A4_E,
        OpB_E,              // This becomes RD2_W, as it is the write data for SW operations
        ALUResultE,
        length_adjusted_E,
        PCNextE,
        A3_W, A4_W,
        RD2_W,
        ALUResultW,
        length_adjusted_W,
        PCNextW
    );
    
    assign WD       =   RD2_W;
    assign WD4      =   (ExPathW[0] == 1'b0) ? ReadData : BNNResult;
    
// -------------- LOAD STALL BUFFER -------------- //
    
    lsb lsb(
        clk,
        reset,
        RegWE_W_W,
        A4_W,
        ReadData,
        RegWE_W_W2,
        A4_W2,
        ReadData2
    );

endmodule
