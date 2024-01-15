`timescale 1ns/1ps

`define IMEM_PATH "C:/Users/willa/RISCV_core/user_data/fibonacci.dat"
`define IMEM_SIZE 32
`define DMEM_SIZE 64

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
    
// -------------- INSTRUCTION MEMORY -------------- //

    imem #(`IMEM_SIZE, `IMEM_PATH) imem(
        PCF,
        InstrF
    );
    
// -------------- DATA MEMORY -------------- //

    logic [31:0]        WriteAddr;

    dmem #(`DMEM_SIZE) dmem(
        clk, reset,
        MemWrite,
        WriteAddr,
        WriteData,
        ReadData
    );
    
// -------------- SIMULATION -------------- //

    initial begin
    
        // Initialize core inputs
        clk = 1'b0;
        WriteAddr = 32'h00000000;
        
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
