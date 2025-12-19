`timescale 1ns/1ps
// tri_top.v
// Top-level that instantiates the vector adder and exposes its sum on a tri-stated bus.
module tri_top #(
  parameter integer W = 4
)(
  input  wire [W-1:0] a,
  input  wire [W-1:0] b,
  input  wire         cin,
  input  wire         drive_en,   // 1 = drive bus with sum, 0 = Hi-Z
  inout  wire [W-1:0] SUM_BUS,    // tri-stated bus (top-level I/O in hardware)
  output wire         cout
);
  wire [W-1:0] sum;

  // Reusable vector adder
  adder #(.W(W)) u_add (
    .a(a),
    .b(b),
    .cin(cin),
    .sum(sum),
    .cout(cout)
  );

  // Behavioral tri-state (maps to real IOB tri-state in hardware)
  assign SUM_BUS = drive_en ? sum : {W{1'bz}};

endmodule
