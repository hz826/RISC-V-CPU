`include "ctrl_encode_def.v"
`include "alu.v"
`include "EXT.v"
`include "NPC.v"
`include "PC.v"
`include "RF.v"
`include "ctrl.v"
module SCPU(
    input wire clk,
    input wire reset,
    input wire MIO_ready, // Not used
    input wire [31:0] inst_in, //指令输入总线
    input wire [31:0]Data_in, //数据输入总线
    //input wire data_ram_we, //写数据控制
    output wire mem_w, //存储器读写控制
    output wire[31:0]PC_out, //程序空间访问指针
    output wire[31:0]Addr_out, //数据空间访问地址
    output wire[31:0]Data_out, //数据输出总线
    output wire CPU_MIO, // Not used 
    output[3:0] wea,
    input wire INT //中断
);
    wire        RegWrite;    // control signal to register write
    wire [5:0]       EXTOp;       // control signal to signed extension
    wire [4:0]  ALUOp;       // ALU opertion
    wire [2:0]  NPCOp;       // next PC operation

    wire [1:0]  WDSel;       // (register) write data selection
    wire [1:0]  GPRSel;      // general purpose register selection
   
    wire [2:0] DMType;

    wire        ALUSrc;      // ALU source for A
    wire        Zero;        // ALU ouput zero

    wire [31:0] NPC;         // next PC

    wire [4:0]  rs1;          // rs
    wire [4:0]  rs2;          // rt
    wire [4:0]  rd;          // rd
    wire [6:0]  Op;          // opcode
    wire [6:0]  Funct7;       // funct7
    wire [2:0]  Funct3;       // funct3
    wire [11:0] Imm12;       // 12-bit immediate
    wire [31:0] Imm32;       // 32-bit immediate
    wire [19:0] IMM;         // 20-bit immediate (address)
    wire [4:0]  A3;          // register address for write
    reg [31:0] WD;          // register write data
    wire [31:0] RD1,RD2;         // register data specified by rs
    wire [31:0] B;           // operator for ALU B
	
	wire [4:0] iimm_shamt;
	wire [11:0] iimm,simm,bimm;
	wire [19:0] uimm,jimm;
	wire [31:0] immout;
    wire[31:0] aluout;
    assign Addr_out=aluout;
	assign B = (ALUSrc) ? immout : RD2;
    wire [31: 0 ]Data_ori;
	assign Data_ori = RD2;
	
	assign iimm_shamt=inst_in[24:20];
	assign iimm=inst_in[31:20];
	assign simm={inst_in[31:25],inst_in[11:7]};
	assign bimm={inst_in[31],inst_in[7],inst_in[30:25],inst_in[11:8]};
	assign uimm=inst_in[31:12];
	assign jimm={inst_in[31],inst_in[19:12],inst_in[20],inst_in[30:21]};
   
    assign Op = inst_in[6:0];  // instruction
    assign Funct7 = inst_in[31:25]; // funct7
    assign Funct3 = inst_in[14:12]; // funct3
    assign rs1 = inst_in[19:15];  // rs1
    assign rs2 = inst_in[24:20];  // rs2
    assign rd = inst_in[11:7];  // rd
    assign Imm12 = inst_in[31:20];// 12-bit immediate
    assign IMM = inst_in[31:12];  // 20-bit immediate
   
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
	alu U_alu(.A(RD1), .B(B), .ALUOp(ALUOp), .C(aluout), .Zero(Zero), .PC(PC_out));

//please connnect the CPU by yourself
/*always @*
begin
	case(WDSel)
		`WDSel_FromALU: WD<=aluout;
		`WDSel_FromMEM: WD<=Data_in;
		`WDSel_FromPC: WD<=PC_out+4;
	endcase
