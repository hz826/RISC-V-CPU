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
    output reg [31:0] ALU_A,       // operator for ALU A
    output reg [31:0] ALU_B,       // operator for ALU B
    output reg [4:0]  ALUOp,       // ALU opertion

    // to MEM
    output reg [31:0] PC,
    output reg [31:0] immout,      // used in NPC
    output reg [2:0]  NPCOp,       // next PC operation

    output reg        MemWrite,    // output: memory write signal
    output reg [2:0]  DMType,      // read/write data length
    output reg [31:0] DataWrite,   // data to data memory

    // to WB
    output reg        RegWrite,    // control signal to register write
    output reg [4:0]  rd,          // write register id
    output reg [1:0]  WDSel        // (register) write data selection
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

    wire [4:0]  rd_w;
    wire        RegWrite_w;
    wire        MemWrite_w;
    wire [4:0]  ALUOp_w;
    wire [2:0]  NPCOp_w;
    wire [2:0]  DMType_w;
    wire [1:0]  WDSel_w;
    wire [31:0] immout_w;

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
    assign rd_w = inst_in[11:7];    // rd
    // assign Imm12 = inst_in[31:20];  // 12-bit immediate
    // assign IMM = inst_in[31:12];    // 20-bit immediate

    // instantiation of control unit
    ctrl U_ctrl(
        // input
        .Op(Op), .Funct7(Funct7), .Funct3(Funct3),
        // output
        .RegWrite(RegWrite_w), .MemWrite(MemWrite_w),
        .EXTOp(EXTOp), .ALUOp(ALUOp_w), .NPCOp(NPCOp_w), 
        .ALUSrc(ALUSrc), .GPRSel(GPRSel), .WDSel(WDSel_w), .DMType(DMType_w)
    );

    EXT U_EXT(
        .iimm_shamt(iimm_shamt), .iimm(iimm), .simm(simm), .bimm(bimm),
        .uimm(uimm), .jimm(jimm),
        .EXTOp(EXTOp), .immout(immout_w)
    );

    /*********************** after reading registers ************************/

    always @(*) begin
        ALU_A <= RD1;
        ALU_B <= (ALUSrc) ? immout : RD2;
        ALUOp <= ALUOp_w;

        PC <= PC_in;
        immout <= immout_w;
        NPCOp <= NPCOp_w;

        MemWrite <= MemWrite_w;
        DMType <= DMType_w;
        DataWrite <= RD2;

        RegWrite <= RegWrite_w;
        rd <= rd_w;
        WDSel <= WDSel_w;
    end
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
    output reg [31:0] PC,
    output reg [31:0] immout,      // used in NPC
    output reg [2:0]  NPCOp,       // next PC operation NPCOp2[0] = NPCOp1[0] & Zero;

    output reg        MemWrite,    // output: memory write signal
    output reg [2:0]  DMType,      // read/write data length
    output reg [31:0] DataWrite,   // data to data memory
    output reg [31:0] aluout,

    // to WB
    output reg        RegWrite,    // control signal to register write
    output reg [4:0]  rd,          // write register id
    output reg [1:0]  WDSel,       // register write data selection
    output reg [31:0] WD           // register write data
);

    wire        Zero;          // ALU ouput zero
    wire [31:0] aluout_w;
    wire [31:0] WD_w;

    /*************************** ALU calculating ***************************/

    // instantiation of alu unit
    alu U_alu(.A(ALU_A), .B(ALU_B), .PC(PC), .ALUOp(ALUOp), .C(aluout_w), .Zero(Zero));
    
    assign WD_w = (WDSel == `WDSel_FromPC) ? PC_in+4 : aluout;

    /************************** after calculating **************************/

    always @(*) begin
        PC <= PC_in;
        immout <= immout_in;
        NPCOp[0] <= NPCOp_in[0] & Zero;
        NPCOp[1] <= NPCOp_in[1];
        NPCOp[2] <= NPCOp_in[2];

        MemWrite <= MemWrite_in;
        DMType <= DMType_in;
        DataWrite <= DataWrite_in;
        aluout <= aluout_w;

        RegWrite <= RegWrite_in;
        rd <= rd_in;
        WDSel <= WDSel_in;
        WD <= WD_w;
    end
endmodule

module MEM(
    // MEM -> DM -> MEM
    input  [31:0] Data_in,     // data from data memory

    // to WB
    input         RegWrite_in, // control signal to register write
    input  [4:0]  rd_in,       // write register id
    input  [1:0]  WDSel_in,    // register write data selection
    input  [31:0] WD_in,       // register write data

    /**********************************************/

    // to WB
    output reg        RegWrite,    // control signal to register write
    output reg [4:0]  rd,          // write register id
    output reg [31:0] WD           // register write data
);

    /**************************** DM read/write ****************************/

    assign WD_w = (WDSel_in == `WDSel_FromMEM) ? Data_in : WD_in;
    
    always @(*) begin
        RegWrite <= RegWrite_in;
        rd <= rd_in;
        WD <= WD_w;
    end
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

    wire [31:0] PC_in;
    wire [31:0] inst_in;

    wire [31:0] RD1;
    wire [31:0] RD2;
    wire [4:0] rs1;
    wire [4:0] rs2;

    wire [31:0] ID_EX_ALU_A;
    wire [31:0] ID_EX_ALU_B;
    wire [4:0]  ID_EX_ALUOp;
    wire [31:0] ID_EX_PC;
    wire [31:0] ID_EX_immout;
    wire [2:0]  ID_EX_NPCOp;
    wire        ID_EX_MemWrite;
    wire [2:0]  ID_EX_DMType;
    wire [31:0] ID_EX_DataWrite;
    wire        ID_EX_RegWrite;
    wire [4:0]  ID_EX_rd;
    wire [1:0]  ID_EX_WDSel;

    wire [31:0] EX_MEM_PC;
    wire [31:0] EX_MEM_immout;
    wire [2:0]  EX_MEM_NPCOp;
    wire        EX_MEM_MemWrite;
    wire [2:0]  EX_MEM_DMType;
    wire [31:0] EX_MEM_DataWrite;
    wire [31:0] EX_MEM_aluout;
    wire        EX_MEM_RegWrite;
    wire [4:0]  EX_MEM_rd;
    wire [1:0]  EX_MEM_WDSel;
    wire [31:0] EX_MEM_WD;

    wire        MEM_WB_RegWrite;
    wire [4:0]  MEM_WB_rd;
    wire [31:0] MEM_WB_WD;

    RF U_RF(
        .clk(clk), .rst(reset),
        .A1(rs1), .A2(rs2), .RD1(RD1), .RD2(RD2), // read
        .RFWr(MEM_WB_RegWrite), .A3(MEM_WB_rd), .WD(MEM_WB_WD)         // write
        //.reg_sel(reg_sel),
        //.reg_data(reg_data)
    );

    ID U_ID(
        // IF_ID
        .PC_in(PC_in), .inst_in(inst_in),

        // ID -> RF -> ID
        .RD1(RD1), .RD2(RD2), .rs1(rs1), .rs2(rs2),

        // ID_EX
        .ALU_A(ID_EX_ALU_A),
        .ALU_B(ID_EX_ALU_B),
        .ALUOp(ID_EX_ALUOp),
        .PC(ID_EX_PC),
        .immout(ID_EX_immout),
        .NPCOp(ID_EX_NPCOp),
        .MemWrite(ID_EX_MemWrite),
        .DMType(ID_EX_DMType),
        .DataWrite(ID_EX_DataWrite),
        .RegWrite(ID_EX_RegWrite),
        .rd(ID_EX_rd),
        .WDSel(ID_EX_WDSel)
    );

    EX U_EX(
        // ID_EX
        .ALU_A(ID_EX_ALU_A),
        .ALU_B(ID_EX_ALU_B),
        .ALUOp(ID_EX_ALUOp),
        .PC_in(ID_EX_PC),
        .immout_in(ID_EX_immout),
        .NPCOp_in(ID_EX_NPCOp),
        .MemWrite_in(ID_EX_MemWrite),
        .DMType_in(ID_EX_DMType),
        .DataWrite_in(ID_EX_DataWrite),
        .RegWrite_in(ID_EX_RegWrite),
        .rd_in(ID_EX_rd),
        .WDSel_in(ID_EX_WDSel),

        // EX_MEM
        .PC(EX_MEM_PC),
        .immout(EX_MEM_immout),
        .NPCOp(EX_MEM_NPCOp),
        .MemWrite(EX_MEM_MemWrite),
        .DMType(EX_MEM_DMType),
        .DataWrite(EX_MEM_DataWrite),
        .aluout(EX_MEM_aluout),
        .RegWrite(EX_MEM_RegWrite),
        .rd(EX_MEM_rd),
        .WDSel(EX_MEM_WDSel),
        .WD(EX_MEM_WD)
    );

    // DM
    assign mem_w     = EX_MEM_MemWrite;
    assign AddrWrite = EX_MEM_aluout;
    assign Data_out  = EX_MEM_DataWrite;
    assign DMType    = EX_MEM_DMType;
    
    MEM U_MEM(
        .Data_in(Data_in),
        .RegWrite_in(EX_MEM_RegWrite),
        .rd_in(EX_MEM_rd),
        .WDSel_in(EX_MEM_WDSel),
        .WD_in(EX_MEM_WD),

        .RegWrite(MEM_WB_RegWrite),
        .rd(MEM_WB_rd),
        .WD(MEM_WB_WD)
    );

    // to MEM
    // input         MemWrite_in, // output: memory write signal
    // input  [2:0]  DMType_in,   // read/write data length
    // input  [31:0] DataWrite_in,// data to data memory
    // input  [31:0] aluout,
endmodule