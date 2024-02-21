`timescale 1ns / 1ps

module dp_id_ex_pipeline_register(

    input logic                 clk, reset,
                                StallE,
                                FlushE,
                                                    // Datapath signals (ALL sent from the Decode stage)
    input logic [4:0]           A1_D, A2_D,             // Register source addresses
                                A3_D, A4_D,             // Register addresses used for writing back to register file
    input logic [31:0]          RD1_D, RD2_D,           // Carries the register data to the next pipeline stage
                                PCD,                    // Program counter value, used by the AGU
                                PCNextD,                // Incremented PC, used for JAL instructions
                                ExtImmD,                // 32-bit extended immediate value - may be used by the 

    output logic [4:0]          A1_E, A2_E,
                                A3_E, A4_E,
    output logic [31:0]         RD1_E, RD2_E,
                                PCE,
                                PCNextE,
                                ExtImmE
);  
    
    always_ff @(posedge clk, posedge reset) begin
        if(reset) begin
            A1_E            <= 32'h00000000;
            A2_E            <= 32'h00000000;
            A3_E            <= 32'h00000000;
            A4_E            <= 32'h00000000;
            RD1_E           <= 32'h00000000;
            RD2_E           <= 32'h00000000;
            PCE             <= 32'h00000000;
            PCNextE         <= 32'h00000000;
            ExtImmE         <= 32'h00000000;
        end
        else if(clk) begin
            if(FlushE) begin
                A1_E            <= 32'h00000000;
                A2_E            <= 32'h00000000;
                A3_E            <= 32'h00000000;
                A4_E            <= 32'h00000000;
                RD1_E           <= 32'h00000000;
                RD2_E           <= 32'h00000000;
                PCE             <= 32'h00000000;
                PCNextE         <= 32'h00000000;
                ExtImmE         <= 32'h00000000;
            end
            else if(!StallE) begin
                A1_E            <= A1_D;
                A2_E            <= A2_D;
                A3_E            <= A3_D;
                A4_E            <= A4_D;
                RD1_E           <= RD1_D;
                RD2_E           <= RD2_D;
                PCE             <= PCD;
                PCNextE         <= PCNextD;
                ExtImmE         <= ExtImmD;
            end
        end
    end

endmodule
