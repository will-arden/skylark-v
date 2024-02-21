`timescale 1ns / 1ps

module c_if_id_pipeline_register(

    input logic                 clk, reset,
                                StallD,
                                FlushD,
    
    input logic                 funct7b5_F,
    input logic [2:0]           funct3_F,
    input logic [6:0]           op_F,
                                
                                
        // I HAVE NOT INCLUDED RS1 & RS2 - these will be included in the control pipeline register
        // also haven't included any control signals (besides StallE) because they should be passed to the datapath by
        // the control pipeline register(s)

    output logic                funct7b5_D,
    output logic [2:0]          funct3_D,
    output logic [6:0]          op_D
);
    
    always_ff @(posedge clk, posedge reset) begin
        if(reset) begin
            funct7b5_D      <= 1'b0;
            funct3_D        <= 3'b000;
            op_D            <= 7'b0010011;          // Set for a NOP
        end
        else if(clk) begin
            if(FlushD) begin
                funct7b5_D      <= 1'b0;
                funct3_D        <= 3'b000;
                op_D            <= 7'b0010011;          // Set for a NOP
            end
            else if(!StallD) begin
                funct7b5_D      <= funct7b5_F;
                funct3_D        <= funct3_F;
                op_D            <= op_F;
            end
        end
    end

endmodule
