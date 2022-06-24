`include "ctrl.v"
`include "PC.v"
`include "NPC.v"
`include "EXT.v"
`include "RF.v"
`include "ALU.v"
`include "DM_ctrl.v"

module SCPU(
    input         clk,          // clock
    input         reset,        // reset
    input         INT,          // not used
    input         MIO_ready,    // not used
    output        CPU_MIO,      // not used

    // IM
    output [31:0] PC_out,       // PC address
    input  [31:0] inst_in,      // instruction
   
    // DM
    output        mem_w,        // output: memory write signal
    output [3:0]  wea,          // write enable bit
    output [31:0] Addr_out,     // ALU output
    output [31:0] Data_out,     // data to data memory
    input  [31:0] Data_in       // data from data memory
);

    wire        RegWrite;    // control signal to register write
    wire [5:0]  EXTOp;       // control signal to signed extension
    wire [4:0]  ALUOp;       // ALU opertion
    wire [2:0]  NPCOp;       // next PC operation

    wire [1:0]  WDSel;       // (register) write data selection
    wire [1:0]  GPRSel;      // general purpose register selection
   
    wire        ALUSrc;      // ALU source for A
    wire        Zero;        // ALU ouput zero

    wire [31:0] NPC;         // next PC

    wire [4:0]  rs1;         // rs
    wire [4:0]  rs2;         // rt
    wire [4:0]  rd;          // rd
    wire [6:0]  Op;          // opcode
    wire [6:0]  Funct7;      // funct7
    wire [2:0]  Funct3;      // funct3
    wire [11:0] Imm12;       // 12-bit immediate
    wire [31:0] Imm32;       // 32-bit immediate
    wire [19:0] IMM;         // 20-bit immediate (address)
    wire [4:0]  A3;          // register address for write
    reg  [31:0] WD;          // register write data
    wire [31:0] RD1,RD2;     // register data specified by rs
    wire [31:0] ALU_B;       // operator for ALU B
	
	wire [4:0]  iimm_shamt;
	wire [11:0] iimm,simm,bimm;
	wire [19:0] uimm,jimm;
	wire [31:0] immout;
    wire [31:0] aluout;

    wire [31:0] raw_Data_out;
    wire [31:0] real_Data_in;

    wire [2:0] DMType;

    assign Addr_out = {2'b00, aluout[31:2]};
    // assign Addr_out = {aluout[31:2], 2'b00};

	assign ALU_B = (ALUSrc) ? immout : RD2;
	assign raw_Data_out = RD2;
	
    /*** 指令处理 ***/
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
    assign Imm12 = inst_in[31:20];  // 12-bit immediate
    assign IMM = inst_in[31:12];    // 20-bit immediate
    /*** 指令处理 ***/
   
    // instantiation of control unit
	ctrl U_ctrl(
		.Op(Op), .Funct7(Funct7), .Funct3(Funct3), .Zero(Zero), 
		.RegWrite(RegWrite), .MemWrite(mem_w),
		.EXTOp(EXTOp), .ALUOp(ALUOp), .NPCOp(NPCOp), 
		.ALUSrc(ALUSrc), .GPRSel(GPRSel), .WDSel(WDSel), .DMType(DMType)
	);
    // instantiation of pc unit
	PC U_PC(.clk(clk), .rst(reset), .NPC(NPC), .PC(PC_out) );
	NPC U_NPC(.PC(PC_out), .NPCOp(NPCOp), .IMM(immout), .NPC(NPC), .aluout(aluout));
	EXT U_EXT(
		.iimm_shamt(iimm_shamt), .iimm(iimm), .simm(simm), .bimm(bimm),
		.uimm(uimm), .jimm(jimm),
		.EXTOp(EXTOp), .immout(immout)
	);
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

    DM_ctrl U_DM_ctrl(
        .raw_Data_out(raw_Data_out),
        .dm_Data_out(Data_out),
        .dm_Data_in(Data_in),
        .real_Data_in(real_Data_in),

        .mem_w(mem_w),
        .DMType(DMType),
        .pos(aluout[1:0]),
        .wea(wea)
    );

    //please connnect the CPU by yourself
    always @*
    begin
        case(WDSel)
            `WDSel_FromALU: WD<=aluout;
            `WDSel_FromMEM: WD<=real_Data_in;
            `WDSel_FromPC: WD<=PC_out+4;
        endcase
    end
endmodule