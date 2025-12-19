// adder_latch_top.v
`timescale 1ns/1ps
module adder_latch_top(
  input  wire [3:0] a,
  input  wire [3:0] b,
  input  wire       cin,
  input  wire       en,    // latch enable
  input  wire       rst,   // reset
  output reg  [3:0] c,     // latched output
  output wire       cout
);
  wire [3:0] sum;

  // Use your parameterized adder
  adder #(.W(4)) u_add (
    .a(a),
    .b(b),
    .cin(cin),
    .sum(sum),
    .cout(cout)
  );

  // Simple level-sensitive latch
  always @(*) begin
    if (rst)
      c = 4'b0000;
    else if (en)
      c = sum;
  end

endmodule
