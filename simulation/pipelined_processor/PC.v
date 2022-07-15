`include "ctrl_encode_def.v"

module NPC(                  // next pc module
    input  [31:0] PC,        // pc
    input  [2:0]  NPCOp,     // next pc operation
    input  [31:0] IMM,       // immediate
    input  [31:0] aluout,
    output reg [31:0] NPC    // next pc
);
    always @(*) begin
        case (NPCOp)
            `NPC_BRANCH: NPC = PC+IMM;
            `NPC_JUMP:   NPC = PC+IMM;
            `NPC_JALR:   NPC = aluout;
        endcase
    end
endmodule

module PC(
    input              clk,
    input              rst,
    input              stall,
    input       [2:0]  NPCOP,
    input       [31:0] NPC,
    output reg  [31:0] PC
);

    wire [31:0] PCPLUS4;
    assign PCPLUS4 = PC + 4; // pc + 4

    always @(posedge clk, posedge rst)
        if (rst)
            PC <= 32'h0000_0000;  //      PC <= 32'h0000_3000;
        else begin
            if (stall == 1) PC <= PC;
            else if (NPCOP != 3'b000) PC <= NPC;
            else PC <= PCPLUS4;
        end
endmodule