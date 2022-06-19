`include "ctrl.v"
`include "PC.v"
`include "NPC.v"
`include "EXT.v"
`include "RF.v"
`include "ALU.v"

module IF(

);

endmodule

module ID(
    input  [31:0] PC_in,
    input  [31:0] inst_in,     // instruction
    input  [31:0] RD1_in,      // read register value
    input  [31:0] RD2_in,      // read register value

    // to RF (ID -> RF -> ID)
    output [4:0]  rs1,         // read register id
    output [4:0]  rs2,         // read register id
    
    // to EX
    output [31:0] RD1_out,     // read register value
    output [31:0] RD2_out,     // read register value
    output [4:0]  ALUOp,       // ALU opertion
    output [31:0] ALU_B,       // operator for ALU B

    // to MEM
    output [31:0] PC_out,
    output [31:0] immout,      // used in NPC
    output [2:0]  NPCOp1,      // next PC operation

    output        MemWrite,    // output: memory write signal
    output [2:0]  DMType,      // read/write data length
    output [31:0] Data_out,    // data to data memory

    // to WB
    output        RegWrite,    // control signal to register write
    output [4:0]  rd,          // write register id
    output [1:0]  WDSel        // (register) write data selection
);

    wire [4:0]  iimm_shamt;
	wire [11:0] iimm,simm,bimm;
	wire [19:0] uimm,jimm;

    wire [6:0]  Op;          // opcode
    wire [6:0]  Funct7;      // funct7
    wire [2:0]  Funct3;      // funct3
    // wire [11:0] Imm12;       // 12-bit immediate
    // wire [31:0] Imm32;       // 32-bit immediate
    // wire [19:0] IMM;         // 20-bit immediate (address)

    wire [5:0]  EXTOp;       // control signal to signed extension
    wire        ALUSrc;      // ALU source for B

    wire [1:0]  GPRSel;      // general purpose register selection (unused)

    /************************ processing instruction ************************/
	assign iimm_shamt=inst_in[24:20];
	assign iimm=inst_in[31:20];
	assign simm={inst_in[31:25],inst_in[11:7]};
	assign bimm={inst_in[31],inst_in[7],inst_in[30:25],inst_in[11:8]};
	assign uimm=inst_in[31:12];
	assign jimm={inst_in[31],inst_in[19:12],inst_in[20],inst_in[30:21]};
   
    assign Op = inst_in[6:0];       // instruction
    assign Funct7 = inst_in[31:25]; // funct7
    assign Funct3 = inst_in[14:12]; // funct3
    assign rs1 = inst_in[19:15];    // rs1
    assign rs2 = inst_in[24:20];    // rs2
    assign rd = inst_in[11:7];      // rd
    // assign Imm12 = inst_in[31:20];  // 12-bit immediate
    // assign IMM = inst_in[31:12];    // 20-bit immediate

    // instantiation of control unit
    ctrl U_ctrl(
        // input
		.Op(Op), .Funct7(Funct7), .Funct3(Funct3),
        // output
		.RegWrite(RegWrite), .MemWrite(MemWrite),
		.EXTOp(EXTOp), .ALUOp(ALUOp), .NPCOp(NPCOp1), 
		.ALUSrc(ALUSrc), .GPRSel(GPRSel), .WDSel(WDSel), .DMType(DMType)
	);

    EXT U_EXT(
		.iimm_shamt(iimm_shamt), .iimm(iimm), .simm(simm), .bimm(bimm),
		.uimm(uimm), .jimm(jimm),
		.EXTOp(EXTOp), .immout(immout)
	);

    /*********************** after reading registers ************************/

    assign ALU_B = (ALUSrc) ? immout : RD2_in;
    assign Data_out = RD2_in;
    assign RD1_out = RD1_in;
    assign RD2_out = RD2_in;
endmodule

module EX(
    
);

endmodule

module MEM(
    
);

endmodule

module WB(
    
);

endmodule

module SCPU(
    input      clk,           // clock
    input      reset,         // reset
    input  [4:0]  reg_sel,    // register selection     (for debug use)
    output [31:0] reg_data,   // selected register data (for debug use)

    // IM
    output [31:0] PC_out,      // PC address
   
    // DM
    output [31:0] Addr_out,   // ALU output
    
    input  [31:0] Data_in     // data from data memory
);

    wire [2:0]  NPCOp2;      // next PC operation NPCOp2[0] = NPCOp1[0] & Zero;
    wire        Zero;        // ALU ouput zero

    wire [31:0] NPC;         // next PC
    
    // wire [4:0]  A3;          // register address for write (unused)
    wire [31:0] WD;          // register write data

    wire [31:0] aluout;

    // instantiation of pc unit
	PC U_PC(.clk(clk), .rst(reset), .NPC(NPC), .PC(PC_out));
	NPC U_NPC(.PC(PC_out), .NPCOp(NPCOp2), .IMM(immout), .NPC(NPC), .aluout(aluout));
	
	RF U_RF(
		.clk(clk), .rst(reset),
		.RFWr(RegWrite), 
		.A1(rs1), .A2(rs2), .A3(rd), 
		.WD(WD), 
		.RD1(RD1), .RD2(RD2)
		//.reg_sel(reg_sel),
		//.reg_data(reg_data)
	);

    // instantiation of alu unit
	alu U_alu(.A(RD1), .B(ALU_B), .ALUOp(ALUOp), .C(aluout), .Zero(Zero), .PC(PC_out));

    assign Addr_out=aluout;

    assign NPCOp2[0] = NPCOp1[0] & Zero;
    assign NPCOp2[1] = NPCOp1[1];
	assign NPCOp2[2] = NPCOp1[2];

    assign WD = (WDSel == `WDSel_FromALU) ? aluout : ((WDSel == `WDSel_FromMEM) ? Data_in : PC_out+4);
endmodule