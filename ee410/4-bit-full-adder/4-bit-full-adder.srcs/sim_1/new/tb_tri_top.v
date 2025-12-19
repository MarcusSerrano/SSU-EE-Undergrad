`timescale 1ns/1ps
// tb_tri_top.v
// Testbench to exercise tri-state behavior: DUT drives SUM_BUS when drive_en=1,
// otherwise bus goes Hi-Z; also models an external device that can drive the bus.
module tb_tri_top;
  localparam integer W = 4;

  // DUT I/O
  reg  [W-1:0] a;
  reg  [W-1:0] b;
  reg          cin;
  reg          drive_en;
  wire [W-1:0] SUM_BUS;
  wire         cout;

  // Instantiate DUT
  tri_top #(.W(W)) dut (
    .a(a),
    .b(b),
    .cin(cin),
    .drive_en(drive_en),
    .SUM_BUS(SUM_BUS),
    .cout(cout)
  );

  // External device model on the same bus (to show contention/ownership)
  reg          ext_drive_en;
  reg  [W-1:0] ext_data;

  // Tri-state driver from the "external world"
  assign SUM_BUS = ext_drive_en ? ext_data : {W{1'bz}};

  // Simple stimulus
  integer i;
  initial begin
    a = 0; b = 0; cin = 0;
    drive_en = 0;
	ext_drive_en = 0; ext_data = {W{1'b0}};

    // Phase 1: DUT owns the bus (drive_en=1), external is Hi-Z
    drive_en = 1;  ext_drive_en = 0;
    for (i = 0; i < 16; i = i + 1) begin
      {cin, b, a} = i[2*W:0]; // limited sweep for demo
      #10;
    end

    // Phase 2: DUT releases bus (Hi-Z), external drives a pattern
    drive_en = 0;  ext_drive_en = 1;  ext_data = 4'hA;
    #50;
    ext_data = 4'h5;
    #50;

    // Phase 3: External releases, DUT drives again
    ext_drive_en = 0; drive_en = 1;
    for (i = 0; i < 16; i = i + 1) begin
      {cin, b, a} = ~i[2*W:0];
      #10;
    end

    $stop;
  end
endmodule
