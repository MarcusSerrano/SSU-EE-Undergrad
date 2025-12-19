// top_xadc_temp.v
//
// XADC on-chip temperature to PmodSSD display
// Target: Pynq-Z2 (xc7z020clg400-1)
//
// Top-level ports (match pynq_z2_pmodssd.xdc):
//   clk_125mhz : 125 MHz board clock
//   btn_reset  : pushbutton reset (active high)
//   led[3:0]   : user LEDs
//   ja[3:0]    : Pmod JA (segments A..D)
//   jb[3:0]    : Pmod JB (segments E,F,G + digit select C)
//
// The design:
//   * Reads on-chip temperature from XADC in default System Monitor mode
//   * Averages many samples to reduce jitter
//   * Converts to approximate °C (integer 0–99)
//   * Converts that to BCD and drives pmodssd_display.v

`timescale 1ns / 1ps

module top_xadc_temp (
    input  wire        clk_125mhz,
    input  wire        btn_reset,
    output wire [3:0]  led,
    output wire [3:0]  ja,
    output wire [3:0]  jb
);

    // --------------------------------------------------------------------
    // Reset (synchronous, de-bounced with shift register)
    // --------------------------------------------------------------------
    reg [3:0] rst_sync = 4'hF;
    always @(posedge clk_125mhz or posedge btn_reset) begin
        if (btn_reset) begin
            rst_sync <= 4'hF;
        end else begin
            rst_sync <= {rst_sync[2:0], 1'b0};
        end
    end
    wire rst = rst_sync[3];

    // --------------------------------------------------------------------
    // XADC primitive in default System Monitor configuration
    // --------------------------------------------------------------------
    // We leave most INIT_* registers at their default reset values.
    // We continuously read the temperature status register at address 0x00
    // by tying DEN to EOC.

    wire [15:0] xadc_do;
    wire        xadc_drdy;
    wire        xadc_eoc;
    wire        xadc_busy;
    wire [4:0]  xadc_channel;
    wire        xadc_eos;

    XADC #(
        // Leave configuration mostly at defaults
        .INIT_40(16'h0000),
        .INIT_41(16'h0000),
        .INIT_42(16'h0800),
        .INIT_48(16'h0000),
        .INIT_49(16'h0000),
        .INIT_4A(16'h0000),
        .INIT_4B(16'h0000),
        .INIT_4C(16'h0000),
        .INIT_4D(16'h0000),
        .INIT_4E(16'h0000),
        .INIT_4F(16'h0000),
        // Alarms unused
        .INIT_50(16'h0000),
        .INIT_51(16'h0000),
        .INIT_52(16'h0000),
        .INIT_53(16'h0000),
        .INIT_54(16'h0000),
        .INIT_55(16'h0000),
        .INIT_56(16'h0000),
        .INIT_57(16'h0000),
        .INIT_58(16'h0000),
        .INIT_5C(16'h0000),
        .SIM_DEVICE("ZYNQ"),
        .SIM_MONITOR_FILE("design.txt")
    ) u_xadc (
        .DADDR   (7'h00),          // temperature status register
        .DCLK    (clk_125mhz),
        .DEN     (xadc_eoc),       // pulse DRP enable at end-of-conversion
        .DI      (16'h0000),
        .DWE     (1'b0),
        .RESET   (rst),
        .VP      (), .VN(),
        .ALM     (), .OT(),
        .MUXADDR (),
        .CHANNEL (xadc_channel),
        .DO      (xadc_do),
        .DRDY    (xadc_drdy),
        .BUSY    (xadc_busy),
        .EOC     (xadc_eoc),
        .EOS     (xadc_eos),
        .JTAGBUSY(), .JTAGLOCKED(), .JTAGMODIFIED()
    );

    // --------------------------------------------------------------------
    // Capture 12-bit temperature sample (bits [15:4] of DO)
    // --------------------------------------------------------------------
    reg [11:0] temp_sample = 12'd0;

    always @(posedge clk_125mhz) begin
        if (rst) begin
            temp_sample <= 12'd0;
        end else if (xadc_drdy) begin
            temp_sample <= xadc_do[15:4];
        end
    end

    // --------------------------------------------------------------------
    // Average many samples to reduce jitter
    // --------------------------------------------------------------------
    // Simple boxcar average over 256 samples:
    //   temp_filtered <= (sum of 256 samples) / 256
    // This greatly smooths the reading so the ones digit doesn't dance.

    reg [23:0] sample_accum   = 24'd0;
    reg [7:0]  sample_count   = 8'd0;
    reg [11:0] temp_filtered  = 12'd0;

    always @(posedge clk_125mhz) begin
        if (rst) begin
            sample_accum  <= 24'd0;
            sample_count  <= 8'd0;
            temp_filtered <= 12'd0;
        end else if (xadc_drdy) begin
            sample_accum <= sample_accum + temp_sample;
            sample_count <= sample_count + 1'b1;

            if (sample_count == 8'd255) begin
                // divide by 256 (>> 8)
                temp_filtered <= sample_accum[23:12];
                sample_accum  <= 24'd0;
                sample_count  <= 8'd0;
            end
        end
    end

    // --------------------------------------------------------------------
    // Convert raw XADC temperature code to integer degrees Celsius
    // --------------------------------------------------------------------
    // From Xilinx docs (UG480):
    //   T(K)  ≈ temp_code * 503.975 / 4096
    //   T(°C) ≈ T(K) - 273.15
    //
    // Approximation:
    //   T(°C) ≈ (temp_filtered * 504 >> 12) - 273
    // Clamp result to 0..99 for display.

    reg  [27:0] mult_result;
    reg  [15:0] temp_c_calc;
    reg  [6:0]  temp_c_clamped;

    always @(posedge clk_125mhz) begin
        if (rst) begin
            mult_result    <= 28'd0;
            temp_c_calc    <= 16'd0;
            temp_c_clamped <= 7'd0;
        end else begin
            mult_result <= temp_filtered * 16'd504;
            temp_c_calc <= (mult_result >> 12); // divide by 4096

            if (temp_c_calc <= 16'd273)
                temp_c_clamped <= 7'd0;
            else if (temp_c_calc - 16'd273 >= 16'd99)
                temp_c_clamped <= 7'd99;
            else
                temp_c_clamped <= temp_c_calc[15:0] - 16'd273;
        end
    end

    // --------------------------------------------------------------------
    // Convert integer temperature 0..99 to BCD (tens & ones)
    // --------------------------------------------------------------------
    reg [3:0] tens = 4'd0;
    reg [3:0] ones = 4'd0;

    always @(posedge clk_125mhz) begin
        if (rst) begin
            tens <= 4'd0;
            ones <= 4'd0;
        end else begin
            tens <= temp_c_clamped / 10;
            ones <= temp_c_clamped % 10;
        end
    end

    wire [7:0] temp_bcd = {tens, ones};

    // --------------------------------------------------------------------
    // Drive PmodSSD via pmodssd_display.v
    // --------------------------------------------------------------------
    wire [6:0] seg;
    wire       digit_sel;

    pmodssd_display u_pmodssd (
        .clk       (clk_125mhz),
        .rst       (rst),
        .bcd_value (temp_bcd),
        .seg       (seg),
        .digit_sel (digit_sel)
    );

    // Map seg / digit_sel to Pmod pins:
    // seg = {A,B,C,D,E,F,G}
    // JA[3:0] -> A..D, JB[0:2] -> E,F,G, JB[3] -> digit select C

    assign ja[0] = seg[6]; // A
    assign ja[1] = seg[5]; // B
    assign ja[2] = seg[4]; // C
    assign ja[3] = seg[3]; // D

    assign jb[0] = seg[2];    // E
    assign jb[1] = seg[1];    // F
    assign jb[2] = seg[0];    // G
    assign jb[3] = digit_sel; // digit select C

    // --------------------------------------------------------------------
    // LED debug: show upper bits of filtered temp code
    // --------------------------------------------------------------------
    assign led = temp_filtered[11:8];

endmodule
