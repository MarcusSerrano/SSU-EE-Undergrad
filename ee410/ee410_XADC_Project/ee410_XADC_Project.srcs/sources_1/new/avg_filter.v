// avg_filter.v
// Simple moving-average filter for unsigned samples.
//
// Parameters:
//   SAMPLE_COUNT_LOG2: log2 of the number of samples to average.
//                      e.g., 4 -> average 16 samples.

module avg_filter #(
    parameter SAMPLE_COUNT_LOG2 = 4  // default: 16 samples
)(
    input  wire        clk,
    input  wire        rst,          // active-high synchronous reset

    input  wire [11:0] sample_in,    // raw XADC sample
    input  wire        sample_valid, // 1 when sample_in is valid

    output reg  [11:0] avg_out,      // averaged sample
    output reg         avg_valid     // pulses high for 1 clk when avg_out is updated
);

    localparam SAMPLE_COUNT = (1 << SAMPLE_COUNT_LOG2);

    // Sum wide enough to hold SAMPLE_COUNT * 12-bit samples
    // 12 + SAMPLE_COUNT_LOG2 bits is enough.
    reg [11+SAMPLE_COUNT_LOG2:0] sum;
    reg [SAMPLE_COUNT_LOG2-1:0]  count;

    always @(posedge clk) begin
        if (rst) begin
            sum       <= { (12+SAMPLE_COUNT_LOG2+1) {1'b0} };
            count     <= { SAMPLE_COUNT_LOG2 {1'b0} };
            avg_out   <= 12'd0;
            avg_valid <= 1'b0;
        end else begin
            avg_valid <= 1'b0; // default

            if (sample_valid) begin
                sum   <= sum + sample_in;
                count <= count + 1'b1;

                if (count == SAMPLE_COUNT-1) begin
                    // Right-shift by SAMPLE_COUNT_LOG2 bits to divide
                    avg_out   <= sum[11+SAMPLE_COUNT_LOG2 : SAMPLE_COUNT_LOG2];
                    avg_valid <= 1'b1;

                    // Reset for next block of samples
                    sum   <= { (12+SAMPLE_COUNT_LOG2+1) {1'b0} };
                    count <= { SAMPLE_COUNT_LOG2 {1'b0} };
                end
            end
        end
    end

endmodule
