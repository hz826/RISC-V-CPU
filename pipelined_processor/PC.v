`include "ctrl_encode_def.v"

module NPC(                  // next pc module
    input  [31:0] PC;        // pc
    input  [2:0]  NPCOp;     // next pc operation
    input  [31:0] IMM;       // immediate
    input  [31:0] aluout;
    output reg [31:0] NPC;   // next pc
);

    wire [31:0] PCPLUS4;
    
    assign PCPLUS4 = PC + 4; // pc + 4
    
    always @(*) begin
        case (NPCOp)
            `NPC_PLUS4:  NPC = PCPLUS4;
            `NPC_BRANCH: NPC = PC+IMM;
            `NPC_JUMP:   NPC = PC+IMM;
            `NPC_JALR:   NPC = aluout;
            default:     NPC = PCPLUS4;
        endcase
    end // end always
endmodule

module PC(
    input              clk,
    input              rst,
    input              PC_stall,
    input       [31:0] NPC,
    output reg  [31:0] PC
);

    always @(posedge clk, posedge rst)
        if (rst) 
            PC <= 32'h0000_0000;  //      PC <= 32'h0000_3000;
        else
            if (PC_stall)
                PC <= NPC;
endmodule