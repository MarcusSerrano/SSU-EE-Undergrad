// tb_timer_0to9.v
`timescale 1ns/1ps
module tb_timer_0to9;
  reg clk, rst, en;
  wire [3:0] tim;

  timer_0to9 dut (.clk(clk), .rst(rst), .en(en), .tim(tim));

  // 100 MHz clock
  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    rst = 1'b0; en = 1'b0;          // hold in reset
    #12; rst = 1'b1; en = 1'b1;     // release, start
    #1200;                          // run long enough to see several 0..9 steps
    en = 1'b0; #100;                // pause
    rst = 1'b0; #20; rst = 1'b1;    // async clear
    en = 1'b1; #400;
    $stop;
  end
endmodule
