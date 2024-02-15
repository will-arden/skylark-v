module hcu(
    
    input logic         RegWE_E_W,                  // Indicates RAW hazard
                        RegWE_W_E,                  // Load operation indicators        (Execute)
                        RegWE_W_W,                  //                                  (Writeback)
                        condition_met_E,            // Branch condition met             (Execute)
                        branch_D, jump_D,           // Branch and Jump flags            (Decode)
                        branch_E,                   //                                  (Execute)
                        branched_flag_F,            // After a branch, this gets set
    input logic [4:0]   A1_E, A2_E,
                        A3_W,                       // Writeback destination register
    
    output logic        StallF,                     // Stall and Flush signals
                        StallD, FlushD,
                        StallE, FlushE,
                        StallW, FlushW,
                        fwdA_E, fwdB_E              // Forwarding control signals
    
);
    
    // Unused output signals
    assign StallW = 1'b0;

    always_comb begin
        
        // Misprediction Control Hazard
        if(branch_E && !condition_met_E) begin          // Misprediction detected
            StallF <= 1'b1;
            FlushD <= 1'b1;
            FlushE <= 1'b1;
            FlushW <= 1'b1;
        end
        else begin
            FlushD <= 1'b0;
            FlushE <= 1'b0;
            FlushW <= 1'b0;
        end
    
        // RAW Hazard Mitigation (Forwarding)
        if(RegWE_E_W) begin                             // If an Execute result was just stored (RAW)
            if(A1_E == A3_W)        fwdA_E <= 1'b1;         // Check if OpA requires the result
            else                    fwdA_E <= 1'b0;
            if(A2_E == A3_W)        fwdB_E <= 1'b1;         // Check if OpB requires the result
            else                    fwdB_E <= 1'b0;
        end
        else begin                                      // Otherwise, forwarding is not required
            fwdA_E <= 1'b0;
            fwdB_E <= 1'b0;
        end
        
        // Load (Double) Stall
        if(RegWE_W_E || RegWE_W_W) begin
            StallF <= 1'b1;
            StallD <= 1'b1;
            StallE <= 1'b1;
            FlushE <= 1'b1;
        end
        else if((branch_D || jump_D) && !branched_flag_F) begin
            StallD <= 1'b1;
        end
        else begin
            StallF <= 1'b0;
            StallD <= 1'b0;
            StallE <= 1'b0;
            FlushE <= 1'b0;
        end

    end

endmodule
