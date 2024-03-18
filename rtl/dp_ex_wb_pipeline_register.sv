`timescale 1ns / 1ps

module dp_ex_wb_pipeline_register(

    input logic                 clk, reset,
                                StallW,
                                FlushW,
    input logic [4:0]           A3_E, A4_E,
    input logic [31:0]          OpB_E,              // Write data to external memory, for SW operations
                                ALUResultE,
                                length_adjusted_E,  // Input prepared for the BNN popcount operation
                                PCNextE,

    output logic [4:0]          A3_W, A4_W,
    output logic [31:0]         RD2_W,
                                ALUResultW,
                                length_adjusted_W,
                                PCNextW
);

    always_ff @(posedge clk, posedge reset) begin : seq_proc
        if(reset) begin
            A3_W                <= 5'b00000;
            A4_W                <= 5'b00000;
            RD2_W               <= 32'h00000000;
            ALUResultW          <= 32'h00000000;
            length_adjusted_W   <= 32'h00000000;
            PCNextW             <= 32'h00000000;
        end
        else if(clk) begin
            if(FlushW) begin
                A3_W                <= 5'b00000;
                A4_W                <= 5'b00000;
                RD2_W               <= 32'h00000000;
                ALUResultW          <= 32'h00000000;
                length_adjusted_W   <= 32'h00000000;
                PCNextW             <= 32'h00000000;
            end
            else if(!StallW) begin
                A3_W                <= A3_E;
                A4_W                <= A4_E;
                RD2_W               <= OpB_E;
                ALUResultW          <= ALUResultE;
                length_adjusted_W   <= length_adjusted_E;
                PCNextW             <= PCNextE;
            end
        end
    end

endmodule
