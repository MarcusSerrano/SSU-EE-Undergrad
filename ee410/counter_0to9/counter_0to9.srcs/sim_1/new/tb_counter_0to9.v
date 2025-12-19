// tb_counter_0to9.v
`timescale 1ns/1ps
module tb_counter_0to9;
  reg clk, rst, en;
  wire [3:0] cnt;

  // DUT
  counter_0to9 dut (
    .clk(clk),
    .rst(rst),
    .en(en),
    .cnt(cnt)
  );

  // 100 MHz clock (10 ns period)
  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    // Initial conditions
    rst = 1'b0;  // assert reset (active-low)
    en  = 1'b0;
    #12;
    rst = 1'b1;  // release reset
    en  = 1'b1;  // start counting

    #200;

    // Hold count (en=0), then pulse reset low
    en = 1'b0;  #40;
    rst = 1'b0; #20;  // async clear
    rst = 1'b1; #20;
    en  = 1'b1; #100;

    $stop;
  end
endmodule
