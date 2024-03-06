`timescale 1ns / 1ps

module decoder(
    
    input logic             branch_E,
                            N, Z,
                            funct7b5_D,
    input logic [2:0]       funct3_D,
                            funct3_E,
    input logic [6:0]       op_D,
    
    output logic            RegWE_E_D, RegWE_W_D,
                            branch_D, jump_D,
                            condition_met_E,
                            OpBSrcD,
                            MemWriteD,
                            en_threshold_D,
                            ms_WE_D,
                            at_WE_D,
    output logic [1:0]      ExPathD,
                            PCSrcE,
                            ImmFormatD,
    output logic [2:0]      ALUFuncD
    
);
    
    // Detect branch/jump instructions based on 7-bit opcode
    assign branch_D         = (op_D == 7'b1100011) ? 1'b1 : 1'b0;
    assign jump_D           = (op_D == 7'b1101111) ? 1'b1 : 1'b0;

    // Generate a vector of all the control signals (improves readability)
    logic [15:0] control_signals;

    always_comb begin
    
        // Check for custom BNN instructions
        if(op_D == 7'b1111111) begin                        // Unique opcode not found in other RISC-V instructions
            unique case(funct3_D)
                3'b000:         control_signals <= 16'b01x_00_1_01_00_00_000_0;     // Set Matrix Size (BNNCMS)             (I-type)
                3'b001:         control_signals <= 16'b000_10_0_01_00_00_100_0;     // Binarized Convolution (BCNV)         (R-type)
                3'b010:         control_signals <= 16'b001_10_0_01_00_01_100_0;     // BNN Operation (BNN)                  (R-type)
                3'b011:         control_signals <= 16'b10x_00_1_01_00_00_000_0;     // Set Activation Threshold (BNNCAT)    (I-type)
                default:        control_signals <= 'x;                              // Invalid instruction (or not supported)
            endcase
        end
        else begin
        
            // Checking 7-bit opcode
            unique case(op_D)
                7'b0010011:     control_signals <= 16'b00x_10_1_00_00_00_xxx_0;  // I-type (not LOAD)
                7'b0110011:     control_signals <= 16'b00x_10_0_00_00_00_xxx_0;  // R-type               (ImmFormatD is "don't care")
                7'b0000011:     control_signals <= 16'b00x_01_1_00_00_00_000_0;  // LOAD instruction
                7'b0100011:     control_signals <= 16'b00x_00_1_00_00_01_000_1;  // S-type
                7'b1100011:     control_signals <= 16'b00x_00_0_00_xx_10_001_0;  // B-type
                7'b1101111:     control_signals <= 16'b00x_10_0_10_01_11_000_0;  // J-type (not JALR)
                default:        control_signals <= 'x;                          // Invalid instruction (or not supported)
            endcase
            
            // Checking funct3_D if necessary to decipher the specific instruction
            if(!branch_D && !control_signals[0] && !control_signals[11]) begin  // Not necessary for branch/store/load instructions
                unique case(funct3_D)
                    3'b000:         control_signals[3:1] <= (funct7b5_D && op_D==7'b0110011) ? 3'b001 : 3'b000; // ADD/SUB operation
                    3'b010:         control_signals[3:1] <= 3'b001;                                             // SLT operation
                    3'b100:         control_signals[3:1] <= 3'b100;                                             // XOR operation
                    3'b110:         control_signals[3:1] <= 3'b011;                                             // OR operation
                    3'b111:         control_signals[3:1] <= 3'b010;                                             // AND operation
                    default:        control_signals[3:1] <= 'x;                                                 // Invalid operation
                endcase
            end
            
            // Misprediction check
            if(branch_E) begin
                unique case (funct3_E)
                    3'b000:         condition_met_E <= Z;           // BEQ
                    3'b001:         condition_met_E <= !Z;          // BNE
                    3'b100:         condition_met_E <= N;           // BLT
                    3'b101:         condition_met_E <= !N;          // BGE
                    default:        condition_met_E <= 1'bx;               // Invalid/unsupported instruction
                endcase
            end
            
            // Check for misprediction
            if(branch_E && !condition_met_E)    control_signals[7:6] <= 2'b10;
            
            // If safe from mispredictions, check for jump/branch and assume it will be taken
            else if(branch_D || jump_D)         control_signals[7:6] <= 2'b01;
            
            // Otherwise, normal PC behaviour (increment)
            else                                control_signals[7:6] <= 2'b00;
            
        end
    end
    
    // Distribute Decode control signals based on the vector generated above
    assign at_WE_D          = control_signals[15];
    assign ms_WE_D          = control_signals[14];
    assign en_threshold_D   = control_signals[13];
    assign RegWE_E_D        = control_signals[12];
    assign RegWE_W_D        = control_signals[11];
    assign OpBSrcD          = control_signals[10];
    assign ExPathD          = control_signals[9:8];
    assign PCSrcE           = control_signals[7:6];
    assign ImmFormatD       = control_signals[5:4];
    assign ALUFuncD         = control_signals[3:1];
    assign MemWriteD        = control_signals[0];

endmodule
