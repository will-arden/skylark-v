`timescale 1ns/1ps

module tb_register_file;

    logic           clk, reset,
                    RegWE_E, RegWE_W;
    logic [4:0]     A1, A2, A3, A4;
    logic [31:0]    WD3, WD4,
                    RD1, RD2;

    GPR dut(
        clk,
        reset,
        RegWE_E,
        RegWE_W,
        A1, A2, A3, A4,
        WD3, WD4,
        RD1, RD2
    );
    
    initial begin
    
        clk = 1'b0;         // Set clk to zero
        RegWE_E = 1'b0; RegWE_W = 1'b0;
        A1 = 5'b0; A2 = 5'b0; A3 = 5'b0; A4 = 5'b0;
        WD3 = 32'hAAAAAAAA; WD4 = 32'hBBBBBBBB;
    
        // Toggle reset
        #5; reset = 1'b0; #10; reset = 1'b1; #10; reset = 1'b0;
        
        #10;
        
        // Execute writes to register 1
        RegWE_E = 1'b1;
        A3 = 5'b00001;
        
        #10;
        
        // Read from register 0 and register 1
        RegWE_E = 1'b0;
        A1 = 5'b00000;
        A2 = 5'b00001;
        
        #10;
        
        // Execute overwrites to register 1 value
        RegWE_E = 1'b1;
        A3 = 5'b00001;
        WD3 = 32'hA00AA00A;
        
        #10;
        
        // Writeback writes to register 1, and Execute stops writing
        RegWE_E = 1'b0;
        A4 = 5'b00001;
        RegWE_W = 1'b1;
        
        #10;
        
        // Now both try to write to register 2
        A3 = 5'b00010; A4 = 5'b00010;
        RegWE_E = 1'b1; RegWE_W = 1'b1;
        
        #10;
        
        // Both stop writing and the result is read from register 2 (should be Execute value)
        RegWE_E = 1'b0; RegWE_W = 1'b0;
        A1 = 5'b00010;
        
        #10;
    
    end
    
    always begin
        clk <= !clk;
        #1;
    end

endmodule
