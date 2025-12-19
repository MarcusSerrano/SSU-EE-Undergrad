// tb_adder_register.v
`timescale 1ns/1ps
module tb_adder_register;
  reg [3:0] a, b;
  reg cin, clk, rst;
  wire [3:0] c;
  wire cout;

  // Instantiate DUT
  adder_register_top dut (
    .a(a), .b(b), .cin(cin),
    .clk(clk), .rst(rst),
    .c(c), .cout(cout)
  );

  // Simple clock: 100 MHz (10 ns period)
  initial clk = 0;
  always #5 clk = ~clk;

  // Stimulus
  initial begin
    // initialize
    a = 0; b = 0; cin = 0; rst = 1;
    #12 rst = 0;  // release reset

    // apply input patterns
    a = 4'h1; b = 4'h2; cin = 0; #10;
    a = 4'h3; b = 4'h4; cin = 0; #10;
    a = 4'h5; b = 4'h6; cin = 1; #10;
    a = 4'hF; b = 4'h1; cin = 0; #10;
    rst = 1; #10; rst = 0;
    a = 4'h9; b = 4'h7; cin = 0; #10;

    $stop;
  end
endmodule
