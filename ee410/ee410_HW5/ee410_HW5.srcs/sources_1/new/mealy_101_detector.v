`timescale 1ns / 1ps

// ------------------------------------------------------------
// Mealy FSM 101 sequence detector
// IOs match Table 7.2:
//   clk : input clock (rising edge)
//   rst : asynchronous reset, active low (0 = reset)
//   x   : serial input bit
//   y   : output high when 101 just detected (overlap allowed)
// ------------------------------------------------------------
module mealy_101_detector (
    input  wire clk,
    input  wire rst,   // asynchronous, active-low
    input  wire x,
    output reg  y
);

    // State encoding
    localparam S0 = 2'b00;  // no useful prefix
    localparam S1 = 2'b01;  // last bit was '1'
    localparam S2 = 2'b10;  // last two bits were '10'

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
    // Next-state and Mealy output logic
    // --------------------------------------------------------
    always @(*) begin
        // Default assignments
        nxt_state = cur_state;
        y         = 1'b0;

        case (cur_state)
            S0: begin
                // No useful prefix yet
                if (x == 1'b1)
                    nxt_state = S1;   // saw first '1'
                else
                    nxt_state = S0;   // stay idle
            end

            S1: begin
                // Last bit was '1'
                if (x == 1'b0)
                    nxt_state = S2;   // now have "10"
                else
                    nxt_state = S1;   // still just '1' as prefix
            end

            S2: begin
                // Last two bits were "10"
                if (x == 1'b1) begin
                    // Now have "101" -> detect
                    nxt_state = S1;   // overlap: last bit is '1'
                    y         = 1'b1; // Mealy output asserted here
                end else begin
                    // "100" -> no useful suffix
                    nxt_state = S0;
                end
            end

            default: begin
                // Defensive default (shouldn't happen)
                nxt_state = S0;
                y         = 1'b0;
            end
        endcase
    end

endmodule
