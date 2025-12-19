// pmodssd_display.v
//
// Drives a Digilent PmodSSD (Rev A) two-digit seven-seg display.
//
// bcd_value[3:0]  = ones digit (0–9)
// bcd_value[7:4]  = tens digit (0–9)
//
// Outputs:
//   seg[6:0]  = segments A..G (active-high)
//              seg[6] = A, seg[0] = G
//   digit_sel = digit select C pin:
//               0 -> first digit (e.g., left)
//               1 -> second digit (e.g., right)
//
// Internally, we time-multiplex the digits at ~2 kHz total
// (about 1 kHz per digit), which is fast enough that the
// display appears steady to the eye.

`timescale 1ns / 1ps

module pmodssd_display (
    input  wire        clk,
    input  wire        rst,
    input  wire [7:0]  bcd_value,
    output reg  [6:0]  seg,
    output wire        digit_sel
);

    // --------------------------------------------------------------------
    // Refresh counter for digit multiplexing
    // --------------------------------------------------------------------
    // Using bit 15 as the digit select:
    //   refresh_counter[15] toggles at clk / 2^16
    // For a 125 MHz clock: 125e6 / 2^16 ≈ 1.9 kHz
    // => each digit ~950 Hz (no visible flicker).

    reg [15:0] refresh_counter = 16'd0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            refresh_counter <= 16'd0;
        end else begin
            refresh_counter <= refresh_counter + 1'b1;
        end
    end

    assign digit_sel = refresh_counter[15];

    // --------------------------------------------------------------------
    // Select which BCD digit to display based on digit_sel
    // --------------------------------------------------------------------
    wire [3:0] ones_digit = bcd_value[3:0];
    wire [3:0] tens_digit = bcd_value[7:4];

    reg [3:0] current_digit;

    always @* begin
        if (digit_sel == 1'b0)
            current_digit = ones_digit; // first digit
        else
            current_digit = tens_digit; // second digit
    end

    // --------------------------------------------------------------------
    // BCD to seven-segment decoder (active-high, A..G)
    // --------------------------------------------------------------------
    always @* begin
        case (current_digit)
            4'd0: seg = 7'b1111110; // 0
            4'd1: seg = 7'b0110000; // 1
            4'd2: seg = 7'b1101101; // 2
            4'd3: seg = 7'b1111001; // 3
            4'd4: seg = 7'b0110011; // 4
            4'd5: seg = 7'b1011011; // 5
            4'd6: seg = 7'b1011111; // 6
            4'd7: seg = 7'b1110000; // 7
            4'd8: seg = 7'b1111111; // 8
            4'd9: seg = 7'b1111011; // 9
            default: seg = 7'b0000000; // all off
        endcase
    end

endmodule
