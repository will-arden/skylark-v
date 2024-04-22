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
                            ms_WE_D,
                            use_register,
    output logic [1:0]      ExPathD,
                            PCSrcD,
    output logic [2:0]      ImmFormatD,
                            ALUFuncD
    
);
    
    // Detect branch/jump instructions based on 7-bit opcode
    assign branch_D         = (op_D == 7'b1100011) ? 1'b1 : 1'b0;
    assign jump_D           = ((op_D == 7'b1101111) || (op_D == 7'b1100111)) ? 1'b1 : 1'b0;

    // Generate a vector of all the control signals (improves readability)
    logic [16:0] control_signals;

    always_comb begin : comb_proc
    
        // Check for custom BNN instructions
        if(op_D == 7'b1111111) begin                        // Unique opcode not found in other RISC-V instructions
            unique case(funct3_D)
                3'b000:         control_signals <= 17'b01_0_00_1_01_00_000_000_0;    // Set Matrix Size (BNNCMS)             (I-type)
                3'b001:         control_signals <= 17'b00_0_01_0_01_00_000_100_0;    // Binarized Convolution (BCNV)         (R-type)
                default:        control_signals <= 'x;                              // Invalid instruction (or not supported)
            endcase
            condition_met_E <= 1'bx;
        end
        else begin
        
            // Checking 7-bit opcode
            unique case(op_D)
                7'b0010011:     control_signals <= 17'b00_0_10_1_00_00_000_xxx_0;   // I-type (not LOAD or JALR)
                7'b0110011:     control_signals <= 17'b00_0_10_0_00_00_000_xxx_0;   // R-type               (ImmFormatD is "don't care")
                7'b0000011:     control_signals <= 17'b00_0_01_1_00_00_000_000_0;   // LOAD instruction
                7'b0100011:     control_signals <= 17'b00_0_00_1_00_00_001_000_1;   // S-type
                7'b1100011:     control_signals <= 17'b00_0_00_0_00_xx_010_001_0;   // B-type
                7'b1101111:     control_signals <= 17'b00_0_10_0_10_01_011_000_0;   // JAL (J-type)
                7'b1100111:     control_signals <= 17'b00_1_10_1_10_01_000_000_0;   // JALR (I-type)
                7'b0110111:     control_signals <= 17'b00_0_10_1_00_00_100_000_0;   // U-type (LUI)
                default:        control_signals <= 'x;                              // Invalid instruction (or not supported)
            endcase
            
            // Checking funct3_D if necessary to decipher the specific instruction
            // This is not necessary for branch/store/load/lui instructions
            if(!branch_D && !control_signals[0] && !control_signals[12] && !control_signals[6]) begin
                unique case(funct3_D)
                    3'b000:         control_signals[3:1] <= (funct7b5_D && op_D==7'b0110011) ? 3'b001 : 3'b000; // ADD/SUB operation
                    3'b001:         control_signals[3:1] <= 3'b110;                                             // SLL operation
                    3'b010:         control_signals[3:1] <= 3'b001;                                             // SLT operation
                    3'b100:         control_signals[3:1] <= 3'b100;                                             // XOR operation
                    3'b101:         control_signals[3:1] <= 3'b111;                                             // SLR operation
                    3'b110:         control_signals[3:1] <= 3'b011;                                             // OR operation
                    3'b111:         control_signals[3:1] <= 3'b010;                                             // AND operation
                    default:        control_signals[3:1] <= 'x;                                                 // Invalid operation
                endcase
            end
            
            // Misprediction check
            if(branch_E) begin
                case (funct3_E)
                    3'b000:         condition_met_E <= Z;           // BEQ
                    3'b001:         condition_met_E <= !Z;          // BNE
                    3'b100:         condition_met_E <= N;           // BLT
                    3'b101:         condition_met_E <= !N;          // BGE
                    default:        condition_met_E <= 1'bx;        // Invalid/unsupported instruction
                endcase
            end
            else                    condition_met_E <= 1'bx;
            
            // Check for misprediction
            if(branch_E && !condition_met_E)    control_signals[8:7] <= 2'b10;
            
            // If safe from mispredictions, check for jump/branch and assume it will be taken
            else if(branch_D || jump_D)         control_signals[8:7] <= 2'b01;
            
            // Otherwise, normal PC behaviour (increment)
            else                                control_signals[8:7] <= 2'b00;
            
        end
    end
    
    // Distribute Decode control signals based on the vector generated above
    assign ms_WE_D          = control_signals[15];
    assign use_register     = control_signals[14];
    assign RegWE_E_D        = control_signals[13];
    assign RegWE_W_D        = control_signals[12];
    assign OpBSrcD          = control_signals[11];
    assign ExPathD          = control_signals[10:9];
    assign PCSrcD           = control_signals[8:7];
    assign ImmFormatD       = control_signals[6:4];
    assign ALUFuncD         = control_signals[3:1];
    assign MemWriteD        = control_signals[0];

endmodule
