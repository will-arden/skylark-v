`timescale 1ns / 1ps

module pc(

    input logic             clk, reset,
                            PCSrcE,
    input logic [31:0]      TargetAddr,
    output logic [31:0]     PCF,
                            PCNextF

);

    always_ff @(posedge clk, posedge reset) begin
        if(reset)                   PCF = 32'h00000000;                         // Restart program from 0x0
        else if(clk && !reset)      PCF = (PCSrcE) ? TargetAddr : PCNextF;      // Select next PC value
    end
    
    assign PCNextF = PCF + 32'h00000004;
    
    
endmodule
