`timescale 1ns / 1ps

`define IMEM_SIZE 16
`define DMEM_SIZE 64

module soc(

    input logic             CLK100MHZ, btnC,
    output logic [3:0]      an,
    output logic [6:0]      seg,
    output logic [15:0]     LED

);

    // Declare signals
    logic               clk, reset, MemWriteW, num;
    logic [31:0]        InstrF, ReadData, ALUResultW, WriteData, PCF;
    
    // Map physical signals
    assign clk          = CLK100MHZ;
    assign reset        = btnC;
    
// -------------- BOARD PERIPHERALS -------------- //

    assign LED[15:2]    = '0;
    assign an[3:0]      = 4'b1110;          // Turn off all other displays apart from 0
    
    assign seg = 7'b0010010;                // Display 'S' for "skylark"
    
    always_comb begin
    
        // Swapping out these two if statements proves that the program is reaching an infinite JAL terminate loop
        
        if(InstrF == 32'h00000fef) begin                    // JAL Instruction
        //if(InstrF == 32'hFFFFFFFF) begin                    // Invalid instruction
            LED[0] <= 1'b1;
            LED[1] <= 1'b0;
        end
        else begin
            LED[0] <= 1'b0;
            LED[1] <= 1'b1;
        end
        
    end
    
// -------------- SKYLARK-V CORE -------------- //

    skylark_core skylark_core(
        clk, reset,                 // Essential inputs
        InstrF,                     // Input from instruction memory
        ReadData,                   // Input from data memory
        MemWriteW,                  // Output to data memory, to enable writing
        ALUResultW,                 // Output to data memory, to provide the write address
        WriteData,                  // Output to data memory, to provide the write data
        PCF                         // Output to instruction memory, to receive the data at this address
    );
    
// -------------- DATA MEMORY -------------- //

    dmem #(`DMEM_SIZE) dmem(
        clk, reset,
        MemWriteW,
        ALUResultW,
        WriteData,
        ReadData
    );
    
// -------------- INSTRUCTION MEMORY -------------- //

    logic[31:0] memory[`DMEM_SIZE-1:0];             // Create the structure to hold the memory (RAM)

    initial begin
        
        // Manually assign each line of instruction memory
        memory[0]       <= 32'h00300513;
        memory[1]       <= 32'h00100093;
        memory[2]       <= 32'h00200113;
        memory[3]       <= 32'h002081b3;
        memory[4]       <= 32'h40218333;
        memory[5]       <= 32'h00148493;
        memory[6]       <= 32'h00302023;
        memory[7]       <= 32'h00002203;
        memory[8]       <= 32'h00120393;
        memory[9]       <= 32'hfea490e3;
        memory[10]      <= 32'h00000fef;
        memory[11]      <= 32'h00000013;
        memory[12]      <= 32'h00000013;
        memory[13]      <= 32'h00000013;
        memory[14]      <= 32'h00000013;
        memory[15]      <= 32'h00000013;
        memory[16]      <= 32'h00000013;

    end
    
    assign InstrF = memory[PCF[31:2]];              // Ignore two LSB's since instructions are word-aligned

endmodule
