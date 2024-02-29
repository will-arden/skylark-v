`timescale 1ns / 1ps

module bnn(

    input logic                 clk, reset,
                                en_threshold_E,     // Enables activation threshold logic
                                ms_WE,              // Write Enable for matrix_size register
    input logic signed [31:0]   ExtImmE,            // Activation threshold
    input logic [31:0]          ALUResultE,         // XOR result
    output logic [31:0]         BNNResult

);

    logic [31:0] matrix_size;

    // Write to matrix_size
    always_ff @(posedge clk, posedge reset) begin
        if(reset) begin
            matrix_size <= 32'h00000009;                // 3x3 matrix size by default
        end
        else begin
            if(ms_WE)       matrix_size <= ExtImmE;     // BNNCMS instruction is I-type
        end
    end

    logic [31:0] xnor_data;
    assign xnor_data = ~ALUResultE;           // XNOR computation
    
    // Popcount operation
    logic [31:0] c;
    integer i;
    always_comb begin
        c = '0;
        for(i = 0; i < matrix_size; i++) begin
            c += xnor_data[i];
        end
    end
    
    // Activation threshold
    logic           [31:0] activation;
    logic signed    [31:0] c_shifted;
    
    assign c_shifted    = (c << 1) - matrix_size;
    assign activation = (c_shifted >= ExtImmE) ? 32'h00000001 : 32'h00000000;
    
    // Produce final output depending on the threshold enable
    assign BNNResult = (en_threshold_E) ? activation : c_shifted;

endmodule



