// counter_0to9.v
// 4-bit counter: counts 0..9, wraps to 0. Async reset (active-low), enable.
`timescale 1ns/1ps
module counter_0to9(
  input  wire       clk,   // rising edge
  input  wire       rst,   // asynchronous reset, 0 = valid (active-low)
  input  wire       en,    // enable, 1 = count
  output reg  [3:0] cnt    // current count (0..9)
);
  wire [3:0] nxt_cnt = (cnt == 4'd9) ? 4'd0 : (cnt + 4'd1);

  // Async active-low reset; increment on rising edge when enabled
  always @(posedge clk or negedge rst) begin
    if (!rst)
      cnt <= 4'd0;
    else if (en)
      cnt <= nxt_cnt;
  end
endmodule