end*/
reg [31:0] intmp;
wire [1:0] tmp;
assign tmp = (Addr_out[1:0]&({2'b11}));
//display("Addr_out = 0x%x, tmp = 0x%x",addr,tmp);

always @*
begin

    case(DMType)
        /*`dm_word: intmp <= Data_in;
        `dm_halfword: intmp <= {{16{Data_in[15]}}, Data_in[15:0]};
        `dm_halfword_unsigned: intmp <= {16'b0, Data_in[15:0]};
        `dm_byte: intmp <= {{24{Data_in[7]}}, Data_in[7:0]};
        `dm_byte_unsigned: intmp <= {24'b0, Data_in[7:0]};*/
        `dm_word: intmp <= Data_in;
        `dm_halfword: begin
            case(tmp)
                2'b00: intmp <= {{16{Data_in[15]}}, Data_in[15: 0]};
                2'b10: intmp <= {{16{Data_in[31]}}, Data_in[31:16]};
            endcase
        end
        `dm_halfword_unsigned: begin
            case(tmp)
                2'b00: intmp <= {16'b0, Data_in[15: 0]};
                2'b10: intmp <= {16'b0, Data_in[31:16]};
            endcase
        end
        `dm_byte: begin
            case(tmp)
                2'b00: intmp <= {{24{Data_in[ 7]}}, Data_in[ 7: 0]};
                2'b01: intmp <= {{24{Data_in[15]}}, Data_in[15: 8]};
                2'b10: intmp <= {{24{Data_in[23]}}, Data_in[23:16]};
                2'b11: intmp <= {{24{Data_in[31]}}, Data_in[31:24]};
            endcase
        end
        `dm_byte_unsigned: begin
            case(tmp)
                2'b00: intmp <= {24'b0, Data_in[ 7: 0]};
                2'b01: intmp <= {24'b0, Data_in[15: 8]};
                2'b10: intmp <= {24'b0, Data_in[23:16]};
                2'b11: intmp <= {24'b0, Data_in[31:24]};
            endcase
        end
    endcase
	case(WDSel)
		`WDSel_FromALU: WD<=aluout;
		`WDSel_FromMEM: WD<=intmp;
		`WDSel_FromPC:  WD<=PC_out+4;
	endcase
end

reg [3:0] weatmp;
reg [31:0] Data_tmp;

always @* begin
      if (mem_w) begin
		case(DMType)
            `dm_word: begin
                weatmp=4'b1111;
                Data_tmp=Data_ori;
            end
            `dm_halfword: begin
                case(tmp)
                    2'b00: begin
                        weatmp=4'b0011;
                        Data_tmp={16'b0,Data_ori[15: 0]};
                    end
                    2'b10: begin
                        weatmp=4'b1100;
                        Data_tmp={Data_ori[15: 0],16'b0};
                    end
                endcase
            end
            `dm_halfword_unsigned: begin
                case(tmp)
                    2'b00: begin
                        weatmp=4'b0011;
                        Data_tmp={16'b0,Data_ori[15: 0]};
                    end
                    2'b10: begin
                        weatmp=4'b1100;
                        Data_tmp={Data_ori[15: 0],16'b0};
                    end
                endcase
            end
            `dm_byte: begin
                case(tmp)
                    2'b00: begin
                        weatmp=4'b0001;
                        Data_tmp={8'b0,8'b0,8'b0,Data_ori[ 7: 0]};
                    end
                    2'b01: begin
                        weatmp=4'b0010;
                        Data_tmp={8'b0,8'b0,Data_ori[ 7: 0],8'b0};
                    end
                    2'b10: begin
                        weatmp=4'b0100;
                        Data_tmp={8'b0,Data_ori[ 7: 0],8'b0,8'b0};
                    end
                    2'b11: begin
                        weatmp=4'b1000;
                        Data_tmp={Data_ori[ 7: 0],8'b0,8'b0,8'b0};
                    end
                endcase
            end
            `dm_byte_unsigned: begin
                case(tmp)
                    2'b00: begin
                        weatmp=4'b0001;
                        Data_tmp={8'b0,8'b0,8'b0,Data_ori[ 7: 0]};
                    end
                    2'b01: begin
                        weatmp=4'b0010;
                        Data_tmp={8'b0,8'b0,Data_ori[ 7: 0],8'b0};
                    end
                    2'b10: begin
                        weatmp=4'b0100;
                        Data_tmp={8'b0,Data_ori[ 7: 0],8'b0,8'b0};
                    end
                    2'b11: begin
                        weatmp=4'b1000;
                        Data_tmp={Data_ori[ 7: 0],8'b0,8'b0,8'b0};
                    end
                endcase
            end
            //default: assign Data_tmp=Data_ori;
		endcase
      end
      else weatmp=4'b0000;
	//$display("DMTy = 0x%x,",DMType);
	//$display("addr = 0x%x,",addr);
	//$display("dmem[addr] = 0x%2x",dmem[addr]);
	end

assign wea = weatmp;
assign Data_out=Data_tmp;

endmodule