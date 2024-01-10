`timescale 1ns/1ps

module control(

    // Instruction fields for RV32I
    input logic [6:0]           op,
    input logic [2:0]           funct3,
    input logic                 funct7b5,
    
    // Outputs to datapath
    output logic                RegWE_E,                // Register Write Enable                        (Execute)
                                RegWE_W,                //                                              (Writeback)
                                OpBSrcE,                // Select ALU operand B source                  (Execute)
                                ExPathE,                // Select desired Execute stage path            (Execute)
                                PCSrcE,                 // Selects branch target address or +4          (Execute)
    output logic [1:0]          ImmFormatD,             // Format of immediate value for Extend Unit    (Decode)
    output logic [2:0]          ALUFuncE,               // Controls the ALU's operation                 (Execute)
    
    // Outputs to external destinations
    output logic                MemWrite
);

    logic [10:0] control_signals;

    always_comb begin
        case(op)
            7'b0010011:     control_signals = 11'b10_1_0_0_00_xxx_0;    // I-type (not LOAD)
            7'b0110011:     control_signals = 11'b10_0_0_0_00_xxx_0;    // R-type               (ImmFormatD is "don't care")
            7'b0000011:     control_signals = 11'b01_1_0_0_00_000_0;    // LOAD instruction
            7'b0100011:     control_signals = 11'b00_1_0_0_01_000_1;    // S-type
            7'b1100011:     control_signals = 11'b00_1_0_1_10_000_0;    // B-type
            7'b1101111:     control_signals = 11'b00_1_0_1_11_000_0;    // J-type (not JALR)
            default:        control_signals = 'x;                       // Invalid instruction (or not supported)
        endcase
        
        case(funct3)
            3'b000:         control_signals[3:1] = 3'b000;      // ADD/SUB operation (2's complement means it does not matter)
            3'b010:         control_signals[3:1] = 3'b001;      // SLT operation
            3'b100:         control_signals[3:1] = 3'b100;      // XOR operation
            3'b110:         control_signals[3:1] = 3'b011;      // OR operation
            3'b111:         control_signals[3:1] = 3'b010;      // AND operation
            default:        control_signals[3:1] = 'x;          // Invalid operation
        endcase
        
    end
    
    assign RegWE_E =    control_signals[10];
    assign RegWE_W =    control_signals[9];
    assign OpBSrcE =    control_signals[8];
    assign ExPathE =    control_signals[7];
    assign PCSrcE =     control_signals[6];
    assign ImmFormatD = control_signals[5:4];
    assign ALUFuncE =   control_signals[3:1];
    assign MemWrite =   control_signals[0];


    /*
    assign RegWE_E = 1'b1; assign RegWE_W = 1'b1;
    assign OpBSrcE = 1'b0;
    assign ExPathE = 1'b0;
    assign PCSrcE = 1'b0;
    assign ImmFormatD = 2'b00;
    assign ALUFuncE = 3'b000;
    assign MemWrite = 1'b0;
    */

endmodule
