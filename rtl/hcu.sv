module hcu(
    
    input logic         clk, reset,
    input logic [4:0]   A1_E, A2_E,
                        A3_W, A4_W,                 // Writeback destination registers
    input logic         RegWE_E_W,                  // Indicates RAW hazard
                        RegWE_W_E,                  // Load operation indicators        (Execute)
                        RegWE_W_W,                  //                                  (Writeback)
                        condition_met_E,            // Branch condition met             (Execute)
                        branch_D, jump_D,           // Branch and Jump flags            (Decode)
                        branch_E, jump_E,           //                                  (Execute)
                        branched_flag_F,            // After a branch, this gets set
    
    output logic        StallF,
                        StallD, FlushD,
                        StallE, FlushE,
                        StallW, FlushW,
                        fwdA_E, fwdB_E
    
);


/*
Right, if RegWE_W_E is 1, that means that there's a LOAD operation in the Execute stage.
This means the Fetch and Decode stages need to be stalled for 2 cycles, to let the load operation write to the register file.
Two bubbles should be formed in the Execute stage using the FlushE signal.
*/
    
    // Uncoded signals
    //assign StallD = 1'b0;
    //assign StallE = 1'b0;
    //assign StallF = 1'b0;
    assign StallW = 1'b0;
    
    //assign FlushD = 1'b0;
    //assign FlushE = 1'b0;
    //assign FlushW = 1'b0;

    always_comb begin
    
        
        // Misprediction Control Hazard
        if(branch_E && !condition_met_E) begin          // Misprediction detected
            StallF <= 1'b1;
            FlushD <= 1'b1;
            FlushE <= 1'b1;
            FlushW <= 1'b1;
            // I could pipeline the PCNext one extra step to become PCNextW and use that as the PC in case there is a mistake.
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
