// timer_0to9.v — top-level timer per PBL14 I/O (clk,rst,en,tim)
`timescale 1ns/1ps
module timer_0to9(
  input  wire clk,       // 100 MHz
  input  wire rst,       // async, active-low
  input  wire en,        // enable timer
  output reg  [3:0] tim  // 0..9, steps every 10 cycles
);
  wire [3:0] prescale_cnt;
  wire       tick;

  mod10_tick u_ps (
    .clk(clk), .rst(rst), .en(en),
    .cnt(prescale_cnt), .tick(tick)
  );

  always @(posedge clk or negedge rst) begin
    if (!rst)        tim <= 4'd0;
    else if (en)     tim <= (tick ? (tim == 4'd9 ? 4'd0 : tim + 4'd1) : tim);
  end
endmodule
