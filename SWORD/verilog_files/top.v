`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:06:29 06/21/2022 
// Design Name: 
// Module Name:    top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module IP2SOC_Top(
    input         RSTN,
    input  [ 3:0] BTN_y,
    input  [15:0] SW,
    input         clk_100mhz,

    output        CR,
    output        seg_clk,
    output        seg_sout,
    output        SEG_PEN,
    output        seg_clrn,
    output        led_clk,
    output        led_sout,
    output        LED_PEN,
    output        led_clrn,
    output        RDY,
    output        readn,
    output  [4:0] BTN_x
);

wire clk_100mhz_neg;
assign clk_100mhz_neg = ~clk_100mhz;

// U1
wire [31:0] PC;
wire [31:0] Addr_out;
wire [31:0] Data_out;
wire        mem_w;
wire [ 3:0] wea;

// U2
wire [31:0] inst;

// U3
wire [31:0] ram_data_out;

// U4
wire [31:0] Data_in;
wire [31:0] ram_data_in;
wire [ 9:0] ram_addr;
wire        data_ram_we;
wire        counter_we;
wire        GPIOF0;
wire        GPIOE0;
wire [31:0] CPU2IO;

// U5
wire [ 7:0] LE_out;
wire [ 7:0] point_out;
wire [31:0] Disp_num;

// U7
wire [15:0] LED_out;
wire [ 1:0] counter_set;
wire [13:0] U7_GPIOf0;

// U8
wire [31:0] Div;
wire        Clk_CPU;
wire        Clk_CPU_neg;
assign Clk_CPU_neg = ~Clk_CPU;

// U9
wire [ 3:0] Pulse;
wire [15:0] SW_OK_U9;
wire [ 3:0] BTN_OK;
wire        rst;
wire [ 4:0] Key_out;

// U10
wire counter0_OUT;
wire counter1_OUT;
wire counter2_OUT;
wire [31:0] counter_out;

// M4
wire [ 7:0] blink;
wire [31:0] Ai;
wire [31:0] Bi;

/////////////////////////////////////////

// U1
wire [31:0] reg_data;
wire [15:0] PC_tmp = PC[17:2];
reg [31:0] data1;

wire [31:0] SW_OK = SW_OK_U9[15] ? SW_OK_U9 : 16'h0001;

always @(*) begin
	case (SW_OK[14:13])
		2'b00: begin
			data1 <= {2'b00, PC[31:2]};
		end
		2'b01: begin
			data1 <= {PC_tmp, reg_data[15:0]};
		end
		2'b10: begin
			data1 <= {reg_data[31:16], PC_tmp};
		end
		2'b11: begin
			data1 <= reg_data;
		end
	endcase
end

SCPU U_SCPU(
    .clk(Clk_CPU),
    //.reset(rst),
	 .reset(rst),
    // input MIO_ready,
	 .reg_sel(SW_OK[12:8]), // for debug
	 .reg_data(reg_data), // for debug
	 
    .inst_in(inst),
    .Data_in(Data_in),
  
    .mem_w(mem_w),
    .wea(wea),
    .PC_out(PC),
    .Addr_out(Addr_out),
    .Data_out(Data_out),
    // output CPU_MIO,
    .INT(counter0_OUT)
);

// U2
ROM_B U_ROM_B(
    .a(PC[11:2]),
    .spo(inst)
);

// U3
RAM_B U_RAM_B(
    .addra(ram_addr),
    .wea(wea),
    .dina(ram_data_in),
    .clka(clk_100mhz_neg),
    .douta(ram_data_out)
);

// U4
MIO_BUS U_MIO_BUS(
    .clk(clk_100mhz),
    .rst(rst),
    .BTN(BTN_OK[3:0]),
    .SW(SW_OK_U9),
    .mem_w(mem_w),
    .Cpu_data2bus(Data_out),
    .addr_bus(Addr_out),
    .ram_data_out(ram_data_out),
    .led_out(LED_out),
    .counter0_out(counter0_OUT),
    .counter1_out(counter1_OUT),
    .counter2_out(counter2_OUT),
    .counter_out(counter_out),
    
    .Cpu_data4bus(Data_in),
    .ram_data_in(ram_data_in),
    .ram_addr(ram_addr),
    .data_ram_we(data_ram_we),
    .GPIOf0000000_we(GPIOF0),
    .GPIOe0000000_we(GPIOE0),
    .counter_we(counter_we),
    .Peripheral_in(CPU2IO)
);

// U5
Multi_8CH32 U_Multi_8CH32(
    .clk(Clk_CPU_neg),
    .rst(rst),
    .EN(GPIOE0),
    .Test(SW_OK[7:5]),///
    .point_in({Div[31:0],Div[31:0]}),
    .LES(64'b0),
    .Data0(CPU2IO),
    .data1(data1),
    .data2(inst),
    .data3(counter_out),
    .data4(Addr_out),
    .data5(Data_out),
    .data6(Data_in),
    .data7(PC),
    .point_out(point_out),
    .LE_out(LE_out),
    .Disp_num(Disp_num)
);

// U6
SSeg7_Dev U_SSeg7_Dev(
    .clk(clk_100mhz),
    .rst(rst),
    .Start(Div[20]),
    .SW0(SW_OK[0]),
    .flash(Div[25]),
    .Hexs(Disp_num),
    .point(point_out),
    .LES(LE_out),
    .seg_clk(seg_clk),
    .seg_sout(seg_sout),
    .SEG_PEN(SEG_PEN),
    .seg_clrn(seg_clrn)
);

// U7
SPIO U_SPIO(
    .clk(Clk_CPU_neg),
    .rst(rst),
    .Start(Div[20]),
    .EN(GPIOF0),
    .P_Data(CPU2IO),
    .counter_set(counter_set),
    .LED_out(LED_out),
    .led_clk(led_clk),
    .led_sout(led_sout),
    .led_clrn(led_clrn),
    .LED_PEN(LED_PEN),
    .GPIOf0(U7_GPIOf0)
);

// U8
clk_div U_clk_div(
    .clk(clk_100mhz),
    .rst(rst),
    .SW2(SW_OK[2] ^ SW_OK_U9[14]),
    .clkdiv(Div),
    .Clk_CPU(Clk_CPU)
);

// U9
SAnti_jitter U_SAnti_jitter(
    .clk(clk_100mhz),
    .RSTN(RSTN),
    .readn(readn),
    .Key_y(BTN_y),
    .Key_x(BTN_x),
    .SW(SW),
    .Key_out(Key_out),
    .Key_ready(RDY),
    .pulse_out(Pulse),
    .BTN_OK(BTN_OK),
    .SW_OK(SW_OK_U9),
    .CR(CR),
    .rst(rst)
);

// U10
Counter_x U_Counter_x(
    .clk(Clk_CPU_neg),
    .rst(rst),
    .clk0(Div[6]),
    .clk1(Div[9]),
    .clk2(Div[11]),
    .counter_we(counter_we),
    .counter_val(CPU2IO),
    .counter_ch(counter_set),

    .counter0_OUT(counter0_OUT),
    .counter1_OUT(counter1_OUT),
    .counter2_OUT(counter2_OUT),
    .counter_out(counter_out)
);

// M4
SEnter_2_32 U_SEnter_2_32(
    .clk(clk_100mhz),
    .BTN(BTN_OK[2:0]),
    .Ctrl({SW_OK[7:5],1'b0,SW_OK[0]}),
    .D_ready(RDY),
    .Din(Key_out),
    .readn(readn),
    .Ai(Ai),
    .Bi(Bi),
    .blink(blink)
);

endmodule