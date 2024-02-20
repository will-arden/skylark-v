module hcu(
    
    input logic         RegWE_E_W,                  // Indicates RAW hazard
                        RegWE_W_E,                  // Load operation indicators        (Execute)
                        RegWE_W_W,                  //                                  (Writeback)
                        RegWE_W_W2,                 //                                  (Writeback 2)
                        condition_met_E,            // Branch condition met             (Execute)
                        branch_D, jump_D,           // Branch and Jump flags            (Decode)
                        branch_E,                   //                                  (Execute)
    input logic [4:0]   A1_E, A2_E,
                        A3_W,                       // Writeback destination register
    
    output logic        StallF,                     // Stall and Flush signals
                        StallD, FlushD,
                        StallE, FlushE,
                        StallW, FlushW,
    output logic [1:0]  fwdA_E, fwdB_E              // Forwarding control signals
    
);
    
    // Unused output signals
    assign StallW = 1'b0;
    assign FlushW = 1'b0;

    always_comb begin
        
// -------------- FORWARDING -------------- //
    
        // RAW Hazard Mitigation (Forwarding)
        if(RegWE_E_W) begin                             // If an Execute result was just stored (RAW)
            if(A1_E == A3_W)        fwdA_E <= 2'b01;        // Check if OpA requires the result
            else                    fwdA_E <= 2'b00;
            if(A2_E == A3_W)        fwdB_E <= 2'b01;        // Check if OpB requires the result
            else                    fwdB_E <= 2'b00;
        end
        
        // Load stall buffer (forwarding)
        else if(RegWE_W_W2) begin                       // If the Writeback 2 contains a load operation
            if(A1_E == A3_W)        fwdA_E <= 2'b10;        // Check if OpA requires the result
            else                    fwdA_E <= 2'b00;
            if(A2_E == A3_W)        fwdB_E <= 2'b10;        // Check if OpB requires the result
            else                    fwdB_E <= 2'b00;
        end
        
        // Default forwarding
        else begin                                      // Otherwise, forwarding is not required
            fwdA_E <= 2'b00;
            fwdB_E <= 2'b00;
        end
        
// -------------- STALLING & FLUSHING -------------- //
        
        // Load Stall (stalling and flushing)
        if(RegWE_W_E) begin                             // If load operation is in Execute stage,
            StallF <= 1'b1;                                 // Stall all prior stages
            StallD <= 1'b1;
            StallE <= 1'b1;
            FlushE <= 1'b1;                                 // Create a bubble in the Execute stage
        end
        
        // Misprediction Control Hazard
        else if(branch_E && !condition_met_E) begin          // Misprediction detected
            FlushD <= 1'b1;
            FlushE <= 1'b1;
        end
        
        // Branch behaviour
        else if(branch_D || jump_D) begin
            FlushD  <= 1'b1;
        end
        else begin
            StallF  <= 1'b0;
            StallD  <= 1'b0;    FlushD  <= 1'b0;
            StallE  <= 1'b0;    FlushE  <= 1'b0;
        end

    end

endmodule
