// ============================================================
// TPU Controller FSM
// Controls:
// - Accumulator clear
// - Row-wise weight loading
// - Compute phase (2N cycles)
// - Output valid + done
// ============================================================

module tpu_controller #(
    parameter N = 8
)(
    input  wire clk,
    input  wire rst,
    input  wire start,

    output reg  load_weight,
    output reg  compute_en,
    output reg  clear_acc,
    output reg  done,
    output reg  output_valid,
    output reg  [$clog2(N)-1:0] load_row
);

    reg [15:0] counter;
    reg [2:0] state;

    localparam IDLE    = 0;
    localparam CLEAR   = 1;
    localparam LOAD    = 2;
    localparam COMPUTE = 3;
    localparam FINISH  = 4;

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            counter <= 0;
            done <= 0;
            output_valid <= 0;
        end
        else begin
            case(state)

                IDLE:
                    if(start) state <= CLEAR;

                CLEAR: begin
                    counter <= 0;
                    state <= LOAD;
                end

                LOAD: begin
                    load_row <= counter[$clog2(N)-1:0];
                    if(counter == N-1) begin
                        counter <= 0;
                        state <= COMPUTE;
                    end
                    else
                        counter <= counter + 1;
                end

                COMPUTE: begin
                    if(counter == (2*N)) begin
                        state <= FINISH;
                    end
                    else
                        counter <= counter + 1;
                end

                FINISH: begin
                    output_valid <= 1;
                    done <= 1;
                    state <= IDLE;
                end

            endcase
        end
    end

    always @(*) begin
        load_weight = (state == LOAD);
        compute_en  = (state == COMPUTE);
        clear_acc   = (state == CLEAR);
    end

endmodule
