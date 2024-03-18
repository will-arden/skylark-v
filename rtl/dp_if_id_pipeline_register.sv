`timescale 1ns / 1ps

module dp_if_id_pipeline_register(

    input logic                 clk, reset,
                                StallD,
                                FlushD,
    input logic [31:0]          InstrF,
                                PCF,
                                PCNextF,
                                
    output logic[31:0]          InstrD,
                                PCD,
                                PCNextD
);

    always_ff @(posedge clk, posedge reset) begin : seq_proc
        if(reset) begin
            InstrD      <= 32'h00000013;            // Set for NOP
            PCD         <= 32'h00000000;
            PCNextD     <= 32'h00000000;
        end
        else if(clk) begin
            if(FlushD) begin
                InstrD      <= 32'h00000013;            // Set for NOP
                PCD         <= 32'h00000000;
                PCNextD     <= 32'h00000000;
            end
            else if(!StallD) begin
                InstrD      <= InstrF;
                PCD         <= PCF;
                PCNextD     <= PCNextF;
            end
        end
    end

endmodule
