`include "ctrl_encode_def.v"

module dm(
   input         clk,
   input  [9:0]  addr,
   input  [3:0]  wea,
   input  [31:0] din, 
   output [31:0] dout
);
   reg  [31:0] dmem[1024:0];
   wire [31:0] mask;
   wire [31:0] write;

   assign mask = {{8{wea[3]}},{8{wea[2]}},{8{wea[1]}},{8{wea[0]}}};
   assign write = (dmem[addr] & (~mask)) | (din & mask);

   always @(posedge clk) begin
      // $display("%h %h", wea, addr);
      if (wea != 4'b0000) begin
         dmem[addr] = write;
         $display("dmem[%h] = %h,", addr, dmem[addr]);
      end
   end

   assign dout = dmem[addr];
endmodule