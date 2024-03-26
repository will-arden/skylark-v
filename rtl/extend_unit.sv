`timescale 1ns / 1ps

module extend_unit(

    input logic [2:0]       ImmFormatD,
    input logic [31:7]      bits_in,
    
    output logic [31:0]     ExtImmD      

);

    // Placeholder signals
    logic [11:0] unExt_12;
    logic [12:0] unExt_13;
    logic [19:0] unExt_20;
    logic [20:0] unExt_21;

    always_comb begin : comb_proc
        unique case(ImmFormatD)
            3'b000: begin                                                                       // I-type format
                unExt_12 <= bits_in[31:20];                                                         // Bit swizzle
                ExtImmD <= { {20{unExt_12[11]}}, unExt_12 };                                        // Extend
            end
            3'b001: begin                                                                       // S-type format
                unExt_12 <= {bits_in[31:25], bits_in[11:7]};                                        // Bit swizzle
                ExtImmD <= { {20{unExt_12[11]}}, unExt_12 };                                        // Extend
            end
            3'b010: begin                                                                       // B-type format
                unExt_13 <= {bits_in[31], bits_in[7], bits_in[30:25], bits_in[11:8], 1'b0};         // Bit swizzle
                ExtImmD <= { {19{unExt_13[12]}}, unExt_13 };                                        // Extend
            end
            3'b011: begin                                                                       // J-type format
                unExt_21 <= {bits_in[31], bits_in[19:12], bits_in[20], bits_in[30:21], 1'b0};       // Bit swizzle
                ExtImmD <= { {11{unExt_21[20]}}, unExt_21 };                                        // Extend
            end
            3'b100: begin                                                                       // U-type format
                unExt_20 <= bits_in[31:12];                                                         // Select bits
                ExtImmD <= {unExt_20, 12'h000};                                                     // Zero LSBs
            end
            default: begin              // Invalid format (should never occur)
                unExt_12 <= 'x;
                unExt_13 <= 'x;
                unExt_20 <= 'x;
                unExt_21 <= 'x;
            end
        endcase

    end
    
    

endmodule