`timescale 1ns/1ps

module control(

    // Instruction fields for RV32I
    input logic [6:0]           op,
    input logic [2:0]           funct3,
    input logic                 funct7b5,
    
    // Inputs from datapath
    input logic                 zero,
                                negative,
    
    // Outputs to datapath
    output logic                RegWE_E,                // Register Write Enable                        (Execute)
                                RegWE_W,                //                                              (Writeback)
                                OpBSrcE,                // Select ALU operand B source                  (Execute)
                                PCSrcE,                 // Selects branch target address or +4          (Execute)
    output logic [1:0]          ExPathE,                // Select desired Execute stage path            (Execute)
                                ImmFormatD,             // Format of immediate value for Extend Unit    (Decode)
    output logic [2:0]          ALUFuncE,               // Controls the ALU's operation                 (Execute)
    
    // Outputs to external destinations
    output logic                MemWrite
);

    logic       branch,                 // Set if the opcode indicates a branch instruction
                jump,                   // Set if the opcode indicates a jump instruction
                condition_met;          // Set if the branch condition is met
                
    assign branch           = (op == 7'b1100011) ? 1'b1 : 1'b0;
    assign jump             = (op == 7'b1101111) ? 1'b1 : 1'b0;

    logic [11:0] control_signals;

    always_comb begin
    
        // Generate a vector of all the control signals (improves readability)
        unique case(op)
            7'b0010011:     control_signals = 12'b10_1_00_0_00_xxx_0;    // I-type (not LOAD)
            7'b0110011:     control_signals = 12'b10_0_00_0_00_xxx_0;    // R-type               (ImmFormatD is "don't care")
            7'b0000011:     control_signals = 12'b01_1_00_0_00_000_0;    // LOAD instruction
            7'b0100011:     control_signals = 12'b00_1_00_0_01_000_1;    // S-type
            7'b1100011:     control_signals = 12'b00_0_00_x_10_001_0;    // B-type
            7'b1101111:     control_signals = 12'b10_0_10_1_11_000_0;    // J-type (not JALR)
            default:        control_signals = 'x;                       // Invalid instruction (or not supported)
        endcase
        
        if(!branch) begin
            unique case(funct3)
                3'b000:         control_signals[3:1] = (funct7b5 && op==7'b0110011) ? 3'b001 : 3'b000;    // ADD/SUB operation
                3'b010:         control_signals[3:1] = 3'b001;                          // SLT operation
                3'b100:         control_signals[3:1] = 3'b100;                          // XOR operation
                3'b110:         control_signals[3:1] = 3'b011;                          // OR operation
                3'b111:         control_signals[3:1] = 3'b010;                          // AND operation
                default:        control_signals[3:1] = 'x;                              // Invalid operation
            endcase
            condition_met = 1'bx;       // For non-branch instructions, the condition doesn't matter. This line avoids latch generation.
        end
        else begin
            unique case (funct3)
                3'b000:         condition_met = zero;               // BEQ
                3'b001:         condition_met = !zero;              // BNE
                3'b100:         condition_met = negative;           // BLT
                3'b101:         condition_met = !negative;          // BGE
                default:        condition_met = 1'bx;               // Invalid/unsupported instruction
            endcase
        end
        
        control_signals[6] = (jump || (branch && condition_met)) ? 1'b1 : 1'b0;     // Only jump if it is a JAL instruction, or if
                                                                                    // it is a branch and the condition is met
    end
    
    // Distribute control signals based on the vector generated above
    assign RegWE_E =    control_signals[11];
    assign RegWE_W =    control_signals[10];
    assign OpBSrcE =    control_signals[9];
    assign ExPathE =    control_signals[8:7];
    assign PCSrcE =     control_signals[6];
    assign ImmFormatD = control_signals[5:4];
    assign ALUFuncE =   control_signals[3:1];
    assign MemWrite =   control_signals[0];

endmodule
