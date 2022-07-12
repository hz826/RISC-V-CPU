module dm(clka, wea, addra, dina, douta);
   input          clka;
   input  [3:0]   wea;
   input  [9:0]   addra;
   input  [31:0]  dina;
   output [31:0]  douta;

   reg [7:0] dmem[1023:0];
   
   wire [9:0] ar;
   assign ar=addra;

   wire debug = 1'b0;

   always @(posedge clka)
      if(wea!=0) begin
         if((wea&(4'b0001))!=0) begin
            dmem[ar+0]   = dina[ 7: 0];
            if (debug) $display("dmem[0x%8X] = 0x%2X,", ar+0, dina[ 7: 0]);
         end
         
         if((wea&(4'b0010))!=0) begin
            dmem[ar+1]   = dina[15: 8];
            if (debug) $display("dmem[0x%8X] = 0x%2X,", ar+1, dina[15: 8]);
         end

         if((wea&(4'b0100))!=0) begin
            dmem[ar+2]   = dina[23:16];
            if (debug) $display("dmem[0x%8X] = 0x%2X,", ar+2, dina[23:16]);
         end

         if((wea&(4'b1000))!=0) begin
            dmem[ar+3]   = dina[31:24];
            if (debug) $display("dmem[0x%8X] = 0x%2X,", ar+3, dina[31:24]);
         end
      end 

   reg [31:0] dout;
   always @(*) begin
      dout <= {dmem[ar+3],dmem[ar+2],dmem[ar+1],dmem[ar+0]};
   end
   assign douta=dout;
    
endmodule