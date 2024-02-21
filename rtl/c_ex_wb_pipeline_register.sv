`timescale 1ns / 1ps

module c_ex_wb_pipeline_register(

    input logic                 clk, reset,
                                StallW,
                                FlushW,
                                RegWE_E_E, RegWE_W_E,
                                MemWriteE,
                                
    output logic                RegWE_E_W, RegWE_W_W,
                                MemWriteW
);

    always_ff @(posedge clk, posedge reset) begin
        if(reset) begin
            RegWE_E_W   <= 1'b0;
            RegWE_W_W   <= 1'b0;
            MemWriteW   <= 1'b0;
        end
        else if(clk) begin
            if(FlushW) begin
                RegWE_E_W   <= 1'b0;
                RegWE_W_W   <= 1'b0;
                MemWriteW   <= 1'b0;
            end
            else if(!StallW) begin
                RegWE_E_W   <= RegWE_E_E;
                RegWE_W_W   <= RegWE_W_E;
                MemWriteW   <= MemWriteE;
            end
        end
    end

endmodule
