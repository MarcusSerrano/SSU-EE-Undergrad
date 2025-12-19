// adder.v
// Parameterized vector-based adder suitable for reuse
`timescale 1ns/1ps
module adder #(
  parameter integer W = 4
)(
  input  wire [W-1:0] a,
  input  wire [W-1:0] b,
  input  wire         cin,
  output wire [W-1:0] sum,
  output wire         cout
);
  // Simple vector addition
  assign {cout, sum} = a + b + cin;
endmodule