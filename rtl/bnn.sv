`timescale 1ns / 1ps

module bnn(

    input logic                 clk, reset,
                                ms_WE,              // Write Enable for matrix_size register
    input logic signed [31:0]   ExtImmE,            // Write Data
    input logic [31:0]          ALUResultE,         // XOR result
    input logic [2:0]           popcnt_lvl2_W[7:0],
    output logic [2:0]          popcnt_lvl2_E[7:0],
    output logic [31:0]         BNNResult           // Final BNN result

);

// -------------- BNN CONTROL LOGIC -------------- //

    // Create control register(s)
    logic           [31:0] matrix_size;

    // Write to matrix_size
    always_ff @(posedge clk, posedge reset) begin : ms_write
        if(reset)
            matrix_size             <= 32'h00000009;                // 3x3 matrix size by default
        else
            if(ms_WE)       matrix_size             <= ExtImmE;     // BNNCMS instruction is I-type
    end
    
// -------------- PREPARING POPCOUNT INPUT -------------- //

    logic [31:0] xnor_data;
    assign xnor_data = ~ALUResultE;           // XNOR computation
    
    logic [31:0] length_adjusted_E;
    
    integer i;
    
    // Length adjusting popcount input to match matrix size
    always_comb begin : length_adjust_comb
        for(i=0; i < 32; i++) begin
            if(i < matrix_size)         length_adjusted_E[i] <= xnor_data[i];
            else                        length_adjusted_E[i] <= 1'b0;
        end
    end
    
// -------------- POPCOUNT OPERATION -------------- //
    
    logic [1:0] popcnt_lvl1_E[15:0];            // 16   2-bit numbers
    // Popcount level 2 is pipelined            // 8    3-bit numbers
    logic [3:0] popcnt_lvl3_W[3:0];             // 4    4-bit numbers
    logic [4:0] popcnt_lvl4_W[1:0];             // 2    5-bit numbers
    logic [5:0] popcnt_result;                  // 1    6-bit number (the result of the popcount)
    
    genvar v, w, x, y, z;
    
    // First layer of popcount operation
    generate
        for(v=0; v < 16; v++) begin     // Max value: 2'b10 (2)
            assign popcnt_lvl1_E[v] = { {length_adjusted_E[(2*v)] & length_adjusted_E[(2*v)+1]},    // MSB
                                        {length_adjusted_E[(2*v)] ^ length_adjusted_E[(2*v)+1]}     // LSB
                                    };
        end
    endgenerate
    
    // Second layer of popcount operation
    generate
        for(w=0; w < 8; w++) begin      // Max value: 3'b100 (4)
            assign popcnt_lvl2_E[w] = { {((popcnt_lvl1_E[(2*w)][0] & popcnt_lvl1_E[(2*w)+1][0]) & (popcnt_lvl1_E[(2*w)][1] ^ popcnt_lvl1_E[(2*w)+1][1])) | (popcnt_lvl1_E[(2*w)][1] & popcnt_lvl1_E[(2*w)+1][1])},
                                        {(popcnt_lvl1_E[(2*w)][1] ^ popcnt_lvl1_E[(2*w)+1][1]) ^ (popcnt_lvl1_E[(2*w)][0] & popcnt_lvl1_E[(2*w)+1][0])},
                                        {popcnt_lvl1_E[(2*w)][0] ^ popcnt_lvl1_E[(2*w)+1][0]}
                                    };
        end
    endgenerate
    
    /*
    Note:       The following layers of the popcount operation take place in the Writeback stage of the pipeline.
    */
    
    // Third layer of popcount operation
    generate
        for(x=0; x < 4; x++) begin      // Max value: 4'b1000 (8)
            assign popcnt_lvl3_W[x] = {{1'b0}, {popcnt_lvl2_W[(2*x)]}} + {{1'b0}, {popcnt_lvl2_W[(2*x)+1]}};
        end
    endgenerate
    
    // Fourth layer of popcount operation
    generate
        for(y=0; y < 2; y++) begin      // Max value: 5'b10000 (16)
            assign popcnt_lvl4_W[y] = {{1'b0}, {popcnt_lvl3_W[(2*y)]}} + {{1'b0}, {popcnt_lvl3_W[(2*y)+1]}};
        end
    endgenerate
    
    // Fifth and final layer of popcount operation
    assign popcnt_result = {{1'b0}, popcnt_lvl4_W[0]} + {{1'b0}, popcnt_lvl4_W[1]};     // Max value: 6'b100000 (32)
    
// -------------- CONVOLUTION RESULT -------------- //

    assign BNNResult = (popcnt_result << 1) - matrix_size;      // Convolution Result = (2*popcount) - matrix_size

endmodule



