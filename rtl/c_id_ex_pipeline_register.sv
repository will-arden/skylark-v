`timescale 1ns / 1ps

module c_id_ex_pipeline_register(

    input logic             clk, reset,
                            StallE,
                            FlushE,
                            RegWE_E_D, RegWE_W_D,
                            OpBSrcD,
                            MemWriteD,
                            ms_WE_D,
                            branch_D, jump_D,
    input logic [1:0]       ExPathD,
    input logic [2:0]       ALUFuncD,
                            funct3_D,

    output logic            RegWE_E_E, RegWE_W_E,
                            OpBSrcE,
                            MemWriteE,
                            ms_WE_E,
                            branch_E, jump_E,
    output logic [1:0]      ExPathE,
    output logic [2:0]      ALUFuncE,
                            funct3_E
);
    
    always_ff @(posedge clk, posedge reset) begin : seq_proc
        if(reset) begin
            RegWE_E_E           <= 1'b0;
            RegWE_W_E           <= 1'b0;
            OpBSrcE             <= 1'b1;          // Set for NOP
            MemWriteE           <= 1'b0;
            ms_WE_E             <= 1'b0;
            branch_E            <= 1'b0;
            jump_E              <= 1'b0;
            ExPathE             <= 2'b00;
            ALUFuncE            <= 3'b00;         // Set for NOP
            funct3_E            <= 3'b00;
        end
        else if(clk) begin
            if(FlushE) begin
                RegWE_E_E           <= 1'b0;
                RegWE_W_E           <= 1'b0;
                OpBSrcE             <= 1'b1;          // Set for NOP
                MemWriteE           <= 1'b0;
                ms_WE_E             <= 1'b0;
                branch_E            <= 1'b0;
                jump_E              <= 1'b0;
                ExPathE             <= 2'b00;
                ALUFuncE            <= 3'b00;         // Set for NOP
                funct3_E            <= 3'b00;
            end
            else if(!StallE) begin
                RegWE_E_E           <= RegWE_E_D;
                RegWE_W_E           <= RegWE_W_D;
                OpBSrcE             <= OpBSrcD;
                MemWriteE           <= MemWriteD;
                ms_WE_E             <= ms_WE_D;
                branch_E            <= branch_D;
                jump_E              <= jump_D;
                ExPathE             <= ExPathD;
                ALUFuncE            <= ALUFuncD;
                funct3_E            <= funct3_D;
            end
        end
    end

endmodule
