`timescale 1ns / 1ps

`define IMEM_SIZE 32
`define DMEM_SIZE 64

localparam SEG_MEM_MAP = int'(32'h00000000);

module soc(

    input logic             CLK100MHZ, btnC,
    output logic [3:0]      an,
    output logic [6:0]      seg,
    output logic [15:0]     LED

);

    // Declare signals
    logic               clk, low_speed_clk, reset, MemWriteW;
    logic [31:0]        InstrF, ReadData, ALUResultW, WriteData, PCF;
    logic               decimal_point;
    logic [3:0]         bcd0, bcd1, bcd2, bcd3;
    logic [6:0]         cathodes;
    
// -------------- CLOCKING WIZARD (VIVADO IP) -------------- //

    // Declare signals
    logic       clk_wzd_100,
                clk_wzd_90,
                clk_wzd_80,
                clk_wzd_70,
                clk_wzd_60,
                clk_wzd_50,
                clk_wzd_110,
                reset, locked;
                
    // Map physical signals
    assign clk          = clk_wzd_110;
    assign reset        = btnC;
    assign seg          = cathodes;

    // Instantiate IP
    clk_wiz_0 clk_wiz(
        clk_wzd_100,
        clk_wzd_90,
        clk_wzd_80,
        clk_wzd_70,
        clk_wzd_60,
        clk_wzd_50,
        clk_wzd_110,
        reset, locked,
        CLK100MHZ
    );
   
/* 
// -------------- CLOCK DIVIDER -------------- //

    clk_div #(6250000) clk_div(
        CLK100MHZ, reset,
        low_speed_clk
    ); */
    

    
// -------------- DATA MEMORY -------------- //
    
    integer i;
    
    logic [31:0] data[`DMEM_SIZE-1:0];            // Create memory space
    
    // Writing to external memory
    always_ff @(posedge clk, posedge reset) begin
    
        // Zero all RAM on reset
        if(reset) begin
            for(i=0; i<`DMEM_SIZE; i=i+1)       data[i] <= 32'h00000000;
        end
        
        else if(MemWriteW)      data[ALUResultW] <= WriteData;
    end
    
    // Reading from external memory
    assign ReadData = data[ALUResultW];
    
// -------------- 7-SEGMENT DISPLAY -------------- //
    
    assign decimal_point = 1'b0;
    assign bcd0 = 4'h1;
    assign bcd1 = 4'h2;
    assign bcd2 = 4'h2;
    assign bcd3 = 4'h2;
    
    logic [19:0] refresh_count;
    logic [3:0] BCD;
    logic [31:0] PC;
    assign PC = PCF;
    
    //Display PC on 4 7-segments       
    always_ff @(posedge CLK100MHZ, posedge reset)
        if (reset)
            refresh_count <= 0;
        else
            refresh_count <= refresh_count + 1;
            
            
    always_comb begin
        if(reset)       begin
                            an  = 4'b0000;
                            BCD = 4'h0;
                        end
        else begin
            unique case (refresh_count[19:18])
                2'b00:      begin
                                an  = 4'b0111;                                              // Illuminate only LHS digit
                                BCD = data[SEG_MEM_MAP + refresh_count[19:18]][3:0];        // Memory map
                            end
                2'b01:      begin
                                an  = 4'b1011;                                              // Illuminate only second from LHS digit
                                BCD = data[SEG_MEM_MAP + refresh_count[19:18]][3:0];        // Memory map
                            end
                2'b10:      begin
                                an  = 4'b1101;                                              // Illuminate only second from RHS digit
                                BCD = data[SEG_MEM_MAP + refresh_count[19:18]][3:0];        // Memory map
                            end
                2'b11:      begin
                                an  = 4'b1110;                                              // Illuminate only RHS digit
                                BCD = data[SEG_MEM_MAP + refresh_count[19:18]][3:0];        // Memory map
                            end
            endcase
        end
    end
    
    always_comb
        if(reset)       seg = 7'b0111111;
        else begin
            case (BCD)			//GFEDCBA
                4'h0:    seg = 7'b1000000; // 0
                4'h1:    seg = 7'b1111001; // 1
                4'h2:    seg = 7'b0100100; // 2
                4'h3:    seg = 7'b0110000; // 3
                4'h4:    seg = 7'b0011001; // 4
                4'h5:    seg = 7'b0010010; // 5
                4'h6:    seg = 7'b0000010; // 6
                4'h7:    seg = 7'b1111000; // 7
                4'h8:    seg = 7'b0000000; // 8
                4'h9:    seg = 7'b0010000; // 9
                4'hA:    seg = 7'b0001000; // A
                4'hB:    seg = 7'b0000011; // B
                4'hC:    seg = 7'b0100111; // C
                4'hD:    seg = 7'b0100001; // D
                4'hE:    seg = 7'b0000110; // E
                4'hF:    seg = 7'b0001110; // F
                default: seg = 7'b0111111; // -
           endcase
       end

    
    always_comb begin
        
        if(InstrF == 32'h00000fef) begin        // Indicates that program is finished
            LED <= 16'hFFFF;
        end
        else begin
            LED <= 16'h0000;
        end
        
    end
    
// -------------- SKYLARK-V CORE -------------- //

    skylark_core skylark_core(
        clk, reset,                 // Essential inputs
        InstrF,                     // Input from instruction memory
        ReadData,                   // Input from data memory
        MemWriteW,                  // Output to data memory, to enable writing
        ALUResultW,                 // Output to data memory, to provide the write address
        WriteData,                  // Output to data memory, to provide the write data
        PCF                         // Output to instruction memory, to receive the data at this address
    );
    

    
// -------------- INSTRUCTION MEMORY -------------- //

    logic[31:0] memory[`DMEM_SIZE-1:0];             // Create the structure to hold the memory (RAM)

    initial begin
    
        for(i=0; i<`IMEM_SIZE; i++) begin
            memory[i]   <= 32'h00000013;
        end
        
        // Manually assign each line of instruction memory
        memory[0]       <= 32'h00f00093;
        memory[1]       <= 32'h00110113;
        memory[2]       <= 32'h00202023;
        memory[3]       <= 32'hfe209ce3;
        memory[4]       <= 32'h00000113;
        memory[5]       <= 32'h00110113;
        memory[6]       <= 32'h002020a3;
        memory[7]       <= 32'hfe209ce3;
        memory[8]       <= 32'h00000113;
        memory[9]       <= 32'h00110113;
        memory[10]      <= 32'h00202123;
        memory[11]      <= 32'hfe209ce3;
        memory[12]      <= 32'h00000113;
        memory[13]      <= 32'h00110113;
        memory[14]      <= 32'h002021a3;
        memory[15]      <= 32'hfe209ce3;
        memory[16]      <= 32'h00000113;
        memory[17]      <= 32'h0000006f;

    end
    
    assign InstrF = memory[PCF[31:2]];              // Ignore two LSB's since instructions are word-aligned

endmodule
