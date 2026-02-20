// ============================================================
// Weight-Stationary Processing Element (PE)
// - Stores one weight locally
// - Streams activation downward
// - Accumulates partial sums horizontally
// ============================================================

module pe_ws #(
    parameter DATA_W = 8,
    parameter ACC_W  = 32
)(
    input  wire clk,
    input  wire rst,
    input  wire en,

    input  wire clear_acc,          // Clears accumulation

    input  wire load_weight,        // Loads weight into local register
    input  wire signed [DATA_W-1:0] weight_in,

    input  wire signed [DATA_W-1:0] act_in,
    input  wire signed [ACC_W-1:0]  acc_in,

    output wire signed [DATA_W-1:0] act_out,
    output wire signed [ACC_W-1:0]  acc_out
);

    // Local weight register (stationary)
    reg signed [DATA_W-1:0] weight_reg;

    always @(posedge clk) begin
        if (rst)
            weight_reg <= 0;
        else if (load_weight)
            weight_reg <= weight_in;
    end

    // Clear accumulator at start of new computation
    wire signed [ACC_W-1:0] acc_mux =
        (clear_acc) ? 0 : acc_in;

    wire signed [ACC_W-1:0] acc_internal;

    // MAC instance
    mac_int8 #(
        .DATA_W(DATA_W),
        .ACC_W(ACC_W)
    ) mac_inst (
        .clk(clk),
        .rst(rst),
        .en(en),
        .a(act_in),
        .b(weight_reg),
        .acc_in(acc_mux),
        .acc_out(acc_internal)
    );

    assign acc_out = acc_internal;
    assign act_out = act_in;  // Forward activation downward

endmodule
