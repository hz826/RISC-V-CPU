`include "PC.v"
`include "RF.v"
`include "pipeline.v"

module SCPU(
    input         clk,          // clock
    input         reset,        // reset
    input         INT,          // not used
    input         MIO_ready,    // not used
    output        CPU_MIO,      // not used
    input  [4:0]  reg_sel,      // register selection     (for debug use)
    output [31:0] reg_data,     // selected register data (for debug use)

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
    wire [31:0] PC;
    wire [2:0]  PCOP;
    wire stall;
    wire flush;
    wire [31:0] EX_WD_f;
    wire [31:0] MEM_WD_f;

    wire [31:0] IF_ID_PC;
    wire [31:0] IF_ID_inst;

    wire [31:0] RD1;
    wire [31:0] RD2;
    wire [4:0]  rs1;
    wire [4:0]  rs2;

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
    wire [6:0]  ID_EX_type;

    wire [31:0] EX_MEM_PC;
    wire [31:0] EX_MEM_immout;
    wire [2:0]  EX_MEM_NPCOp;
    wire        EX_MEM_MemWrite;
    wire [2:0]  EX_MEM_DMType;
    wire [3:0]  EX_MEM_wea;
    wire [31:0] EX_MEM_DataWrite;
    wire [31:0] EX_MEM_aluout;
    wire        EX_MEM_RegWrite;
    wire [4:0]  EX_MEM_rd;
    wire [1:0]  EX_MEM_WDSel;
    wire [31:0] EX_MEM_WD;
    wire [6:0]  EX_MEM_type;

    wire [31:0] MEM_NPC;         // next PC

    wire        MEM_WB_RegWrite;
    wire [4:0]  MEM_WB_rd;
    wire [31:0] MEM_WB_WD;

    // assign PCOP = (EX_MEM_NPCOp == `NPC_PLUS4) ? `PC_PLUS4 : `PC_JUMP;
    // IF
    PC U_PC(
        .clk(clk), .rst(reset), 
        .stall(stall),
        .NPCOP(EX_MEM_NPCOp), .NPC(MEM_NPC), // input
        .PC(PC)                              // output
    ); // PC = NPC when posedge clk
    assign PC_out = PC;
    // PC -> IM -> inst_in

    IF U_IF(
        .clk(clk), 
        .rst(reset),
        .stall(stall),
        .flush(flush),
        // input
        .PC_in(PC),
        .inst_in(inst_in),
        // output
        .PC_out(IF_ID_PC),
        .inst_out(IF_ID_inst)
    );

    // ID
    // WB
    RF U_RF(
        .clk(clk), .rst(reset),
        .A1(rs1), .A2(rs2), .RD1(RD1), .RD2(RD2), // read
        .RFWr(MEM_WB_RegWrite), .A3(MEM_WB_rd), .WD(MEM_WB_WD)         // write
        //.reg_sel(reg_sel),
        //.reg_data(reg_data)
    );

    ID U_ID(
        .clk(clk), 
        .rst(reset),
        .flush(flush),
        // IF_ID
        .PC_in(IF_ID_PC), .inst_in(IF_ID_inst),

        // ID -> RF -> ID
        .RD1(RD1), .RD2(RD2), .rs1(rs1), .rs2(rs2),

        // stall & forwarding
        .ID_EX_rd(ID_EX_rd),
        .EX_MEM_rd(EX_MEM_rd),
        .ID_EX_RegWrite(ID_EX_RegWrite),
        .EX_MEM_RegWrite(EX_MEM_RegWrite),
        .ID_EX_type(ID_EX_type),
        .EX_MEM_type(EX_MEM_type),
        .ID_EX_WDSel(ID_EX_WDSel),
        .EX_WD_f(EX_WD_f),
        .MEM_WD_f(MEM_WD_f),
        .stall(stall),

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

    //  EX                                                                                      
    EX U_EX(
        .clk(clk), 
        .rst(reset),
        .flush(flush),
        .EX_WD_f(EX_WD_f),

        // ID_EX
        .ALU_A(ID_EX_ALU_A),
        .ALU_B(ID_EX_ALU_B),
        .ALUOp(ID_EX_ALUOp),
        .PC_in(ID_EX_PC),
        .immout_in(ID_EX_immout),
        .NPCOp_in(ID_EX_NPCOp),
        .MemWrite_in(ID_EX_MemWrite),
        .DMType_in(ID_EX_DMType),
        .raw_Data_out(ID_EX_DataWrite),
        .RegWrite_in(ID_EX_RegWrite),
        .rd_in(ID_EX_rd),
        .WDSel_in(ID_EX_WDSel),

        // EX_MEM
        .PC(EX_MEM_PC),
        .immout(EX_MEM_immout),
        .NPCOp(EX_MEM_NPCOp),
        .MemWrite(EX_MEM_MemWrite),
        .DMType(EX_MEM_DMType),
        .wea(EX_MEM_wea),
        .dm_Data_out(EX_MEM_DataWrite),
        .aluout(EX_MEM_aluout),
        .RegWrite(EX_MEM_RegWrite),
        .rd(EX_MEM_rd),
        .WDSel(EX_MEM_WDSel),
        .WD(EX_MEM_WD)
    );

    // MEM
    // NPC
    NPC U_NPC(
        .PC(EX_MEM_PC), 
        .NPCOp(EX_MEM_NPCOp), 
        .IMM(EX_MEM_immout), 
        .aluout(EX_MEM_aluout),  // input
        .NPC(MEM_NPC)         // output
    );

    // DM
    assign mem_w     = EX_MEM_MemWrite;
    // assign Addr_out  = EX_MEM_aluout;
    // assign Addr_out  = {EX_MEM_aluout[31:2], 2'b00};
    // assign Addr_out  = {2'b00, EX_MEM_aluout[31:2]};
    assign Addr_out  = (mem_w || EX_MEM_WDSel == `WDSel_FromMEM) ? {2'b00, EX_MEM_aluout[31:2]} : 32'b0;
    assign wea       = EX_MEM_wea;
    assign Data_out  = EX_MEM_DataWrite;
    assign DMType    = EX_MEM_DMType;
    
    MEM U_MEM(
        .clk(clk), 
        .rst(reset),

        .MEM_WD_f(MEM_WD_f),

        .raw_Data_in(Data_in),
        .DMType(EX_MEM_DMType),
        .bias(EX_MEM_aluout[1:0]),

        .RegWrite_in(EX_MEM_RegWrite),
        .rd_in(EX_MEM_rd),
        .WDSel_in(EX_MEM_WDSel),
        .WD_in(EX_MEM_WD),

        .RegWrite(MEM_WB_RegWrite),
        .rd(MEM_WB_rd),
        .WD(MEM_WB_WD)
    );
endmodule