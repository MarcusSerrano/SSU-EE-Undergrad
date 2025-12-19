`timescale 1ns / 1ps

//// tb_com_and_or.v (bare minimum for Vivado simulation)
//module tb;
//  reg a, b, c, d;
//  wire e;

//  com_and_or dut(.a(a), .b(b), .c(c), .d(d), .e(e));

//  integer i;
//  initial begin
//    for (i = 0; i < 16; i = i + 1) begin
//      {a, b, c, d} = i;
      
//    end
//    $finish;
//  end
//endmodule

//// tb_seq_and_or.v (bare minimum for Vivado)
//module tb;
//  reg a, b, c, d, clk, rst;
//  wire f;

//  seq_and_or dut(.a(a), .b(b), .c(c), .d(d), .clk(clk), .rst(rst), .f(f));

//  initial begin
//    clk = 0;
//    forever #5 clk = ~clk;
//  end

//  integer i;
//  initial begin
//    rst = 0; #10; rst = 1;
//    for (i = 0; i < 16; i = i + 1) begin
//      {a, b, c, d} = i;
//      #10;
//    end
//    $finish;
//  end
//endmodule


// tb_seq_inst_and_or.v  (bare minimum for Vivado)
module tb;
  reg a,b,c,d,e,f,g, clk, rst;
  wire n;

  seq_inst_and_or dut(.a(a),.b(b),.c(c),.d(d),.e(e),.f(f),.g(g),
                      .clk(clk),.rst(rst),.n(n));

  // clock
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  integer i;
  initial begin
    // reset
    rst = 1'b0; a=0;b=0;c=0;d=0;e=0;f=0;g=0;
    #12 rst = 1'b1;

    // 128 combinations of a..g
    for (i = 0; i < 128; i = i + 1) begin
      {a,b,c,d,e,f,g} = i[6:0];
      @(posedge clk);
    end
    $finish;
  end
endmodule