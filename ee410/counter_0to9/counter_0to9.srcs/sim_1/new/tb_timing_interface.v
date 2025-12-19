`timescale 1ns/1ps
module tb_timing_interface;
  reg clk, rst, en;
  wire sig;

  timing_interface dut (.clk(clk), .rst(rst), .en(en), .sig(sig));

  // 100 MHz clock (10 ns)
  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    // hold reset, then enable
    rst = 1'b0; en = 1'b0; #12;
    rst = 1'b1; en = 1'b1;

    // run long enough to see multiple 0..9 periods (each is 1.0us)
    #2500;

    // pause and pulse reset to observe restart behavior
    en = 1'b0; #50;
    rst = 1'b0; #20; rst = 1'b1; #20;
    en = 1'b1; #1000;

    $stop;
  end
endmodule
