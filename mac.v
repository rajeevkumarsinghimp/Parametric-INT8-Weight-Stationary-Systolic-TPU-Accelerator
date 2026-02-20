// ============================================================
// INT8 Multiply-Accumulate Unit
// - 1 pipeline stage
// - Signed arithmetic
// - Synthesizable for FPGA (DSP) and ASIC
// ============================================================

module mac_int8 #(
    parameter DATA_W = 8,    // Input data width (INT8)
    parameter ACC_W  = 32    // Accumulator width
)(
    input  wire clk,
    input  wire rst,
    input  wire en,          // Enable for MAC operation

    input  wire signed [DATA_W-1:0] a,   // Activation
    input  wire signed [DATA_W-1:0] b,   // Weight
    input  wire signed [ACC_W-1:0]  acc_in,

    output reg  signed [ACC_W-1:0]  acc_out
);

    // Internal pipeline registers
    reg signed [DATA_W-1:0] a_r, b_r;
    reg signed [15:0] mult_r;

    always @(posedge clk) begin
        if (rst) begin
            a_r     <= 0;
            b_r     <= 0;
            mult_r  <= 0;
            acc_out <= 0;
        end
        else if (en) begin
            // Stage 1: register inputs
            a_r <= a;
            b_r <= b;

            // Stage 2: multiply
            mult_r <= a_r * b_r;

            // Stage 3: accumulate
            acc_out <= acc_in + mult_r;
        end
    end

endmodule
