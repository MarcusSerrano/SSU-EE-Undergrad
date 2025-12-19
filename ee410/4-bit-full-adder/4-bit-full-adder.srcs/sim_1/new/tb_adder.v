`timescale 1ns/1ps
// tb_adder_vec_nocheck.v
// Simple testbench for parameterized adder: sweeps all input combinations without checks
module tb_adder;

  // Parameters
  localparam integer W = 4;

  // DUT inputs
  reg  [W-1:0] a;
  reg  [W-1:0] b;
  reg          cin;

  // DUT outputs
  wire [W-1:0] sum;
  wire         cout;

  integer i;

  // Instantiate DUT
  adder #(.W(W)) dut (
    .a(a),
    .b(b),
    .cin(cin),
    .sum(sum),
    .cout(cout)
  );

  // Sweep all combinations
  initial begin
    for (i = 0; i < (1 << (2*W + 1)); i = i + 1) begin
      {cin, b, a} = i[2*W:0];   // [cin][b][a]
      #10; // delay between vectors
    end
    $stop;
  end

endmodule
