`include "../rtl/ALU.sv"
`timescale 1ns/1ps

module tb_ALU;

    logic [31:0]      srcA, srcB_reg, srcB_ImmExt;
    logic [2:0]       ALUControl;
    logic             ALUSrc;


    tri [31:0]       ALUResult;
    logic            zero_out;

    // Instantiate ALU
    ALU dut (
        srcA, srcB_reg, srcB_ImmExt,
        ALUControl,
        ALUSrc,
        ALUResult,
        zero_out
    );

    // Test vector
    initial begin
        $dumpfile("dut.vcd");
        $dumpvars(0,dut);

        // Initialise all signals
        srcA = '0; srcB_ImmExt = '0; srcB_reg = '0;
        ALUControl = '0; ALUSrc = 1'b0;
        #1;

        srcA = 32'h00000005; srcB_reg = 32'h00000003;
        ALUControl = 3'b000;
        #10;

        srcA = 32'h00000005; srcB_reg = 32'h00000003;
        ALUControl = 3'b101;
        #10;

        srcA = 32'h00000005; srcB_ImmExt = 32'h0000000F;
        ALUControl = 3'b101;
        ALUSrc = 1'b1;
        #10;

        srcA = 32'h0400AB05; srcB_ImmExt = 32'h21700F03;
        ALUControl = 3'b010;
        #10;
    end

endmodule
