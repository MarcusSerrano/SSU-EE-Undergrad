`timescale 1ns/1ps
module tb_timing_controller;
  reg        clk, rst, en;
  reg  [7:0] a, b, c, d;
  wire [7:0] g;
  wire       finish;

  timing_controller dut (
    .clk(clk), .rst(rst), .en(en),
    .a(a), .b(b), .c(c), .d(d),
    .g(g), .finish(finish)
  );

  // 100 MHz clock (10 ns)
  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    // Reset
    rst = 1'b0; en = 1'b0; a=0; b=0; c=0; d=0;
    #12 rst = 1'b1;

    // Transaction 1
    a=8'd3; b=8'd4; c=8'd2; d=8'd5;  // g = ((3+4)*2)*5 = 70 (truncated to 8b)
    en = 1'b1; #10; en = 1'b0;       // pulse start
    // g becomes valid 3 clocks later; finish pulses with it

    // Idle a bit
    #60;

    // Transaction 2
    a=8'd1; b=8'd2; c=8'd3; d=8'd4;
    en = 1'b1; #10; en = 1'b0;

    #100;
    $stop;
  end
endmodule
