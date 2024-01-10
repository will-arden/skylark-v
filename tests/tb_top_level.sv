`timescale 1ns/1ps

`define IMEM_SIZE 16

module tb_top_level;

// -------------- CORE --------------

    // Inputs to core
    logic           clk, reset;
    logic [31:0]    InstrF, ReadData;
    
    // Outputs from core
    logic           MemWrite;
    logic [31:0]    ALUResult, WriteData, PCF;

    // Instantiate core
    rv_core rv_core(
        clk,
        reset,
        InstrF,
        ReadData,
        MemWrite,
        ALUResult,
        WriteData,
        PCF
    );
    
// -------------- INSTRUCTION MEMORY --------------

    imem #(`IMEM_SIZE, "C:/Users/willa/RISCV_core/user_data/imem.dat") imem(
        PCF,
        InstrF
    );
    
// -------------- SIMULATION --------------

    initial begin
    
        // Initialize core inputs
        clk = 1'b0;
        //InstrF = 32'h00000000;
        ReadData = 32'h00000000;
        
        // Reset device by toggling reset signal
        reset <= 1'b1;
        #10;
        reset <= 1'b0;
        
    end
    
    // Generate clock signal
    always begin
        clk <= !clk;
        #10;
    end

endmodule
