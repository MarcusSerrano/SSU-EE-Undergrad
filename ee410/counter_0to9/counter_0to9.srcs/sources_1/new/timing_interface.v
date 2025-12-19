// timing_interface.v — PBL15 Timing Interface
// Reuses a 0.1us timer (0..9). sig=1 for tim 0..3 and 6..9.
`timescale 1ns/1ps
module timing_interface(
  input  wire clk,   // 100 MHz
  input  wire rst,   // async reset, 0-valid
  input  wire en,    // enable
  output wire sig    // timing pulse per spec
);
  wire [3:0] tim;

  // Reuse your PBL14 timer (unit = 0.1us, counts 0..9 and wraps)
  timer_0to9 u_timer (
    .clk(clk), .rst(rst), .en(en), .tim(tim)
  );

  // Comparators per spec: tim < 4  OR  tim >= 6
  assign sig = (tim <= 4'd3) | (tim >= 4'd6);

endmodule
