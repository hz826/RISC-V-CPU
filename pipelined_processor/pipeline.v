`include "ctrl.v"
`include "EXT.v"
`include "ALU.v"

module IF(
    input             clk,
    input             rst,
    input             stall,
    input             flush,
    input      [31:0] PC_in,
    input      [31:0] inst_in,
    
    output reg [31:0] PC_out,
    output reg [31:0] inst_out
);

    always @(posedge clk, posedge rst) begin
        if (rst || flush) begin
            PC_out <= 32'b0;
            inst_out <= 32'b0;
        end
        else begin
            if (!(stall === 1'b1)) begin
                PC_out <= PC_in;
                inst_out <= inst_in;
            end
        end
    end
endmodule

module ID(
    input         clk,
    input         rst,
    input  [31:0] PC_in,
    input  [31:0] inst_in,     // instruction
    input  [31:0] RD1,         // read register value
    input  [31:0] RD2,         // read register value
    input         flush,

    // stall
    input        ID_EX_RegWrite,
    input  [4:0] ID_EX_rd,
    input  [6:0] ID_EX_type,
    input        EX_MEM_RegWrite,
    input  [4:0] EX_MEM_rd,
    input  [6:0] EX_MEM_type,
    output       stall,

    // forwarding
    input  [1:0]  ID_EX_WDSel,
    input  [31:0] EX_WD_f,
    input  [31:0] MEM_WD_f,

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
    output reg [6:0]  type,
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
    wire [1:0]  GPRSel;      // general purbiase register selection (unused)

    wire [4:0]  rd_w;
    wire        RegWrite_w;
    wire        MemWrite_w;
    wire [4:0]  ALUOp_w;
    wire [2:0]  NPCOp_w;
    wire [2:0]  DMType_w;
    wire [1:0]  WDSel_w;
    wire [31:0] immout_w;
    wire [6:0]  type_w;
    wire        use_rs1, use_rs2;

    wire [31:0] RD1_f, RD2_f; // forwarding

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
        .ALUSrc(ALUSrc), .GPRSel(GPRSel), .WDSel(WDSel_w), .DMType(DMType_w),
        .type(type_w), .use_rs1(use_rs1), .use_rs2(use_rs2)
    );

    EXT U_EXT(
        .iimm_shamt(iimm_shamt), .iimm(iimm), .simm(simm), .bimm(bimm),
        .uimm(uimm), .jimm(jimm),
        .EXTOp(EXTOp), .immout(immout_w)
    );

    wire dh11 =          ID_EX_RegWrite  & use_rs1 & (ID_EX_rd  == rs1) & (rs1 != 5'b0);
    wire dh12 =          ID_EX_RegWrite  & use_rs2 & (ID_EX_rd  == rs2) & (rs2 != 5'b0);
    wire dh21 = !dh11 && EX_MEM_RegWrite & use_rs1 & (EX_MEM_rd == rs1) & (rs1 != 5'b0);
    wire dh22 = !dh12 && EX_MEM_RegWrite & use_rs2 & (EX_MEM_rd == rs2) & (rs2 != 5'b0);

    wire fw11 = dh11 & (~ID_EX_WDSel[0]);
    wire fw12 = dh12 & (~ID_EX_WDSel[0]);
    wire fw21 = dh21;
    wire fw22 = dh22;

    // ver 0
    // assign stall = 1'b0;

    // ver 1
    // assign stall = (~flush) & (dh11 | dh12 | dh21 | dh22);
    // assign RD1_f = RD1;
    // assign RD2_f = RD2;

    // ver 2
    assign stall =  (~flush) & ((dh11 & ~fw11) | (dh12 & ~fw12));
    assign RD1_f = fw11 ? EX_WD_f : (fw21 ? MEM_WD_f : RD1);
    assign RD2_f = fw12 ? EX_WD_f : (fw22 ? MEM_WD_f : RD2);

    /*********************** after reading registers ************************/

    always @(posedge clk, posedge rst) begin
        if (rst || flush) begin
            ALU_A <= 32'b0;
            ALU_B <= 32'b0;
            ALUOp <= 5'b0;

            PC <= 32'b0;
            immout <= 32'b0;
            NPCOp <= 3'b0;

            MemWrite <= 1'b0;
            DMType <= 3'b0;
            DataWrite <= 32'b0;

            RegWrite <= 1'b0;
            rd <= 5'b0;
            WDSel <= 2'b0;
            type <= 7'b0;
        end
        else begin
            ALU_A <= RD1_f;
            ALU_B <= (ALUSrc) ? immout_w : RD2_f;
            ALUOp <= ALUOp_w;

            PC <= PC_in;
            immout <= immout_w;
            NPCOp <= (stall === 1'b1) ? 3'b0 : NPCOp_w;

            MemWrite <= (stall === 1'b1) ? 1'b0 : MemWrite_w;
            DMType <= DMType_w;
            DataWrite <= RD2_f;

            RegWrite <= (stall === 1'b1) ? 1'b0 : RegWrite_w;
            rd <= rd_w;
            WDSel <= WDSel_w;
            type <= type_w;
        end
    end
endmodule

module EX(
    input         clk,
    input         rst,
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
    input  [31:0] raw_Data_out,// data to data memory

    // to WB
    input         RegWrite_in, // control signal to register write
    input  [4:0]  rd_in,       // write register id
    input  [1:0]  WDSel_in,    // register write data selection
    input  [6:0]  type_in,

    /**********************************************/
    output reg flush,
    output [31:0] EX_WD_f,

    // to MEM
    output reg [31:0] PC,
    output reg [31:0] immout,      // used in NPC
    output reg [2:0]  NPCOp,       // next PC operation NPCOp2[0] = NPCOp1[0] & Zero;

    output reg        MemWrite,    // output: memory write signal
    output reg [2:0]  DMType,      // read/write data length
    output reg [3:0]  wea,         // write enable signal
    output reg [31:0] dm_Data_out, // data to data memory
    output reg [31:0] aluout,

    // to WB
    output reg        RegWrite,    // control signal to register write
    output reg [4:0]  rd,          // write register id
    output reg [1:0]  WDSel,       // register write data selection
    output reg [31:0] WD,          // register write data
    output reg [6:0]  type
);

    wire        Zero;          // ALU ouput zero
    wire [31:0] aluout_w;
    wire [31:0] WD_w;
    wire [31:0] real_Data_out_w;

    /*************************** ALU calculating ***************************/

    // instantiation of alu unit
    alu U_alu(.A(ALU_A), .B(ALU_B), .PC(PC), .ALUOp(ALUOp), .C(aluout_w), .Zero(Zero));
    
    assign WD_w = (WDSel_in == `WDSel_FromPC) ? PC_in+4 : aluout_w;
    assign EX_WD_f = WD_w;

    wire [2:0] bias;
    assign bias = aluout_w[1:0];

    reg [3:0]  wea_tmp1;
    reg [3:0]  wea_tmp2;
    reg [31:0] dm_Data_out_w;

    wire flush_w = (NPCOp_in[0] & Zero) | NPCOp_in[1] | NPCOp_in[2];

    always @(*) begin
        if (MemWrite_in) begin
            case (DMType_in)
                `dm_word: begin
                    wea_tmp1 <= 4'b1111;
                end
                
                `dm_halfword: begin
                    wea_tmp1 <= 4'b0011;
                end

                `dm_byte: begin
                    wea_tmp1 <= 4'b0001;
                end

                default wea_tmp1 <= 4'b0000;
            endcase
        end
        else begin
            wea_tmp1 <= 4'b0000;
        end
    end

    always @(*) begin
        dm_Data_out_w <= raw_Data_out;
        wea_tmp2 <= wea_tmp1;
    end

    /************************** after calculating **************************/

    always @(posedge clk, posedge rst) begin
        if (rst || flush) begin
            PC <= 32'b0;
            immout <= 32'b0;
            NPCOp <= 3'b0;

            MemWrite <= 1'b0;
            DMType <= 3'b0;
            dm_Data_out <= 32'b0;
            wea <= 4'b0;
            aluout <= 32'b0;

            RegWrite <= 1'b0;
            rd <= 5'b0;
            WDSel <= 2'b0;
            WD <= 32'b0;
            type <= 7'b0;
            flush <= 1'b0;
        end
        else begin
            PC <= PC_in;
            immout <= immout_in;
            NPCOp[0] <= NPCOp_in[0] & Zero;
            NPCOp[1] <= NPCOp_in[1];
            NPCOp[2] <= NPCOp_in[2];

            MemWrite <= MemWrite_in;
            DMType <= DMType_in;
            dm_Data_out <= dm_Data_out_w;
            wea <= wea_tmp2;
            aluout <= aluout_w;

            RegWrite <= RegWrite_in;
            rd <= rd_in;
            WDSel <= WDSel_in;
            WD <= WD_w;
            type <= type_in;
            flush <= flush_w;
        end
    end
endmodule

module MEM(
    input         clk,
    input         rst,
    // MEM -> DM -> MEM
    input  [31:0] raw_Data_in, // data from data memory
    input  [2:0]  DMType,
    input  [1:0]  bias,

    // to WB
    input         RegWrite_in, // control signal to register write
    input  [4:0]  rd_in,       // write register id
    input  [1:0]  WDSel_in,    // register write data selection
    input  [31:0] WD_in,       // register write data

    /**********************************************/
    
    output [31:0] MEM_WD_f,

    // to WB
    output reg        RegWrite,    // control signal to register write
    output reg [4:0]  rd,          // write register id
    output reg [31:0] WD           // register write data
);

    /**************************** DM read/write ****************************/

    assign MEM_WD_f = WD_w;

    reg [31:0] dtmp;
    reg [31:0] WD_w;
    reg [31:0] Data_in;

    always @(*) begin
        dtmp <= raw_Data_in;

        case (DMType)
            `dm_word: begin
                Data_in <= dtmp;
            end
            
            `dm_halfword: begin
                Data_in <= {{16{dtmp[15]}}, dtmp[15:0]};
            end

            `dm_byte: begin
                Data_in <= {{24{dtmp[7]}}, dtmp[7:0]};
            end

            `dm_halfword_unsigned: begin
                Data_in <= {16'b0, dtmp[15:0]};
            end

            `dm_byte_unsigned: begin
                Data_in <= {24'b0, dtmp[7:0]};
            end
            default Data_in <= 32'b0;
        endcase

        WD_w <= (WDSel_in == `WDSel_FromMEM) ? Data_in : WD_in;
    end
    
    always @(*) begin
        RegWrite <= RegWrite_in;
        rd <= rd_in;
        WD <= WD_w;
    end
endmodule