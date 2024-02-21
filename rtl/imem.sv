`timescale 1ns / 1ps

module imem #(
    parameter MEM_SIZE = 32,
    parameter string IMEM_FILE = "user_data/imem.dat")
(
    
    input logic [31:0]      A,          // Address to read from
    output logic [31:0]     InstrF      // Output instruction
    
);

    logic[31:0] memory[MEM_SIZE-1:0];           // Create the structure to hold the memory (RAM)

    initial begin
        // Read the instructions into RAM
        $readmemh(IMEM_FILE, memory);           // Not synthesizable
    end
    
    assign InstrF = memory[A[31:2]];            // Ignore two LSB's since instructions are word-aligned

endmodule