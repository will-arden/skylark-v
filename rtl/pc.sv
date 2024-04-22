`timescale 1ns / 1ps

module pc(

    input logic             clk, reset,
                            StallF,
    input logic [1:0]       PCSrc,
    input logic [31:0]      TargetAddr,
                            PCNextE,
    
    output logic [31:0]     PCF,
                            PCNextF
                            
);

    always_ff @(posedge clk, posedge reset) begin : seq_proc
        if(reset) begin
            PCF             <= 32'h00000000;                // Restart program from 0x0
       end
        else if(!StallF) begin                              // Unless the pipeline is stalled
            if(PCSrc==2'b01) begin                              // If branch predicted,
                PCF             <= TargetAddr;                      // update the PC
            end
            else if(PCSrc==2'b10) begin                         // If a previous branch instruction was mispredicted,
                PCF             <= PCNextE;                         // get the correct PC value from the Execute stage and
            end
            else begin                                          // Otherwise,
                PCF             <= PCNextF;                         // update the PC (add 4) and
            end
        end
    end
    
    // PC Incrementer
    assign PCNextF = PCF + 32'h00000004;

endmodule
