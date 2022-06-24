`include "ctrl.v"
`include "EXT.v"
`include "ALU.v"

module IF(
    input             clk,
    inout             stall,
    input      [31:0] PC_in,
    input      [31:0] inst_in,
    
    output reg [31:0] PC_out,
    output reg [31:0] inst_out
);

    always @(posedge clk) begin
        if (!(stall === 1'b1)) begin
            PC_out <= PC_in;
            inst_out <= inst_in;
        end
    end
endmodule

module ID(
    input         clk,
    input  [31:0] PC_in,
    input  [31:0] inst_in,     // instruction
    input  [31:0] RD1,         // read register value
    input  [31:0] RD2,         // read register value

    // stall
    input        ID_EX_RegWrite,
    input  [4:0] ID_EX_rd,
    input  [6:0] ID_EX_type,
    input        EX_MEM_RegWrite,
    input  [4:0] EX_MEM_rd,
    input  [6:0] EX_MEM_type,
    output       stall,

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
        .type(type_w)
    );

    EXT U_EXT(
        .iimm_shamt(iimm_shamt), .iimm(iimm), .simm(simm), .bimm(bimm),
        .uimm(uimm), .jimm(jimm),
        .EXTOp(EXTOp), .immout(immout_w)
    );

    // wire dh11 = ID_EX_RegWrite & (ID_EX_rd === rs1);
    assign stall = (ID_EX_RegWrite & (ID_EX_rd === rs1 || ID_EX_rd === rs2))
                | (EX_MEM_RegWrite & (EX_MEM_rd === rs1 || EX_MEM_rd === rs2));
    // assign stall = 1'b0;

    /*********************** after reading registers ************************/

    always @(posedge clk) begin
        ALU_A <= RD1;
        ALU_B <= (ALUSrc) ? immout_w : RD2;
        ALUOp <= ALUOp_w;

        PC <= PC_in;
        immout <= immout_w;
        NPCOp <= NPCOp_w;

        MemWrite <= (stall === 1'b1) ? 1'b0 : MemWrite_w;
        DMType <= DMType_w;
        DataWrite <= RD2;

        RegWrite <= (stall === 1'b1) ? 1'b0 : RegWrite_w;
        rd <= rd_w;
        WDSel <= WDSel_w;
        type <= type_w;
    end
endmodule

module EX(
    input         clk,
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

    wire [2:0] bias;
    assign bias = aluout_w[1:0];

    reg [3:0]  wea_tmp;
    reg [31:0] dm_Data_out_w;

    always @(*) begin
        dm_Data_out_w <= (raw_Data_out << (bias << 3));

        if (MemWrite_in) begin
            case (DMType)
                `dm_word: begin
                    wea_tmp <= (4'b1111 << bias);
                end
                
                `dm_halfword: begin
                    wea_tmp <= (4'b0011 << bias);
                end

                `dm_byte: begin
                    wea_tmp <= (4'b0001 << bias);
                end

                default wea_tmp <= 4'b0000;
            endcase
        end
        else begin
            wea_tmp <= 4'b0000;
        end
    end

    /************************** after calculating **************************/

    always @(posedge clk) begin
        PC <= PC_in;
        immout <= immout_in;
        NPCOp[0] <= NPCOp_in[0] & Zero;
        NPCOp[1] <= NPCOp_in[1];
        NPCOp[2] <= NPCOp_in[2];

        MemWrite <= MemWrite_in;
        DMType <= DMType_in;
        dm_Data_out <= dm_Data_out_w;
        wea <= wea_tmp;
        aluout <= aluout_w;

        RegWrite <= RegWrite_in;
        rd <= rd_in;
        WDSel <= WDSel_in;
        WD <= WD_w;
        type <= type_in;
    end
endmodule

module MEM(
    input         clk,
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

    // to WB
    output reg        RegWrite,    // control signal to register write
    output reg [4:0]  rd,          // write register id
    output reg [31:0] WD           // register write data
);

    /**************************** DM read/write ****************************/

    reg [31:0] dtmp;
    reg [31:0] WD_w;
    reg [31:0] Data_in;

    always @(*) begin
        dtmp <= (raw_Data_in >> (bias << 3));

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