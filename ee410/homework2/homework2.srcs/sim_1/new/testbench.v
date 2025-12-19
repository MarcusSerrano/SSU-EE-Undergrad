`timescale 1ns / 1ps

module testbench;
//DUT inputs
reg a,b,c,d,clk,rst;
//DUT output f.
wire f;
//Instantiate uut
homework2 uut(
.a(a),.b(b),.c(c),.d(d),.clk(clk),.rst(rst),
.f(f)
);
initial begin
rst = 1 'b0; clk = 1 'b0;
a = 1 'b0; b = 1 'b0; c = 1 'b0; d = 1 'b0;
#10 rst = 1 'b1;
#10; a = 1 'b1; b = 1 'b1; c = 1 'b0; d = 1'b0;
#10; a = 1 'b0; b = 1 'b1; c = 1 'b0; d = 1'b1;
#10; a = 1 'b0; b = 1 'b1; c = 1 'b1; d = 1'b1;
#10; a = 1 'b0; b = 1 'b1; c = 1 'b0; d = 1'b1;
end

always #5 clk =~ clk;
endmodule


//`timescale 1ns / 1ps

//module testbench;

////DUT inputs
//reg a,b,c,d,en;

////DUT intermidieary wire e and output f.
//wire f;

////Instantiate uut
//homework2 uut(

//.a(a),.b(b),.c(c),.d(d),.en(en),

//.f(f)

//);
//initial begin
//en = 1 'b0; a = 1 'b0; b = 1 'b0; c = 1 'b0; d = 1 'b0;
//#10; en = 1 'b0; a = 1 'b1; b = 1 'b1; c = 1 'b1; d = 1 'b1;
//#10; en = 1 'b1; a = 1 'b1; b = 1 'b1; c = 1 'b0; d = 1 'b1;
//#10; en = 1 'b1; a = 1 'b0; b = 1 'b1; c = 1 'b1; d = 1 'b1;
//#10; en = 1 'b1; a = 1 'b1; b = 1 'b1; c = 1 'b0; d = 1 'b1;
//end
//endmodule
