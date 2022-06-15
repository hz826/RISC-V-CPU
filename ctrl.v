`include "ctrl_encode_def.v"

//123
module ctrl(Op, Funct7, Funct3, Zero, 
            RegWrite, MemWrite,
            EXTOp, ALUOp, NPCOp, 
            ALUSrc, GPRSel, WDSel,DMType
            );
            
   input  [6:0] Op;       // opcode
   input  [6:0] Funct7;    // funct7
   input  [2:0] Funct3;    // funct3
   input        Zero;
   
   output       RegWrite; // control signal for register write
   output       MemWrite; // control signal for memory write
   output [5:0] EXTOp;    // control signal to signed extension
   output [4:0] ALUOp;    // ALU opertion
   output [2:0] NPCOp;    // next pc operation
   output       ALUSrc;   // ALU source for A
   output [2:0] DMType;
   output [1:0] GPRSel;   // general purpose register selection
   output [1:0] WDSel;    // (register) write data selection
   
  // r format
    wire rtype = ~Op[6]&Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0110011
    wire i_add = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // add 0000000 000
    wire i_sub = rtype& ~Funct7[6]& Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]&~Funct3[0]; // sub 0100000 000
    wire i_or  = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& Funct3[1]&~Funct3[0]; // or 0000000 110
    wire i_and = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]& Funct3[1]& Funct3[0]; // and 0000000 111
    wire i_xor = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]&~Funct3[1]&~Funct3[0]; // xor 0000000 100
    wire i_sll = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]&~Funct3[1]& Funct3[0]; // sll 0000000 001
    wire i_sra = rtype& ~Funct7[6]& Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]&~Funct3[1]& Funct3[0]; // sra 0100000 101
    wire i_srl = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]& Funct3[2]&~Funct3[1]& Funct3[0]; // srl 0000000 101
    wire i_slt = rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]& Funct3[1]&~Funct3[0]; // slt 0000000 010
    wire i_sltu= rtype& ~Funct7[6]&~Funct7[5]&~Funct7[4]&~Funct7[3]&~Funct7[2]&~Funct7[1]&~Funct7[0]&~Funct3[2]& Funct3[1]& Funct3[0]; // sltu 0000000 011

  // i format
    wire itype_l = ~Op[6]&~Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0000011
    wire i_lb  = itype_l&~Funct3[2]&~Funct3[1]&~Funct3[0]; // lb 000
    wire i_lh  = itype_l&~Funct3[2]&~Funct3[1]& Funct3[0]; // lh 001
    wire i_lbu = itype_l& Funct3[2]&~Funct3[1]&~Funct3[0]; // lbu 100
    wire i_lhu = itype_l& Funct3[2]&~Funct3[1]& Funct3[0]; // lhu 101
    wire i_lw  = itype_l&~Funct3[2]& Funct3[1]&~Funct3[0]; // lw 010

  // i format
    wire itype_r = ~Op[6]&~Op[5]&Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0]; //0010011
    wire i_addi = itype_r&~Funct3[2]&~Funct3[1]&~Funct3[0]; // addi 000
    wire i_ori  = itype_r& Funct3[2]& Funct3[1]&~Funct3[0]; // ori 110
    wire i_xori = itype_r& Funct3[2]&~Funct3[1]&~Funct3[0]; // xori 100
    wire i_andi = itype_r& Funct3[2]& Funct3[1]& Funct3[0]; // andi 111
    wire i_srai = itype_r& Funct3[2]&~Funct3[1]& Funct3[0] & Funct7[5]; // srai 0100000 101
    wire i_srli = itype_r& Funct3[2]&~Funct3[1]& Funct3[0] &~Funct7[5]; // srli 0000000 101
    wire i_slti = itype_r&~Funct3[2]& Funct3[1]&~Funct3[0]; // slti 010
    wire i_sltiu= itype_r&~Funct3[2]& Funct3[1]& Funct3[0]; // sltiu 011
    wire i_slli = itype_r&~Funct3[2]&~Funct3[1]& Funct3[0]; // slli 001
	
  //jalr
  	wire i_jalr = Op[6]&Op[5]&~Op[4]&~Op[3]&Op[2]&Op[1]&Op[0];//jalr 1100111

  // s format
    wire stype = ~Op[6]&Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0];//0100011
    wire i_sw = stype&~Funct3[2]& Funct3[1]&~Funct3[0]; // sw 010
    wire i_sb = stype&~Funct3[2]&~Funct3[1]&~Funct3[0]; // sb 000
    wire i_sh = stype&~Funct3[2]&~Funct3[1]& Funct3[0]; // sh 001

  // sb format
    wire sbtype = Op[6]&Op[5]&~Op[4]&~Op[3]&~Op[2]&Op[1]&Op[0];//1100011
    wire i_beq  = sbtype&~Funct3[2]&~Funct3[1]&~Funct3[0]; // beq 000
    wire i_bne  = sbtype&~Funct3[2]&~Funct3[1]& Funct3[0]; // bne 001
    wire i_blt  = sbtype& Funct3[2]&~Funct3[1]&~Funct3[0]; // blt 100
    wire i_bge  = sbtype& Funct3[2]&~Funct3[1]& Funct3[0]; // bge 101
    wire i_bltu = sbtype& Funct3[2]& Funct3[1]&~Funct3[0]; // bltu 110
    wire i_bgeu = sbtype& Funct3[2]& Funct3[1]& Funct3[0]; // bgeu 111
	
 // j format
    wire i_jal  = Op[6]& Op[5]&~Op[4]& Op[3]& Op[2]& Op[1]& Op[0];  // jal 1101111
  
  // u format
    wire i_lui  =~Op[6]& Op[5]& Op[4]&~Op[3]& Op[2]& Op[1]& Op[0]; //lui 0110111
    wire i_auipc=~Op[6]&~Op[5]& Op[4]&~Op[3]& Op[2]& Op[1]& Op[0]; //auipc 0010111

  // generate control signals
    assign RegWrite   = rtype | itype_r | i_lui | i_auipc | i_jalr | i_jal | itype_l; // register write
    assign MemWrite   = stype;                                                        // memory write
    assign ALUSrc     = itype_r | stype | i_lui | i_auipc | i_jal | i_jalr |itype_l;  // ALU B is from instruction immediate

  // signed extension
  // EXT_CTRL_ITYPE_SHAMT 6'b100000
  // EXT_CTRL_ITYPE	      6'b010000
  // EXT_CTRL_STYPE	      6'b001000
  // EXT_CTRL_BTYPE	      6'b000100
  // EXT_CTRL_UTYPE	      6'b000010
  // EXT_CTRL_JTYPE	      6'b000001
    assign EXTOp[5] = i_slli | i_srli | i_srai;
    assign EXTOp[4] = i_jalr | i_lb   | i_lh  | i_lw  | i_lbu  | i_lhu | i_addi | i_slti | i_sltiu | i_xori | i_ori | i_andi;
    assign EXTOp[3] = i_sb   | i_sh   | i_sw;
    assign EXTOp[2] = i_beq  | i_bne  | i_blt | i_bge | i_bltu | i_bgeu;
    assign EXTOp[1] = i_lui  | i_auipc;
    assign EXTOp[0] = i_jal;
  
  // WDSel_FromALU 2'b00
  // WDSel_FromMEM 2'b01
  // WDSel_FromPC  2'b10 
    assign WDSel[0] = itype_l;
    assign WDSel[1] = i_jal | i_jalr;

  // NPC_PLUS4   3'b000
  // NPC_BRANCH  3'b001
  // NPC_JUMP    3'b010
  // NPC_JALR	3'b100
    assign NPCOp[0] = sbtype & Zero;
    assign NPCOp[1] = i_jal;
	  assign NPCOp[2] = i_jalr;

  // ALUOp_nop   5'b00000
  // ALUOp_lui   5'b00001
  // ALUOp_auipc 5'b00010
  // ALUOp_add   5'b00011
  // ALUOp_sub   5'b00100
  // ALUOp_bne   5'b00101
  // ALUOp_blt   5'b00110
  // ALUOp_bge   5'b00111
  // ALUOp_bltu  5'b01000
  // ALUOp_bgeu  5'b01001
  // ALUOp_slt   5'b01010
  // ALUOp_sltu  5'b01011
  // ALUOp_xor   5'b01100
  // ALUOp_or    5'b01101
  // ALUOp_and   5'b01110
  // ALUOp_sll   5'b01111
  // ALUOp_srl   5'b10000
  // ALUOp_sra   5'b10001

    assign ALUOp[0] = i_jalr|itype_l|stype|i_addi|i_ori|i_add|i_or|i_sll|i_sra|i_sltu
                     |i_srai|i_slli|i_sltiu|i_lui|i_bne|i_bge|i_bgeu;

	  assign ALUOp[1] = i_jalr|itype_l|stype|i_add|i_addi|i_and|i_andi|i_auipc|i_blt|i_bge
                     |i_slt|i_slti|i_sltu|i_sltiu|i_sll|i_slli;

	  assign ALUOp[2] = i_sll|i_slli | i_and|i_andi |i_or|i_ori |i_xor|i_xori
                     |i_bge|i_blt|i_bne|i_sub|i_beq;

  	assign ALUOp[3] = i_sll|i_slli |i_and|i_andi |i_or|i_ori |i_xor|i_xori
                     |i_sltu|i_sltiu | i_slt|i_slti | i_bltu|i_bgeu;

	  assign ALUOp[4] = i_srl|i_sra |i_srli|i_srai;


  // dm_word              3'b000     
  // dm_halfword          3'b001
  // dm_halfword_unsigned 3'b010
  // dm_byte              3'b011
  // dm_byte_unsigned     3'b100
    assign DMType[2] = i_lbu;
    assign DMType[1] = i_lb | i_sb | i_lhu;
    assign DMType[0] = i_lh | i_sh | i_lb | i_sb;
endmodule
