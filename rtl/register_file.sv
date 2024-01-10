/*
Dual-Write, General-Purpose Register File
---------------------
This register file is inspired by the RI5CY design, and allows for dual-access from both the Execute stage and the
Writeback stage. There is nothing to be done on the negative clock edge.
*/


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

    // -------------- WRITE -------------- //
    
    always_ff @(posedge clk) begin
    
        // If the addresses are different - there is no contention.
        // If the addresses are the same but one of the WE flags is 0 - there is no contention.
    
        if( (A3 == A4) && RegWE_E && RegWE_W )          // If there is contention:
            data[A3] <= WD3;                                // Prefer Execute value (newest)
            
        else begin                                      // If there is no contention:
            if(RegWE_E) data[A3] <= WD3;                    // Write from Execute (or)
            if(RegWE_W) data[A4] <= WD4;                    // Write from Writeback
        end
    end
    
    // -------------- READ & RESET -------------- //
    always_ff @(posedge reset) begin
        assign RD1 = (A1 != 5'b00000 && !reset) ? data[A1] : 32'h00000000;
        assign RD2 = (A2 != 5'b00000 && !reset) ? data[A2] : 32'h00000000;
    end
    
endmodule