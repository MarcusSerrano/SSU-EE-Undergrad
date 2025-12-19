`timescale 1ns/1ps

// RPIO26=W9 (OUT), RPIO20=A20 (IN). Jumper 37->38 for loopback.
// Top-only I/Os: rst_n (W18), rpio20_in (A20), rpio26_out (W9)
module eqprec_min_io #(
  parameter integer N_CYCLES = 1024,
  parameter integer FREF_HZ  = 125_000_000,  // used in calculation (sim-accurate)
  parameter integer DIV      = 50            // f_out ≈ clk_ref/(2*DIV)
)(
  input  wire rst_n,
  input  wire rpio20_in,
  output wire rpio26_out
);

  // ---------------- Internal reference clock ----------------
  // SIMULATION: precise 125 MHz (8 ns)
  // SYNTHESIS : minimalist ring oscillator buffered to a BUFG
  // (Replace with a PS FCLK/Clocking Wizard later for precise hardware freq.)
  wire clk_ref;

`ifndef SYNTHESIS
  reg clk_sim = 1'b0;
  always #4 clk_sim = ~clk_sim;
  assign clk_ref = clk_sim;
`else
  (* KEEP="TRUE", DONT_TOUCH="TRUE" *) wire ro;
  // Correct Xilinx primitive ports: .I0, .O
  (* KEEP="TRUE", DONT_TOUCH="TRUE" *)
  LUT1 #(.INIT(2'b01)) ro_inv (.O(ro), .I0(ro));
  BUFG bufg_ro (.I(ro), .O(clk_ref));
`endif

  // ---------------- Square-wave generator on RPIO26 ----------------
  reg [31:0] cnt = 0; reg q = 1'b0;
  always @(posedge clk_ref or negedge rst_n) begin
    if (!rst_n) begin cnt <= 0; q <= 1'b0; end
    else if (cnt == DIV-1) begin cnt <= 0; q <= ~q; end
    else cnt <= cnt + 1;
  end
  assign rpio26_out = q;

  // ---------------- Equal-precision frequency meter ----------------
  // Kept internal (no wide buses on pins). Use ILA later if you want to see it.
  wire        valid_int;
  wire [63:0] sig_hz_int;

  eqprec_min #(.N_CYCLES(N_CYCLES), .FREF_HZ(FREF_HZ)) u_meter (
    .clk_ref(clk_ref),
    .rst_n  (rst_n),
    .sig_in (rpio20_in),
    .valid  (valid_int),
    .sig_hz (sig_hz_int)
  );
endmodule


// Minimal calculation core: counts ref cycles over N_CYCLES signal periods
module eqprec_min #(
  parameter integer N_CYCLES = 1024,
  parameter integer FREF_HZ  = 125_000_000
)(
  input  wire        clk_ref,
  input  wire        rst_n,
  input  wire        sig_in,
  output reg         valid,
  output reg [63:0]  sig_hz
);
  reg prev = 1'b0;
  reg [63:0] ref_cnt = 0;
  reg [31:0] cyc_cnt = 0;

  always @(posedge clk_ref or negedge rst_n) begin
    if (!rst_n) begin
      prev<=0; ref_cnt<=0; cyc_cnt<=0; sig_hz<=0; valid<=0;
    end else begin
      prev  <= sig_in;
      valid <= 1'b0;
      ref_cnt <= ref_cnt + 1;
      if (sig_in && !prev) begin
        cyc_cnt <= cyc_cnt + 1;
        if (cyc_cnt == N_CYCLES) begin
          sig_hz  <= (N_CYCLES * FREF_HZ) / ref_cnt;
          ref_cnt <= 0;
          cyc_cnt <= 0;
          valid   <= 1'b1;
        end
      end
    end
  end
endmodule