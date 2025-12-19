`timescale 1ns / 1ps
// ------------------------------------------------------------
// Testbench for 101 sequence detectors (Mealy and Moore)
// This is for simulation ONLY, not for synthesis.
// ------------------------------------------------------------
module tb_101_sequence_detectors;

    reg  clk;
    reg  rst;
    reg  x;
    wire y_mealy;
    wire y_moore;

    // Instantiate Mealy detector
    mealy_101_detector u_mealy (
        .clk (clk),
        .rst (rst),
        .x   (x),
        .y   (y_mealy)
    );

    // Instantiate Moore detector
    moore_101_detector u_moore (
        .clk (clk),
        .rst (rst),
        .x   (x),
        .y   (y_moore)
    );

    // --------------------------------------------------------
    // Clock generation: 10 ns period (toggle every 5 ns)
    // --------------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // --------------------------------------------------------
    // Stimulus
    // --------------------------------------------------------
    integer i;
    // Example stimulus sequence: contains multiple (and overlapping) "101"
    // Feel free to adjust to match your textbook figure exactly.
    reg [0:11] stimulus_bits;  // 12 bits: indices 0..11

    initial begin
        // Initialize input and reset
        rst = 1'b0;  // hold in reset initially (active low)
        x   = 1'b0;

        // Example stimulus: 0 1 0 1 0 1 0 0 1 0 1 1
        // This yields multiple 101 occurrences with overlap.
        stimulus_bits[0]  = 1'b0;
        stimulus_bits[1]  = 1'b1;
        stimulus_bits[2]  = 1'b0;
        stimulus_bits[3]  = 1'b1;
        stimulus_bits[4]  = 1'b0;
        stimulus_bits[5]  = 1'b1;
        stimulus_bits[6]  = 1'b0;
        stimulus_bits[7]  = 1'b0;
        stimulus_bits[8]  = 1'b1;
        stimulus_bits[9]  = 1'b0;
        stimulus_bits[10] = 1'b1;
        stimulus_bits[11] = 1'b1;

        // Wait a bit, then release reset
        #12;
        rst = 1'b1;   // deassert reset

        // Apply the stimulus bits, one per clock cycle
        for (i = 0; i <= 11; i = i + 1) begin
            // Change x on the negative edge so it is stable by the next posedge
            @(negedge clk);
            x = stimulus_bits[i];
        end

        // After all bits are applied, wait some time and finish
        @(negedge clk);
        x = 1'b0;  // idle
        #50;
        $finish;
    end

    // --------------------------------------------------------
    // Monitor for console output
    // --------------------------------------------------------
    initial begin
        $display("Time   rst  x  |  y_mealy  y_moore");
        $monitor("%4t   %b    %b  |     %b        %b",
                 $time, rst, x, y_mealy, y_moore);
    end

endmodule
