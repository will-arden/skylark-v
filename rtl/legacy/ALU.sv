/*
Legacy Arithmetic Logic Unit (ALU)

This combinational module accepts two operands, srcA and srcB, and performs some operation on them
to output ALUResult. The function is selected using ALUControl, which is sent from the Control Unit.

srcA is input directly by the RD1 of the register file.
srcB is either input from the RD2 of the register file, or it is input from the sign extend unit (ImmExt).
This selection is controlled by the ALUSrc input from the Control Unit.

As well as outputting ALUResult, the ALU should set high the zero_out signal which is sent to the Control Unit.

The data widths of the input operands and ALUResult are 32-bit.
The ALUControl is 3-bit, with each setting corresponding to the following function:
    ALUControl          Instruction         Description
    000                 ADD                 Sum both operands.
    001                 SUB                 Subtract srcB from srcA.
    010                 AND                 srcA & srcB.
    011                 OR                  srcA | srcB.
    101                 SLT                 Set if srcB - srcA < 0.
*/

module ALU (
    input logic signed [31:0]       srcA, srcB_reg, srcB_ImmExt,
    input logic signed [2:0]        ALUControl,
    input logic                     ALUSrc,

    output tri signed [31:0]        ALUResult,
    output logic                    zero_out
);

logic [31:0] temp_result;           // Temporary ALUResult
logic [31:0] srcB;                  // Internal signal for the chosen value of srcB

always_comb begin
    
    // Select srcB source (reg file / ImmExt)
    if(ALUSrc) srcB = srcB_ImmExt;
    else srcB = srcB_reg;

    // Compute ALUResult
    case(ALUControl)
        3'b000:             temp_result = srcA + srcB;                                      // ADD
        3'b001:             temp_result = srcA - srcB;                                      // SUB
        3'b010:             temp_result = srcA & srcB;                                      // AND
        3'b011:             temp_result = srcA | srcB;                                      // OR
        3'b101:             temp_result = (srcB > srcA) ? 32'h00000001 : 32'h00000000;      // SLT
        default:            temp_result = 'x;                                               // Illegal ALUSrc
    endcase

    // zero_out check
    if(temp_result==0) zero_out = 1'b1;
    else zero_out = 1'b0;

end

assign ALUResult = temp_result;     // temp value is passed to ALUResult

endmodule
