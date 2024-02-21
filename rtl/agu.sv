`timescale 1ns / 1ps

module agu(

    input logic [31:0]      ExtImmE,            // Immediate value (address offset)
                            PCE,                // PC value (base address)
    output logic [31:0]     TargetAddr          // base + offset

);

    assign TargetAddr = ExtImmE + PCE;

endmodule