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
    assign data[5'b00000] = 32'h00000000;               // Hard-wire register x0 to #0
    
    // -------------- READ -------------- //
    
    assign RD1 = data[A1];
    assign RD2 = data[A2];

    // -------------- WRITE -------------- //
    
    always_ff @(posedge clk) begin
    
        // If the addresses are different - there is no contention.
        // If the addresses are the same but one of the WE flags is 0 - there is no contention.
    
        if( (A3 == A4) && RegWE_E && RegWE_W )              // If there is contention:
            data[A3] = WD3;                                     // Prefer Execute value (newest)
            
        else begin                                          // If there is no contention:
            if(A3 != 5'b00000 && RegWE_E) data[A3] = WD3;       // Write from Execute (or)
            if(A4 != 5'b00000 && RegWE_W) data[A4] = WD4;       // Write from Writeback
        end
    end
    
    // -------------- RESET -------------- //
    
    always_ff @(posedge reset) begin                    // All registers are reset to 0x0 when the program is reset
        data[1]         = 32'h00000000;
        data[2]         = 32'h00000000;
        data[3]         = 32'h00000000;
        data[4]         = 32'h00000000;
        data[5]         = 32'h00000000;
        data[6]         = 32'h00000000;
        data[7]         = 32'h00000000;
        data[8]         = 32'h00000000;
        data[9]         = 32'h00000000;
        data[10]        = 32'h00000000;
        data[11]        = 32'h00000000;
        data[12]        = 32'h00000000;
        data[13]        = 32'h00000000;
        data[14]        = 32'h00000000;
        data[15]        = 32'h00000000;
        data[16]        = 32'h00000000;
        data[17]        = 32'h00000000;
        data[18]        = 32'h00000000;
        data[19]        = 32'h00000000;
        data[20]        = 32'h00000000;
        data[21]        = 32'h00000000;
        data[22]        = 32'h00000000;
        data[23]        = 32'h00000000;
        data[24]        = 32'h00000000;
        data[25]        = 32'h00000000;
        data[26]        = 32'h00000000;
        data[27]        = 32'h00000000;
        data[28]        = 32'h00000000;
        data[29]        = 32'h00000000;
        data[30]        = 32'h00000000;
        data[31]        = 32'h00000000;
    end
    
endmodule