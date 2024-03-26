`timescale 1ns / 1ps

module register_file(

    input logic             clk, reset,
                            RegWE_E,                    // Write Enable             (Execute)
                            RegWE_W,                    //                          (Writeback)
    input logic [4:0]       A1, A2, A3, A4,             // Register Address         (Decode)
    input logic [31:0]      WD3,                        // Write Data               (Execute)
                            WD4,                        //                          (Writeback)
    
    output logic [31:0]     RD1, RD2                    // Read Data

);

    logic [31:0] data[31:0];                            // 31 useable registers
    assign data[0] = 32'h00000000;               // Hard-wire register x0 to #0
    
// -------------- READ -------------- //
    
    assign RD1 = data[A1];
    assign RD2 = data[A2];

// -------------- WRITE -------------- //
    
    integer i;
    always_ff @(posedge clk, posedge reset) begin : seq_proc
    
        if(reset) begin
            for(i=1; i<32; i++)   data[i] <= 32'h00000000;                  // Zero all registers on reset
        end
        
        else if(clk) begin                                                  // Otherwise, write as normal
    
            // If the addresses are different - there is no contention.
            // If the addresses are the same but one of the WE flags is 0 - there is no contention.
        
            if( (A3 == A4) && RegWE_E && RegWE_W && !reset )                // If there is contention:
                data[A3] <= WD3;                                                // Prefer Execute value (newest)
                
            else begin                                                      // If there is no contention:
                if(A3 != 5'b00000 && RegWE_E && !reset) data[A3] <= WD3;        // Write from Execute (or)
                if(A4 != 5'b00000 && RegWE_W && !reset) data[A4] <= WD4;        // Write from Writeback
            end
        end
    end

endmodule