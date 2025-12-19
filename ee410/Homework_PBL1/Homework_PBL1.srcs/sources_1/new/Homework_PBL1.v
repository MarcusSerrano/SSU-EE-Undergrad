`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2025 07:25:04 PM
// Design Name: 
// Module Name: Homework_PBL1
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


//module Homework_PBL1(
//    input wire a,
//    input wire b,
//    input wire c,
//    input wire d,
//    output wire e
//    );
//    assign e = (a&b)|(c&d);
    
    
//endmodule

//module Homework_PBL2(
//    input wire a,
//    input wire b,
//    input wire c,
//    input wire d,
//    input wire sel,
//    output reg e
//    );
    
//    always @(*) begin
//    if (sel == 1)
//    e = (c & d);
//    else
//    e = (a & b);
//    end
//endmodule

module Homework_PBL3(
    input wire a,
    input wire b,
    input wire c,
    input wire d,
    input wire en,
    output reg e,
    output reg f
    );
    
    always @(*) begin
    e = (a&b)|(c&d);
    if (en == 1)
    f = ~e;
    else
    f = e;
    end
    endmodule