// ============================================================
// ReLU Activation (Combinational)
// ============================================================

module relu #(
    parameter W = 32
)(
    input  wire signed [W-1:0] in,
    output wire signed [W-1:0] out
);

    // If MSB is 1 → negative → clamp to 0
    assign out = (in[W-1]) ? 0 : in;

endmodule
