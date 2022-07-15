module im(
    input  [9:0]  addr,
    output [31:0] dout
);
    reg  [31:0] ROM[1024:0];
    assign dout = ROM[addr]; // word aligned
endmodule