`timescale 1ns / 1ps

module display_encoder(

    input logic             clk, reset,
                            dp,
    input logic [3:0]       num,
    output logic [6:0]      cathodes,
    output logic            anode

);

    logic [3:0] wth;
    assign wth = 4'h3;

    always_comb begin
        anode <= 1'b0;
        case (wth)
            4'h0:       cathodes[6:0]   <= 7'b1000000;
            4'h1:       cathodes[6:0]   <= 7'b1111001;
            4'h2:       cathodes[6:0]   <= 7'b0100100;
            4'h3:       cathodes[6:0]   <= 7'b0000110;
            4'h4:       cathodes[6:0]   <= 7'b0011001;
            4'h5:       cathodes[6:0]   <= 7'b0000010;
            4'h6:       cathodes[6:0]   <= 7'b1111111;
            4'h7:       cathodes[6:0]   <= 7'b1111000;
            4'h8:       cathodes[6:0]   <= 7'b0000000;
            4'h9:       cathodes[6:0]   <= 7'b0010000;
            4'hA:       cathodes[6:0]   <= 7'b0001000;
            4'hB:       cathodes[6:0]   <= 7'b0000011;
            4'hC:       cathodes[6:0]   <= 7'b1000110;
            4'hD:       cathodes[6:0]   <= 7'b0100001;
            4'hE:       cathodes[6:0]   <= 7'b0000110;
            4'hF:       cathodes[6:0]   <= 7'b0001110;
            default:    cathodes[6:0]   <= 7'b1111111;
        endcase
    end

    /*always_ff @(posedge clk, posedge reset) begin
        if(reset) begin
            cathodes    <= 8'h00;
            anode       <= 1'b1;            // Turn off on reset
        end
        else begin
            anode           <= 1'b0;
            cathodes[7]     <= dp;
            case (num)
                4'h0:       cathodes[6:0]   <= 7'b1000000;
                4'h1:       cathodes[6:0]   <= 7'b1111001;
                4'h2:       cathodes[6:0]   <= 7'b0100100;
                4'h3:       cathodes[6:0]   <= 7'b0000110;
                4'h4:       cathodes[6:0]   <= 7'b0011001;
                4'h5:       cathodes[6:0]   <= 7'b0000010;
                4'h6:       cathodes[6:0]   <= 7'b1111111;
                4'h7:       cathodes[6:0]   <= 7'b1111000;
                4'h8:       cathodes[6:0]   <= 7'b0000000;
                4'h9:       cathodes[6:0]   <= 7'b0010000;
                4'hA:       cathodes[6:0]   <= 7'b0001000;
                4'hB:       cathodes[6:0]   <= 7'b0000011;
                4'hC:       cathodes[6:0]   <= 7'b1000110;
                4'hD:       cathodes[6:0]   <= 7'b0100001;
                4'hE:       cathodes[6:0]   <= 7'b0000110;
                4'hF:       cathodes[6:0]   <= 7'b0001110;
                default:    cathodes[6:0]   <= 7'b1111111;
            endcase
        
        end
    end*/

endmodule
