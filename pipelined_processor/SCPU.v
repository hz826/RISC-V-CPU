`include "ctrl.v"
`include "PC.v"
`include "NPC.v"
`include "EXT.v"
`include "RF.v"
`include "ALU.v"

module ID(
    input  [31:0] PC_in,
    input  [31:0] inst_in,     // instruction
    input  [31:0] RD1,         // read register value
    input  [31:0] RD2,         // read register value

    // to RF (ID -> RF -> ID)
    output [4:0]  rs1,         // read register id
    output [4:0]  rs2,         // read register id
    
    // to EX
    output [31:0] ALU_A,       // operator for ALU A
    output [31:0] ALU_B,       // operator for ALU B
    output [4:0]  ALUOp,       // ALU opertion

    // to MEM
    output [31:0] PC,
    output [31:0] immout,      // used in NPC
    output [2:0]  NPCOp,       // next PC operation

    output        MemWrite,    // output: memory write signal
    output [2:0]  DMType,      // read/write data length
    output [31:0] DataWrite,   // data to data memory

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
        .EXTOp(EXTOp), .ALUOp(ALUOp), .NPCOp(NPCOp), 
        .ALUSrc(ALUSrc), .GPRSel(GPRSel), .WDSel(WDSel), .DMType(DMType)
    );

    EXT U_EXT(
        .iimm_shamt(iimm_shamt), .iimm(iimm), .simm(simm), .bimm(bimm),
        .uimm(uimm), .jimm(jimm),
        .EXTOp(EXTOp), .immout(immout)
    );

    /*********************** after reading registers ************************/

    assign ALU_A = RD1;
    assign ALU_B = (ALUSrc) ? immout : RD2;
    assign DataWrite = RD2;
    assign PC = PC_in;
endmodule

module EX(
    // to EX
    input  [31:0] ALU_A,       // operator for ALU A
    input  [31:0] ALU_B,       // operator for ALU B
    input  [4:0]  ALUOp,       // ALU opertion

    // to MEM
    input  [31:0] PC_in,
    input  [31:0] immout_in,   // used in NPC
    input  [2:0]  NPCOp_in,    // next PC operation

    input         MemWrite_in, // output: memory write signal
    input  [2:0]  DMType_in,   // read/write data length
    input  [31:0] DataWrite_in,// data to data memory

    // to WB
    input         RegWrite_in, // control signal to register write
    input  [4:0]  rd_in,       // write register id
    input  [1:0]  WDSel_in,    // register write data selection

    /**********************************************/

    // to MEM
    output [31:0] PC,
    output [31:0] immout,      // used in NPC
    output [2:0]  NPCOp,       // next PC operation NPCOp2[0] = NPCOp1[0] & Zero;

    output        MemWrite,    // output: memory write signal
    output [2:0]  DMType,      // read/write data length
    output [31:0] DataWrite,   // data to data memory
    output [31:0] aluout,

    // to WB
    output        RegWrite,    // control signal to register write
    output [4:0]  rd,          // write register id
    output [1:0]  WDSel,       // register write data selection
    output [31:0] WD           // register write data
);

    wire        Zero;          // ALU ouput zero

    /*************************** ALU calculating ***************************/

    // instantiation of alu unit
    alu U_alu(.A(ALU_A), .B(ALU_B), .PC(PC), .ALUOp(ALUOp), .C(aluout), .Zero(Zero));

    /************************** after calculating **************************/

    assign PC = PC_in;
    assign immout = immout_in;
    assign NPCOp[0] = NPCOp_in[0] & Zero;
    assign NPCOp[1] = NPCOp_in[1];
    assign NPCOp[2] = NPCOp_in[2];

    assign MemWrite = MemWrite_in;
    assign DMType = DMType_in;
    assign DataWrite = DataWrite_in;

    assign RegWrite = RegWrite_in;
    assign rd = rd_in;
    assign WDSel = WDSel_in;
    assign WD = (WDSel == `WDSel_FromPC) ? PC+4 : aluout;
endmodule

module MEM(
    // MEM -> DM -> MEM
    output        MemWrite,    // output: memory write signal
    output [31:0] AddrWrite,   // ALU output
    output [31:0] DataWrite,   // data to data memory
    output [2:0]  DMType,      // read/write data length
    input  [31:0] Data_in,     // data from data memory

    // to MEM
    // input  [31:0] PC,
    // input  [31:0] immout,      // used in NPC
    // input  [2:0]  NPCOp,       // next PC operation NPCOp2[0] = NPCOp1[0] & Zero;

    input         MemWrite_in, // output: memory write signal
    input  [2:0]  DMType_in,   // read/write data length
    input  [31:0] DataWrite_in,// data to data memory
    input  [31:0] aluout,

    // to WB
    input         RegWrite_in, // control signal to register write
    input  [4:0]  rd_in,       // write register id
    input  [1:0]  WDSel_in,    // register write data selection
    input  [31:0] WD_in,       // register write data

    /**********************************************/

    // to WB
    output        RegWrite,    // control signal to register write
    output [4:0]  rd,          // write register id
    output [31:0] WD           // register write data
);

    /**************************** DM read/write ****************************/

    assign MemWrite = MemWrite_in;
    assign AddrWrite = aluout;
    assign DataWrite = DataWrite_in;
    assign DMType = DMType_in;

    assign RegWrite = RegWrite_in;
    assign rd = rd_in;
    assign WD = (WDSel_in == `WDSel_FromMEM) ? Data_in : WD_in;
endmodule

module SCPU(
    input      clk,           // clock
    input      reset,         // reset
    input  [4:0]  reg_sel,    // register selection     (for debug use)
    output [31:0] reg_data,   // selected register data (for debug use)

    // IM
    output [31:0] PC_out,     // PC address
    input  [31:0] inst_in,    // instruction
   
   // DM
    output        mem_w,      // output: memory write signal
    output [31:0] AddrWrite,   // ALU output
    output [31:0] Data_out,   // data to data memory
    output [2:0]  DMType,     // read/write data length
    input  [31:0] Data_in     // data from data memory
);

    // wire [31:0] NPC;         // next PC
    // NPC U_NPC(.PC(PC), .NPCOp(NPCOp), .IMM(immout), .NPC(NPC), .aluout(aluout));

    // // instantiation of pc unit
    // PC U_PC(.clk(clk), .rst(reset), .NPC(NPC), .PC(PC));
    
    RF U_RF(
        .clk(clk), .rst(reset),
        .RFWr(RegWrite), 
        .A1(rs1), .A2(rs2), .A3(rd), 
        .WD(WD), 
        .RD1(RD1), .RD2(RD2)
        //.reg_sel(reg_sel),
        //.reg_data(reg_data)
    );
endmodule