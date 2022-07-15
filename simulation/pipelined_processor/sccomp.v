`include "SCPU.v"
`include "dm.v"
`include "im.v"

module sccomp(clk, rstn, reg_sel, reg_data); // 结合 SCPU, DM, IM
   input          clk;
   input          rstn;
   input [4:0]    reg_sel;
   output [31:0]  reg_data;
   
   wire [31:0]    instr;
   wire [31:0]    PC;
   wire           MemWrite;
   wire [31:0]    dm_addr, dm_din, dm_dout;
   // wire [2:0]     DMType;
   wire [3:0]     wea;

   wire rst = ~rstn;
   
   SCPU U_SCPU(
      .clk(clk),                 // input:  cpu clock
      .reset(rst),               // input:  reset

      .PC_out(PC),               // output: PC
      .inst_in(instr),           // input:  instruction

      .mem_w(MemWrite),          // output: memory write signal
      .wea(wea),
      .Addr_out(dm_addr),        // output: address from cpu to memory
      .Data_in(dm_dout),         // input:  data to cpu 
      .Data_out(dm_din)          // output: data from cpu to memory
      // .reg_sel(reg_sel),         // input:  register selection
      // .reg_data(reg_data),       // output: register data
      // .DMType(DMType)
   );
   
   dm    U_DM(
      .clka(clk),            // input:  cpu clock
      .addra(dm_addr[9:0]),  // input:  ram address
      .wea(wea),             // input:  ram write
      .dina(dm_din),         // input:  data to ram
      .douta(dm_dout)        // output: data from ram
   );
   
   im    U_IM ( 
      .addr(PC[11:2]),    // input:  rom address
      .dout(instr)        // output: instruction
   );
        
endmodule

