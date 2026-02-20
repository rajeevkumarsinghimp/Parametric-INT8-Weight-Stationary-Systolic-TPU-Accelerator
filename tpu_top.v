// ============================================================
// Top-Level TPU Integration
// ============================================================

module tpu_top #(
    parameter N = 8
)(
    input  wire clk,
    input  wire rst,
    input  wire start,

    input  wire [N*8-1:0] act_data,
    input  wire [N*8-1:0] weight_data,

    output wire done,
    output wire output_valid,
    output wire [N*N*32-1:0] result
);

    wire load_weight;
    wire compute_en;
    wire clear_acc;
    wire [$clog2(N)-1:0] load_row;

    tpu_controller #(
        .N(N)
    ) ctrl (
        .clk(clk),
        .rst(rst),
        .start(start),
        .load_weight(load_weight),
        .compute_en(compute_en),
        .clear_acc(clear_acc),
        .done(done),
        .output_valid(output_valid),
        .load_row(load_row)
    );

    systolic_array #(
        .N(N)
    ) array_inst (
        .clk(clk),
        .rst(rst),
        .en(compute_en),
        .clear_acc(clear_acc),
        .load_weight(load_weight),
        .load_row(load_row),
        .act_vector(act_data),
        .weight_vector(weight_data),
        .result_vector(result)
    );

endmodule
