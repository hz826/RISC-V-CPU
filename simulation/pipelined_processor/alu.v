`include "ctrl_encode_def.v"

module alu(A, B, ALUOp, C, Zero,PC);
   input  signed [31:0] A, B;  // 计算输入值
   input         [4:0]  ALUOp; // 运算模式
   input         [31:0] PC;    // 计算输入值
   output signed [31:0] C;     // 计算结果
   output               Zero;  // 计算结果是否为 0
   
   reg [31:0] C;
   
   always @( * ) begin
      case ( ALUOp )
         `ALUOp_nop  :C=A;
         `ALUOp_lui  :C=B;
         `ALUOp_auipc:C=PC+B;
         
         // 算术运算
         `ALUOp_add:C=A+B;
         `ALUOp_sub:C=A-B;

         // 逻辑运算
         `ALUOp_xor:C=A^B;
         `ALUOp_or :C=A|B;
         `ALUOp_and:C=A&B;
         `ALUOp_sll:C=A<<B;
         `ALUOp_srl:C=A>>B;
         `ALUOp_sra:C=A>>>B;

         // 比较运算（若逻辑表达式为真，则C=0，否则C=1）
         `ALUOp_bne :C={31'b0,(A==B)};
         `ALUOp_blt :C={31'b0,(A>=B)};
         `ALUOp_bge :C={31'b0,(A<B)};
         `ALUOp_bltu:C={31'b0,($unsigned(A)>=$unsigned(B))};
         `ALUOp_bgeu:C={31'b0,($unsigned(A)<$unsigned(B))};
         `ALUOp_slt :C={31'b0,(A<B)};
         `ALUOp_sltu:C={31'b0,($unsigned(A)<$unsigned(B))};
      endcase
   end
   
   assign Zero = (C == 32'b0);

endmodule
    
