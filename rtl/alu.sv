`timescale 1ns / 1ps

module alu (
    
    input logic [31:0]      OpA, OpB, ExtImmE,
    input logic [2:0]       ALUFuncE,
    input logic             OpBSrcE,
    
    output logic [31:0]     result,
    output logic            Z,
                            N
    
);

    logic [31:0] s_OpB;                             // Holds the selected value for OpB (Register or ExtImm)
    assign s_OpB = (OpBSrcE) ? ExtImmE : OpB;       // Select between the two options for operand B
    
    // Look-up table for the ALU operation provided by the control
    always_comb begin
    
        logic [31:0] s_OpB_2s_complement;
        s_OpB_2s_complement = (s_OpB[31]) ? (~s_OpB + 1'b1) : s_OpB;
    
        case(ALUFuncE)
            3'b000:     result = OpA + s_OpB;                                   // ADD (and I-type SUB)
            3'b001:     result = OpA - s_OpB;                                   // SUB (R-type only)
            3'b010:     result = OpA & s_OpB;                                   // AND
            3'b011:     result = OpA | s_OpB;                                   // OR
            3'b100:     result = OpA ^ s_OpB;                                   // XOR
            3'b101:     result = (OpA < s_OpB) ? 32'h00000001 : 32'h00000000;   // Set Less Than (SLT)
            3'b110:     result = OpA << s_OpB[5:0];                             // Shift Logical Left (SLL)
            3'b111:     result = OpA >> s_OpB[5:0];                             // Shift Logical Right (SLR)
            default:    result = 32'hXXXXXXXX;                                  // Illegal ALUFuncE
        endcase
    end
    
    // Assign flags based on result
    assign Z = (result == 32'h00000000) ? 1'b1 : 1'b0;          // Zero
    assign N = result[31];                                      // Negative

endmodule