`timescale 1ns/1ps
module tb_min;

  reg  rst_n = 1'b0;
  wire rpio26_out;
  wire rpio20_in;

  // Loopback (like jumper 37->38 on the board)
  assign rpio20_in = rpio26_out;

  // DUT uses an internal clock (sim=125 MHz; synth=internal RO)
  eqprec_min_io #(
    .N_CYCLES(1024),
    .FREF_HZ (125_000_000),
    .DIV     (50)
  ) u_dut (
    .rst_n     (rst_n),
    .rpio20_in (rpio20_in),
    .rpio26_out(rpio26_out)
  );

  initial begin
    rst_n = 1'b0; #100; rst_n = 1'b1;   // release reset
    #4_000_000; $finish;                // run ~4 ms
  end
endmodule