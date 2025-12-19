// mod10_tick.v — prescaler: tick every 10 clocks
`timescale 1ns/1ps
module mod10_tick(
  input  wire clk,
  input  wire rst,   // async, active-low
  input  wire en,    // enable counting
  output reg  [3:0] cnt,   // optional visibility (0..9)
  output wire       tick   // 1 for one clk when cnt==9
);
  assign tick = (cnt == 4'd9);

  always @(posedge clk or negedge rst) begin
    if (!rst)      cnt <= 4'd0;
    else if (en)   cnt <= tick ? 4'd0 : cnt + 4'd1;
  end
endmodule
