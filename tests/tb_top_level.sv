`timescale 1ns / 1ps

`define IMEM_PATH "C:/Users/willa/skylark-v/user_data/program7.dat"
`define IMEM_SIZE 32
`define DMEM_SIZE 64

module tb_top_level;

// -------------- CORE -------------- //

    // Inputs to core
    logic           clk, reset;
    logic [31:0]    InstrF, ReadData;
    
    // Outputs from core
    logic           MemWriteW;
    logic [31:0]    ALUResultW, WriteData, PCF;

    // Instantiate core
    skylark_core skylark_core(
        clk,
        reset,
        InstrF,
        ReadData,
        MemWriteW,
        ALUResultW,
        WriteData,
        PCF
    );
    
// -------------- RESET AND CLOCK -------------- //

    initial begin
        reset <= 1'b1;
        #15;
        reset <= 1'b0;
    end
    
    always begin
        clk <= 1'b1;
        #10;
        clk <= 1'b0;
        #10;
    end
    
// -------------- EXTERNAL MEMORIES -------------- //

    imem #(`IMEM_SIZE, `IMEM_PATH) imem(
        PCF,
        InstrF
    );

    dmem #(`DMEM_SIZE) dmem(
        clk, reset,
        MemWriteW,
        ALUResultW,
        WriteData,
        ReadData
    );

endmodule
