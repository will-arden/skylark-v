`timescale 1ns / 1ps

module c_ex_wb_pipeline_register(

    input logic                 clk, reset,
                                StallW,
                                FlushW,
                                RegWE_E_E, RegWE_W_E,
                                MemWriteE,
                                en_threshold_E,
    input logic [1:0]           ExPathE,
                                
    output logic                RegWE_E_W, RegWE_W_W,
                                MemWriteW,
                                en_threshold_W,
    output logic [1:0]          ExPathW
);

    always_ff @(posedge clk, posedge reset) begin : seq_proc
        if(reset) begin
            RegWE_E_W       <= 1'b0;
            RegWE_W_W       <= 1'b0;
            MemWriteW       <= 1'b0;
            en_threshold_W  <= 1'b0;
            ExPathW         <= 2'b0;
        end
        else if(clk) begin
            if(FlushW) begin
                RegWE_E_W       <= 1'b0;
                RegWE_W_W       <= 1'b0;
                MemWriteW       <= 1'b0;
                en_threshold_W  <= 1'b0;
                ExPathW         <= 2'b0;
            end
            else if(!StallW) begin
                RegWE_E_W       <= RegWE_E_E;
                RegWE_W_W       <= RegWE_W_E;
                MemWriteW       <= MemWriteE;
                en_threshold_W  <= en_threshold_E;
                ExPathW         <= ExPathE;
            end
        end
    end

endmodule
