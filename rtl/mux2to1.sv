`timescale 1ns / 1ps

module mux2to1 #(
    parameter DATA_WIDTH = 32)
(

    input logic [DATA_WIDTH-1:0]        a, b,
    input logic                         sel,
    output logic [DATA_WIDTH-1:0]       y

);

    always_comb begin
        case(sel)
            1'b0:           y = a;
            1'b1:           y = b;
            default:        y = 'x;
        endcase
    end

endmodule