module pc(

    input logic             clk, reset,
                            StallF,
    input logic [1:0]       PCSrc,
    input logic [31:0]      TargetAddr,
                            PCNextE,
    
    output logic            branched_flag_F,
    output logic [31:0]     PCF,
                            PCNextF
                            
);

    always_ff @(posedge clk, posedge reset) begin
        if(reset) begin
            PCF             <= 32'h00000000;                // Restart program from 0x0
            branched_flag_F <= 1'b0;
       end
        else if(!StallF) begin                              // Unless the pipeline is stalled
            if(PCSrc==2'b01) begin                              // If branch predicted,
                PCF             <= TargetAddr;                      // update the PC and
                branched_flag_F <= 1'b1;                            // assert the branched flag
            end
            else if(PCSrc==2'b10) begin                         // If a previous branch instruction was mispredicted,
                PCF             <= PCNextE;                         // get the correct PC value from the Execute stage and
                branched_flag_F <= 1'b0;                            // reset the branched flag
            end
            else begin                                          // Otherwise,
                PCF             <= PCNextF;                         // update the PC (add 4) and
                branched_flag_F <= 1'b0;                            // reset the branched flag
            end
        end
    end
    
    // PC Incrementer
    assign PCNextF = PCF + 32'h00000004;

endmodule
