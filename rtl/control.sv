module control(

    input logic                 clk, reset,
                                StallD,
                                StallE,
                                StallW,
                                FlushD,
                                FlushE,
                                FlushW,

    // Instruction fields for RV32I
    input logic [6:0]           op_F,
    input logic [2:0]           funct3_F,
    input logic                 funct7b5_F,
                                branched_flag_F,
    
    // Inputs from datapath
    input logic                 Z,
                                N,
    
    // Outputs to datapath
    output logic                RegWE_E_E,              // Execute Register Write Enable                (Execute)
                                RegWE_E_W,              //                                              (Writeback)
                                RegWE_W_E,              // Writeback Register Write Enable              (Execute)
                                RegWE_W_W,              //                                              (Writeback)
                                condition_met,
                                OpBSrcE,                // Select ALU operand B source                  (Execute)
    output logic [1:0]          PCSrcE,                 // Selects branch target address or +4          (Execute)
    output logic                branch_D, jump_D,       // Branch and Jump flags                        (Decode)
                                branch_E, jump_E,       //                                              (Execute)
                                branched_flag_D,
    output logic [1:0]          ExPathE,                // Select desired Execute stage path            (Execute)
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

// -------------- FETCH-DECODE PIPELINE REGISTER -------------- //

    // Declare signals that are passed to the Decode stage
    logic           funct7b5_D;
    logic [2:0]     funct3_D;
    logic [6:0]     op_D;

    c_if_id_pipeline_register c_if_id_pipeline_register(
        clk,
        reset,
        StallD,
        FlushD,
        funct7b5_F,
        funct3_F,
        op_F,
        funct7b5_D,
        funct3_D,
        op_D
    );

    logic       branch,                 // Set if the opcode indicates a branch instruction
                jump;                   // Set if the opcode indicates a jump instruction
                //condition_met;          // Set if the branch condition is met
                
    assign branch           = (op_D == 7'b1100011) ? 1'b1 : 1'b0;
    assign jump             = (op_D == 7'b1101111) ? 1'b1 : 1'b0;
    assign branch_D = branch;
    assign jump_D = jump;

    logic [12:0] control_signals;

    always_comb begin
    
        // Generate a vector of all the control signals (improves readability)
        unique case(op_D)
            7'b0010011:     control_signals <= 13'b10_1_00_00_00_xxx_0;    // I-type (not LOAD)
            7'b0110011:     control_signals <= 13'b10_0_00_00_00_xxx_0;    // R-type               (ImmFormatD is "don't care")
            7'b0000011:     control_signals <= 13'b01_1_00_00_00_000_0;    // LOAD instruction
            7'b0100011:     control_signals <= 13'b00_1_00_00_01_000_1;    // S-type
            7'b1100011:     control_signals <= 13'b00_0_00_xx_10_001_0;    // B-type
            7'b1101111:     control_signals <= 13'b10_0_10_01_11_000_0;    // J-type (not JALR)
            default:        control_signals <= 'x;                       // Invalid instruction (or not supported)
        endcase
        
        if(!branch) begin
            unique case(funct3_D)
                3'b000:         control_signals[3:1] <= (funct7b5_D && op_D==7'b0110011) ? 3'b001 : 3'b000;    // ADD/SUB operation
                3'b010:         control_signals[3:1] <= 3'b001;                          // SLT operation
                3'b100:         control_signals[3:1] <= 3'b100;                          // XOR operation
                3'b110:         control_signals[3:1] <= 3'b011;                          // OR operation
                3'b111:         control_signals[3:1] <= 3'b010;                          // AND operation
                default:        control_signals[3:1] <= 'x;                              // Invalid operation
            endcase
            condition_met <= 1'bx;       // For non-branch instructions, the condition doesn't matter. This line avoids latch generation.
        end
        else begin
            unique case (funct3_D)
                3'b000:         condition_met <= Z;           // BEQ
                3'b001:         condition_met <= !Z;          // BNE
                3'b100:         condition_met <= N;           // BLT
                3'b101:         condition_met <= !N;          // BGE
                default:        condition_met <= 1'bx;               // Invalid/unsupported instruction
            endcase
        end
        
        if(!branched_flag_F && (jump || branch))    control_signals[7:6] <= 2'b01;
        else if(!condition_met)                     control_signals[7:6] <= 2'b10;
        else                                        control_signals[7:6] <= 2'b00;
        // It is impossible for the Decode stage to be aware of a misprediction, therefore 2'b10 is not included here.
        
        //control_signals[6] <= (!branched_flag_F && (jump || branch));
        
        //control_signals[6] <= (jump || (branch && condition_met)) ? 1'b1 : 1'b0;     // Only jump if it is a JAL instruction, or if
                                                                                    // it is a branch and the condition is met
    end
    
    // Declare signals to carry Decode stage information to the pipeline register
    logic           RegWE_E_D,
                    RegWE_W_D,
                    OpBSrcD,
                    MemWriteD;
    logic [1:0]     ExPathD;
    logic [2:0]     ALUFuncD;
    
    // Distribute Decode control signals based on the vector generated above
    assign RegWE_E_D =    control_signals[12];
    assign RegWE_W_D =    control_signals[11];
    assign OpBSrcD =    control_signals[10];
    assign ExPathD =    control_signals[9:8];
    assign PCSrcE =     control_signals[7:6];
    assign ImmFormatD = control_signals[5:4];
    assign ALUFuncD =   control_signals[3:1];
    assign MemWriteD =   control_signals[0];
    
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
        branch_D, jump_D,
        ExPathD,
        ALUFuncD,
        RegWE_E_E, RegWE_W_E,           // Outputs from register
        OpBSrcE,
        MemWriteE,
        branch_E, jump_E,
        ExPathE,
        ALUFuncE
    );
    
/*
 __        __    _ _       _                _    
 \ \      / / __(_) |_ ___| |__   __ _  ___| | __
  \ \ /\ / / '__| | __/ _ \ '_ \ / _` |/ __| |/ /
   \ V  V /| |  | | ||  __/ |_) | (_| | (__|   < 
    \_/\_/ |_|  |_|\__\___|_.__/ \__,_|\___|_|\_\
                                                 
*/

    c_ex_wb_pipeline_register c_ex_wb_pipeline_register(
        clk,
        reset,
        StallW,
        FlushW,
        RegWE_E_E, RegWE_W_E,
        MemWriteE,
        RegWE_E_W, RegWE_W_W,
        MemWriteW
    );

endmodule