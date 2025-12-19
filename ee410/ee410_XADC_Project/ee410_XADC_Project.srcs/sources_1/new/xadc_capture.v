// xadc_capture.v
// Simple XADC capture module using XADC Wizard IP (xadc_wiz_0).
//
// - Assumes the XADC Wizard is configured to continuously sample
//   the on-chip temperature sensor.
// - This module uses the DRP port to read status register 0x00,
//   which holds the latest temperature measurement.
// - Outputs a 12-bit temperature code and a 1-cycle valid strobe.

module xadc_capture (
    input  wire        clk,        // system clock fed to XADC DRP (e.g., 25 MHz)
    input  wire        rst,        // active-high synchronous reset

    output reg  [11:0] temp_code,  // raw 12-bit temperature code
    output reg         temp_valid  // pulses high for 1 clk when new code is captured
);

    // DRP interface signals
    reg  [15:0] di_reg;
    reg  [6:0]  daddr_reg;
    reg         den_reg;
    reg         dwe_reg;

    wire [15:0] do_wire;
    wire        drdy_wire;

    // Unused status signals
    wire        user_temp_alarm;
    wire        ot_alarm;
    wire [4:0]  channel_out;
    wire        eoc_out;
    wire        any_alarm;
    wire        eos_out;
    wire        busy_out;

    // --------------------------------------------------------------------
    // XADC Wizard IP instance
    // --------------------------------------------------------------------
    // Create this IP in Vivado with the name "xadc_wiz_0" and enable:
    //  - On-chip temperature sensor
    //  - DRP interface
    //  - Continuous sequencing mode (so status register 0x00 updates)
    //
    xadc_wiz_0 u_xadc_wiz_0 (
        .di_in              (di_reg),
        .daddr_in           (daddr_reg),
        .den_in             (den_reg),
        .dwe_in             (dwe_reg),
        .drdy_out           (drdy_wire),
        .do_out             (do_wire),
        .dclk_in            (clk),
        .reset_in           (rst),
        .vp_in              (1'b0),
        .vn_in              (1'b0),
        .user_temp_alarm_out(user_temp_alarm),
        .ot_out             (ot_alarm),
        .channel_out        (channel_out),
        .eoc_out            (eoc_out),
        .alarm_out          (any_alarm),
        .eos_out            (eos_out),
        .busy_out           (busy_out)
    );

    // --------------------------------------------------------------------
    // Simple DRP read state machine
    //
    // Continuously reads status register 0x00 (temperature).
    // Whenever DRDY asserts, we latch do_wire[15:4] as the 12-bit code.
    // --------------------------------------------------------------------
    localparam S_IDLE     = 2'd0;
    localparam S_READ     = 2'd1;
    localparam S_WAITDRDY = 2'd2;

    reg [1:0] state;

    always @(posedge clk) begin
        if (rst) begin
            state      <= S_IDLE;
            di_reg     <= 16'h0000;
            daddr_reg  <= 7'h00;
            den_reg    <= 1'b0;
            dwe_reg    <= 1'b0;
            temp_code  <= 12'd0;
            temp_valid <= 1'b0;
        end else begin
            // Default: no new sample this cycle
            temp_valid <= 1'b0;

            case (state)
                S_IDLE: begin
                    // Set up a read from status register 0x00
                    daddr_reg <= 7'h00;   // temperature status register
                    dwe_reg   <= 1'b0;    // read
                    den_reg   <= 1'b1;    // assert enable for one cycle
                    state     <= S_READ;
                end

                S_READ: begin
                    // Deassert enable and wait for DRDY
                    den_reg <= 1'b0;
                    state   <= S_WAITDRDY;
                end

                S_WAITDRDY: begin
                    if (drdy_wire) begin
                        // Data ready: latch 12 MSBs of do_wire
                        temp_code  <= do_wire[15:4];
                        temp_valid <= 1'b1;
                        state      <= S_IDLE;
                    end
                end

                default: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end

endmodule
