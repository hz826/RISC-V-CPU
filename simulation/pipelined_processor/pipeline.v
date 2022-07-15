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
            if (!(stall === 1'b1)) begin // 处理停顿
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
    input  [31:0] inst_in,

    // to RF (ID -> RF -> ID)
    output [4:0]  rs1,         // 读寄存器号
    output [4:0]  rs2,         // 读寄存器号
    input  [31:0] RD1,         // 读寄存器值
    input  [31:0] RD2,         // 读寄存器值

    input         flush,

    // 停顿
    input        ID_EX_RegWrite,
    input  [4:0] ID_EX_rd,
    input  [6:0] ID_EX_type,
    input        EX_MEM_RegWrite,
    input  [4:0] EX_MEM_rd,
    input  [6:0] EX_MEM_type,
    output       stall,

    // 前递
    input  [1:0]  ID_EX_WDSel,
    input  [31:0] EX_WD_f,
    input  [31:0] MEM_WD_f,

    // to EX
    output reg [31:0] ALU_A,       // ALU 输入值 A
    output reg [31:0] ALU_B,       // ALU 输入值 B
    output reg [4:0]  ALUOp,       // ALU 控制信号

    // to MEM
    output reg [31:0] PC,
    output reg [31:0] immout,      // 从指令中提取的立即数
    output reg [2:0]  NPCOp,       // next PC 控制信号

    output reg        MemWrite,    // 受否写内存
    output reg [2:0]  DMType,      // 读写内存的控制信号
    output reg [31:0] DataWrite,   // 写入内存的数据

    // to WB
    output reg [6:0]  type,        // 指令格式
    output reg        RegWrite,    // 是否写寄存器
    output reg [4:0]  rd,          // 写寄存器号
    output reg [1:0]  WDSel        // 写入寄存器的数据来源
);

    wire [4:0]  iimm_shamt;
    wire [11:0] iimm,simm,bimm;
    wire [19:0] uimm,jimm;

    wire [6:0]  Op;          // opcode
    wire [6:0]  Funct7;      // funct7
    wire [2:0]  Funct3;      // funct3

    wire [5:0]  EXTOp;       // 立即数提取信号
    wire        ALUSrc;      // ALU 输入值 B 的来源
    wire [1:0]  GPRSel;      // general purbiase register selection (unused)

    wire [4:0]  rd_w;        // 先用 wire 计算结果，在上升沿写入寄存器
    wire        RegWrite_w;
    wire        MemWrite_w;
    wire [4:0]  ALUOp_w;
    wire [2:0]  NPCOp_w;
    wire [2:0]  DMType_w;
    wire [1:0]  WDSel_w;
    wire [31:0] immout_w;
    wire [6:0]  type_w;
    wire        use_rs1, use_rs2;

    wire [31:0] RD1_f, RD2_f; // 考虑前递后的寄存器读取值

    // 处理指令
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

    // 从指令中提取控制信号
    ctrl U_ctrl(
        // input
        .Op(Op), .Funct7(Funct7), .Funct3(Funct3),
        // output
        .RegWrite(RegWrite_w), .MemWrite(MemWrite_w),
        .EXTOp(EXTOp), .ALUOp(ALUOp_w), .NPCOp(NPCOp_w), 
        .ALUSrc(ALUSrc), .GPRSel(GPRSel), .WDSel(WDSel_w), .DMType(DMType_w),
        .type(type_w), .use_rs1(use_rs1), .use_rs2(use_rs2)
    );

    // 从指令中提取立即数
    EXT U_EXT(
        .iimm_shamt(iimm_shamt), .iimm(iimm), .simm(simm), .bimm(bimm),
        .uimm(uimm), .jimm(jimm),
        .EXTOp(EXTOp), .immout(immout_w)
    );

    // 分析是否有数据冒险
    wire dh11 =          ID_EX_RegWrite  & use_rs1 & (ID_EX_rd  == rs1) & (rs1 != 5'b0);
    wire dh12 =          ID_EX_RegWrite  & use_rs2 & (ID_EX_rd  == rs2) & (rs2 != 5'b0);
    wire dh21 = !dh11 && EX_MEM_RegWrite & use_rs1 & (EX_MEM_rd == rs1) & (rs1 != 5'b0);
    wire dh22 = !dh12 && EX_MEM_RegWrite & use_rs2 & (EX_MEM_rd == rs2) & (rs2 != 5'b0);

    // 分析是否可以通过前递解决数据冒险
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
    // 处理停顿和前递
    assign stall = (~flush) & ((dh11 & ~fw11) | (dh12 & ~fw12));
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
            NPCOp <= (stall === 1'b1) ? 3'b0 : NPCOp_w; // 停顿时输出空指令给下一级流水线

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
    input  [31:0] ALU_A,       // ALU 输入值 A
    input  [31:0] ALU_B,       // ALU 输入值 B
    input  [4:0]  ALUOp,       // ALU 控制信号

    // to MEM
    input  [31:0] PC_in,
    input  [31:0] immout_in,   // 从指令中提取的立即数
    input  [2:0]  NPCOp_in,    // next PC 控制信号

    input         MemWrite_in, // 受否写内存
    input  [2:0]  DMType_in,   // 读写内存的控制信号
    input  [31:0] raw_Data_out,// 写入内存的数据

    // to WB
    input         RegWrite_in, // 是否写寄存器
    input  [4:0]  rd_in,       // 写寄存器号
    input  [1:0]  WDSel_in,    // 写入寄存器的数据来源
    input  [6:0]  type_in,     // 指令格式

    /**********************************************/

    output reg flush,          // 在 EX 阶段判断是否有跳转需要清空前面的流水线
    output [31:0] EX_WD_f,     // 前递数据

    // to MEM
    output reg [31:0] PC,
    output reg [31:0] immout,      // 从指令中提取的立即数
    output reg [2:0]  NPCOp,       // next PC 控制信号

    output reg        MemWrite,    // 受否写内存
    output reg [2:0]  DMType,      // 读写内存的控制信号
    output reg [3:0]  wea,         // 写使能信号
    output reg [31:0] dm_Data_out, // 写入内存的数据
    output reg [31:0] aluout,

    // to WB
    output reg        RegWrite,    // 是否写寄存器
    output reg [4:0]  rd,          // 写寄存器号
    output reg [1:0]  WDSel,       // 写入寄存器的数据来源
    output reg [31:0] WD,          // 写入寄存器的数据
    output reg [6:0]  type         // 指令格式
);

    wire        Zero;          // ALU 输出
    wire [31:0] aluout_w;      // ALU 输出
    wire [31:0] WD_w;
    wire [31:0] real_Data_out_w;

    /*************************** ALU calculating ***************************/

    alu U_alu(.A(ALU_A), .B(ALU_B), .PC(PC), .ALUOp(ALUOp), .C(aluout_w), .Zero(Zero));
    
    assign WD_w = (WDSel_in == `WDSel_FromPC) ? PC_in+4 : aluout_w;
    assign EX_WD_f = WD_w; // 前递 ALU 计算结果

    wire [2:0] bias;
    assign bias = aluout_w[1:0]; // 用于对齐内存地址（未使用）

    reg [3:0]  wea_tmp1;
    reg [3:0]  wea_tmp2;
    reg [31:0] dm_Data_out_w;

    wire flush_w = (NPCOp_in[0] & Zero) | NPCOp_in[1] | NPCOp_in[2]; // 跳转，清空前面的流水线

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

    always @(*) begin // 用于对齐内存地址（未使用）
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
    input  [31:0] raw_Data_in, // 从内存中读取的数据
    input  [2:0]  DMType,      // 读数据类型
    input  [1:0]  bias,        // 内存地址对齐值（未使用）

    // to WB
    input         RegWrite_in, // 是否写寄存器
    input  [4:0]  rd_in,       // 写寄存器号
    input  [1:0]  WDSel_in,    // 写入寄存器的数据来源
    input  [31:0] WD_in,       // 写入寄存器的数据

    /**********************************************/
    
    output [31:0] MEM_WD_f,    // 前递内存读取结果

    // to WB
    output reg        RegWrite,    // 是否写寄存器
    output reg [4:0]  rd,          // 写寄存器号
    output reg [31:0] WD           // 写入寄存器的数据
);

    /**************************** DM read/write ****************************/

    assign MEM_WD_f = WD_w;

    reg [31:0] dtmp;
    reg [31:0] WD_w;
    reg [31:0] Data_in;

    always @(*) begin // 将从内存中读取出的数扩展到32位
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