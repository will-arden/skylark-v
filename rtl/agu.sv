`timescale 1ns / 1ps

module agu(

    input logic             use_register,       // Flag which selects between operands
    input logic [31:0]      ExtImmD,            // Immediate value (address offset)
                            PCD,                // PC value (base address)
                            RD1_D,              // Source Register (for JALR)
    output logic [31:0]     TargetAddr          // base + offset

);

    assign TargetAddr = (!use_register) ? ExtImmD + PCD : ExtImmD + RD1_D;

endmodule