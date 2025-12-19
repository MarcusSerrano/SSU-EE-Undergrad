`timescale 1ns / 1ps

//// com_and_or.v
//module com_and_or(input a, input b, input c, input d, output e);
//  assign e = (a & b) | (c & d);
//endmodule

//// seq_and_or.v
//module seq_and_or(input a, input b, input c, input d,
//                  input clk, input rst, output reg f);
//  wire e;
//  com_and_or u1_cmb_and_or(.a(a), .b(b), .c(c), .d(d), .e(e));

//  always @(posedge clk or negedge rst)
//    if (!rst)
//      f <= 0;
//    else
//      f <= e;
//endmodule

// com_and_or.v  (reused submodule)
module com_and_or(input a, input b, input c, input d, output e);
  assign e = (a & b) | (c & d);
endmodule

// seq_inst_and_or.v  (two submodules, one-bit adder, three registers)
module seq_inst_and_or(
  input  a, b, c, d, e, f, g,
  input  clk, rst,           // async active-low reset, posedge clock
  output reg n
);
  // submodule #1 and its register
  wire h;
  reg  j;
  com_and_or u1_cmb_and_or(.a(a), .b(b), .c(c), .d(d), .e(h));
  always @(posedge clk or negedge rst)
    if (!rst) j <= 1'b0; else j <= h;

  // submodule #2; one input comes from a registered feedback
  reg  k;
  wire l;
  com_and_or u2_cmb_and_or(.a(e), .b(f), .c(g), .d(k), .e(l));
  always @(posedge clk or negedge rst)
    if (!rst) k <= 1'b0; else k <= n;  // simple feedback register

  // 1-bit adder (sum only)
  wire m;
  assign m = j + l;  // half-adder sum (LSB of j+l)

  // final register
  always @(posedge clk or negedge rst)
    if (!rst) n <= 1'b0; else n <= m;
endmodule

