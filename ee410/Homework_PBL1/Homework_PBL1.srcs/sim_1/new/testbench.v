`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2025 07:32:30 PM
// Design Name: 
// Module Name: testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//module testbench;

//  // DUT inputs
//  reg a = 1'b0;
//  reg b = 1'b0;
//  reg c = 1'b0;
//  reg d = 1'b0;

//  // DUT output
//  wire e;

//  // Instantiate DUT
//  Homework_PBL1 uut (
//    .a(a),
//    .b(b),
//    .c(c),
//    .d(d),
//    .e(e)
//  );

//  // Stimulus
//  initial begin
////    $display("  time  a b c d | e");
////    $monitor("%6t  %0d %0d %0d %0d | %0d", $time, a, b, c, d, e);

//    a = 1'b0; b = 1'b0; c = 1'b0; d = 1'b0;
//    #100; a = 1'b1; b = 1'b1; c = 1'b0; d = 1'b1;
//    #100; a = 1'b1; b = 1'b0; c = 1'b1; d = 1'b1;
//    #100; a = 1'b1; b = 1'b0; c = 1'b1; d = 1'b0;

//    #50; $finish;
//  end

//endmodule

module testbench;
  // DUT inputs
  reg a = 1'b0;
  reg b = 1'b0;
  reg c = 1'b0;
  reg d = 1'b0;
  reg en = 1'b0;
  // DUT output
  wire e;
  wire f;
  // Instantiate DUT
  Homework_PBL3 uut (
    .a(a),
    .b(b),
    .c(c),
    .d(d),
    .en(en),
    .e(e),
    .f(f)
  );
  // Stimulus
initial begin
en = 1 'b0; a = 1 'b0; b = 1 'b0; c = 1 'b0; d = 1 'b0;
#10; en = 1 'b0; a = 1 'b1; b = 1 'b1; c = 1 'b1; d = 1 'b1;
#10; en = 1 'b1; a = 1 'b1; b = 1 'b1; c = 1 'b0; d = 1 'b1;
#10; en = 1 'b1; a = 1 'b0; b = 1 'b1; c = 1 'b1; d = 1 'b0;
#10; en = 1 'b1; a = 1 'b1; b = 1 'b0; c = 1 'b1; d = 1 'b1;
#10; en = 1 'b1; a = 1 'b0; b = 1 'b0; c = 1 'b1; d = 1 'b1;

    #10; $finish;
  end

endmodule

