`timescale 1ns / 1ps

module mux4to1 #(
    parameter DATA_WIDTH = 32)
(

    input logic [DATA_WIDTH-1:0]        a, b, c, d,
    input logic [1:0]                   sel,
    output logic [DATA_WIDTH-1:0]       y

);

    always_comb begin : comb_proc
        case(sel)
            2'b00:          y <= a;
            2'b01:          y <= b;
            2'b10:          y <= c;
            2'b11:          y <= d;
            default:        y <= 'x;
        endcase
    end

endmodule