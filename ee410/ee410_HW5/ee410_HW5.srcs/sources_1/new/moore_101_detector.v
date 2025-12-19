`timescale 1ns / 1ps

// ------------------------------------------------------------
// Moore FSM 101 sequence detector
// IOs match Table 7.2:
//   clk : input clock (rising edge)
//   rst : asynchronous reset, active low (0 = reset)
//   x   : serial input bit
//   y   : output high when in "101 detected" state (overlap allowed)
// ------------------------------------------------------------
module moore_101_detector (
    input  wire clk,
    input  wire rst,   // asynchronous, active-low
    input  wire x,
    output reg  y
);

    // State encoding
    localparam S0 = 2'b00;  // no useful prefix
    localparam S1 = 2'b01;  // last bit was '1'
    localparam S2 = 2'b10;  // last two bits were '10'
    localparam S3 = 2'b11;  // "101" detected

    reg [1:0] cur_state, nxt_state;

    // --------------------------------------------------------
    // State register with asynchronous active-low reset
    // --------------------------------------------------------
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            cur_state <= S0;
        end else begin
            cur_state <= nxt_state;
        end
    end

    // --------------------------------------------------------
    // Next-state logic (depends on current state and x)
    // --------------------------------------------------------
    always @(*) begin
        nxt_state = cur_state;

        case (cur_state)
            S0: begin
                // No useful prefix yet
                if (x == 1'b1)
                    nxt_state = S1;
                else
                    nxt_state = S0;
            end

            S1: begin
                // Last bit was '1'
                if (x == 1'b0)
                    nxt_state = S2;   // have "10"
                else
                    nxt_state = S1;   // still just '1'
            end

            S2: begin
                // Last two bits were "10"
                if (x == 1'b1)
                    nxt_state = S3;   // have "101"
                else
                    nxt_state = S0;   // "100" -> no useful suffix
            end

            S3: begin
                // State that represents "101" recognized
                // Consider new incoming bit for overlapping
                if (x == 1'b0)
                    nxt_state = S2;   // last two bits become "10"
                else
                    nxt_state = S1;   // last bit becomes "1"
            end

            default: begin
                nxt_state = S0;
            end
        endcase
    end

    // --------------------------------------------------------
    // Moore output logic: depends ONLY on current state
    // --------------------------------------------------------
    always @(*) begin
        case (cur_state)
            S3:  y = 1'b1;   // "101" detected
            default: y = 1'b0;
        endcase
    end

endmodule
