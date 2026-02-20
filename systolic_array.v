// ============================================================
// 2D Weight-Stationary Systolic Array
// - N x N grid of PEs
// - Row-wise weight loading
// - ReLU applied at output stage
// ============================================================

module systolic_array #(
    parameter N       = 8,
    parameter DATA_W  = 8,
    parameter ACC_W   = 32
)(
    input  wire clk,
    input  wire rst,
    input  wire en,
    input  wire clear_acc,

    input  wire load_weight,
    input  wire [$clog2(N)-1:0] load_row,

    input  wire [N*DATA_W-1:0] act_vector,
    input  wire [N*DATA_W-1:0] weight_vector,

    output wire [N*N*ACC_W-1:0] result_vector
);

    genvar i,j;

    // Activation and accumulation buses
    wire signed [DATA_W-1:0] act_bus [0:N][0:N-1];
    wire signed [ACC_W-1:0]  acc_bus [0:N-1][0:N];

    wire signed [ACC_W-1:0] raw_result [0:N*N-1];

    // Inject activations into first row
    generate
        for(i=0;i<N;i=i+1) begin
            assign act_bus[0][i] =
                act_vector[i*DATA_W +: DATA_W];

            assign acc_bus[i][0] = 0;  // Initial accumulation
        end
    endgenerate

    // PE grid
    generate
        for(i=0;i<N;i=i+1) begin : ROW
            for(j=0;j<N;j=j+1) begin : COL

                wire load_this =
                    load_weight && (load_row == i);

                pe_ws #(
                    .DATA_W(DATA_W),
                    .ACC_W(ACC_W)
                ) pe_inst (
                    .clk(clk),
                    .rst(rst),
                    .en(en),
                    .clear_acc(clear_acc),
                    .load_weight(load_this),
                    .weight_in(
                        weight_vector[j*DATA_W +: DATA_W]
                    ),
                    .act_in(act_bus[i][j]),
                    .acc_in(acc_bus[i][j]),
                    .act_out(act_bus[i+1][j]),
                    .acc_out(acc_bus[i][j+1])
                );

                assign raw_result[i*N+j] =
                    acc_bus[i][j+1];

            end
        end
    endgenerate

    // ReLU stage
    generate
        for(i=0;i<N*N;i=i+1) begin : RELU_STAGE

            relu #(
                .W(ACC_W)
            ) relu_inst (
                .in(raw_result[i]),
                .out(result_vector[i*ACC_W +: ACC_W])
            );

        end
    endgenerate

endmodule
