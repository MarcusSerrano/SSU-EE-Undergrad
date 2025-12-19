// adder_register_top.v
`timescale 1ns/1ps
module adder_register_top(
  input  wire [3:0] a,
  input  wire [3:0] b,
  input  wire       cin,
  input  wire       clk,
  input  wire       rst,
  output reg  [3:0] c,
  output wire       cout
);
  wire [3:0] sum;

  // Instantiate the reusable adder
  adder #(.W(4)) u_add (
    .a(a),
    .b(b),
    .cin(cin),
    .sum(sum),
    .cout(cout)
  );

  // Simple synchronous register with reset
  always @(posedge clk) begin
    if (rst)
      c <= 4'b0000;
    else
      c <= sum;
  end

endmodule
