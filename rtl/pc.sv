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
            PCF             <= 32'h00000000;                    // Restart program from 0x0
            branched_flag_F <= 1'b0;
       end
        else if(!StallF) begin
            if(PCSrc==2'b01) begin
                PCF             <= TargetAddr;
                branched_flag_F <= 1'b1;
            end
            else if(PCSrc==2'b10) begin
                PCF             <= PCNextE;
                branched_flag_F <= 1'b0;
            end
            else begin
                PCF             <= PCNextF;
                branched_flag_F <= 1'b0;
            end
        end
    end
    
    // PC Incrementer
    assign PCNextF = PCF + 32'h00000004;

endmodule
