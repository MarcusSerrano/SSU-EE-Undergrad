`timescale 1ns/1ps

module homework2(
  input  wire a,
  input  wire b,
  input  wire c,
  input  wire d,
  input  wire clk,   
  input  wire rst,   
  output reg  f      
);
  // Combinational AND-OR
  wire e = (a & b) | (c & d);

  // Edge-triggered register with async reset
  always @(posedge clk or negedge rst) begin
      f <= e;     // sample e 
  end
endmodule


//module homework2(
////declare inputs
//input wire a,
//input wire b,
//input wire c,
//input wire d,
//input wire en,
////outputs
//output reg f
//    );
//    wire e;
//    //instantiation
    
//    //logic for e
//    assign e = (a&b)|(c&d);
    
//    //latch
//    always @(e or en) begin
//    if (en) begin
//      f <= e; // If en is high, latch the data input
//    end
//    // If en is low, f retains its previous value (latch behavior)
//  end
//endmodule
