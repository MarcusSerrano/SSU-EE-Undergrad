// timing_controller.v — PBL16
// Datapath: g = ((a + b) * c) * d
// Controller: 2-bit stage counter sequences three pipeline steps.
// Assumptions per spec: 8-bit ops; ignore overflow/truncate to 8b. 
`timescale 1ns/1ps
module timing_controller(
  input  wire        clk,     // 100 MHz
  input  wire        rst,     // async reset, 0 = valid
  input  wire        en,      // start processing (assert for >=1 cycle)
  input  wire [7:0]  a, b, c, d,
  output reg  [7:0]  g,       // final 8-bit result
  output reg         finish   // 1 for one cycle when g becomes valid
);

  // Latch inputs at start so they don't change mid-pipeline
  reg [7:0] a_r, b_r, c_r, d_r;

  // Pipeline registers between stages
  reg [7:0] e_reg; // after ADD
  reg [7:0] f_reg; // after MUL1

  // Controller
  reg       busy;
  reg [1:0] stage; // 0,1,2,3; finish when stage==3

  // Async reset, then simple 4-state sequence
  always @(posedge clk or negedge rst) begin
    if (!rst) begin
      a_r <= 8'd0; b_r <= 8'd0; c_r <= 8'd0; d_r <= 8'd0;
      e_reg <= 8'd0; f_reg <= 8'd0; g <= 8'd0;
      stage <= 2'd0; busy <= 1'b0; finish <= 1'b0;
    end else begin
      finish <= 1'b0;  // default

      // Start a new transaction when en=1 and not busy
      if (en && !busy) begin
        a_r <= a; b_r <= b; c_r <= c; d_r <= d;
        stage <= 2'd0;
        busy  <= 1'b1;
      end else if (busy) begin
        case (stage)
          2'd0: begin
            e_reg <= a_r + b_r;  // ADD stage
            stage <= 2'd1;
          end
          2'd1: begin
            f_reg <= e_reg * c_r; // MUL1 stage (truncated to 8b)
            stage <= 2'd2;
          end
          2'd2: begin
            g      <= f_reg * d_r; // MUL2 stage → g valid now
            stage  <= 2'd3;
            finish <= 1'b1;        // assert with final valid (vld3)
          end
          default: begin
            // one-cycle tail; go idle and wait for next en
            busy  <= 1'b0;
            stage <= 2'd0;
          end
        endcase
      end
    end
  end
endmodule
