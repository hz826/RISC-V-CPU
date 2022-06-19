`include "ctrl_encode_def.v"
// data memory
module dm(clk, DMWr, addr, din, dout, DMType);
   input          clk;
   input          DMWr;
   input  [8:0]   addr;
   input  [31:0]  din;
   output [31:0]  dout;

   input [2:0] DMType;
   
   reg [7:0] dmem[511:0];
   
   // always @(posedge clk)
   //    if (DMWr) begin
   //       dmem[addr[8:2]] <= din;
   //      $display("dmem[0x%8X] = 0x%8X,", addr << 2, din); 
   //    end
   
   // assign dout = dmem[addr[8:2]];

   always @(posedge clk) begin
      if(DMWr) begin
         case(DMType)
            `dm_word: begin
               dmem[addr[8:0]]   <= din[ 7: 0];
               dmem[addr[8:0]+1] <= din[15: 8];
               dmem[addr[8:0]+2] <= din[23:16];
               dmem[addr[8:0]+3] <= din[31:24];
               $display("dmem[0x%8X] = 0x%2X,", addr[8:0]+0, din[ 7: 0]);
               $display("dmem[0x%8X] = 0x%2X,", addr[8:0]+1, din[15: 8]);
               $display("dmem[0x%8X] = 0x%2X,", addr[8:0]+2, din[23:16]);
               $display("dmem[0x%8X] = 0x%2X,", addr[8:0]+3, din[31:24]);
            end

            `dm_halfword: begin
               dmem[addr[8:0]]   <= din[ 7: 0];
               dmem[addr[8:0]+1] <= din[15: 8];
               $display("dmem[0x%8X] = 0x%2X,", addr[8:0]+0, din[ 7: 0]);
               $display("dmem[0x%8X] = 0x%2X,", addr[8:0]+1, din[15: 8]);
            end

            `dm_byte: begin
               dmem[addr[8:0]]   <= din[ 7: 0];
               $display("dmem[0x%8X] = 0x%2X,", addr[8:0]+0, din[ 7: 0]);
            end
         endcase
      end 
   end

   reg dout;
   always @(*) begin
      case(DMType)
         `dm_word: begin
            dout <= {dmem[addr[8:0]+3],dmem[addr[8:0]+2],dmem[addr[8:0]+1],dmem[addr[8:0]]}; 
         end
         `dm_halfword: begin
            dout <= {{16{dmem[addr[8:0]+1][7]}},dmem[addr[8:0]+1],dmem[addr[8:0]]};
         end
         `dm_byte: begin
            dout <= {{24{dmem[addr[8:0]][7]}},dmem[addr[8:0]]};
         end
         `dm_halfword_unsigned: begin
            dout <= {16'b0,dmem[addr[8:0]+1],dmem[addr[8:0]]};
         end
         `dm_byte_unsigned: begin
            dout <= {24'b0,dmem[addr[8:0]]};
         end
         default dout <= 32'b0;
      endcase
   end
endmodule    
