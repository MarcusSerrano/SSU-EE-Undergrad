// tb_adder_latch.v
`timescale 1ns/1ps
module tb_adder_latch;
  reg [3:0] a, b;
  reg cin, en, rst;
  wire [3:0] c;
  wire cout;

  adder_latch_top dut (
    .a(a), .b(b), .cin(cin),
    .en(en), .rst(rst),
    .c(c), .cout(cout)
  );

  initial begin
    // Initialize
    a = 0; b = 0; cin = 0; en = 0; rst = 1;
    #10 rst = 0;

    // Drive a few examples
    a = 4'h3; b = 4'h2; cin = 0; en = 1;  #10; // latch sum=5
    en = 0;                                #10; // hold value
    a = 4'h7; b = 4'h8; cin = 1;           #10; // new sum ignored
    en = 1;                                #10; // latch updates
    rst = 1;                               #10; // reset latch
    rst = 0; en = 1; a = 4'hA; b = 4'h5;   #10;
    $stop;
  end
endmodule
