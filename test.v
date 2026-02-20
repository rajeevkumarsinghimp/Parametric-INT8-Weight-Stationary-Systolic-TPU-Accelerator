// ============================================================
// Testbench for INT8 Weight-Stationary TPU
// - Self-checking
// - Matrix Multiply Verification
// ============================================================

`timescale 1ns/1ps

module tb_tpu_top;

    parameter N = 4;
    parameter DATA_W = 8;
    parameter ACC_W  = 32;

    reg clk;
    reg rst;
    reg start;

    reg  [N*DATA_W-1:0] act_data;
    reg  [N*DATA_W-1:0] weight_data;

    wire done;
    wire output_valid;
    wire [N*N*ACC_W-1:0] result;

    //---------------------------------------------------------
    // DUT
    //---------------------------------------------------------

    tpu_top #(
        .N(N)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .act_data(act_data),
        .weight_data(weight_data),
        .done(done),
        .output_valid(output_valid),
        .result(result)
    );

    //---------------------------------------------------------
    // Clock Generation
    //---------------------------------------------------------

    initial clk = 0;
    always #5 clk = ~clk;  // 100 MHz

    //---------------------------------------------------------
    // Test Matrices
    //---------------------------------------------------------

    integer i,j,k;

    reg signed [7:0] A [0:N-1][0:N-1];
    reg signed [7:0] B [0:N-1][0:N-1];
    reg signed [31:0] C_golden [0:N-1][0:N-1];

    //---------------------------------------------------------
    // Initialize Test Data
    //---------------------------------------------------------

    initial begin

        // Example matrices
        // A = identity matrix
        // B = random small numbers

        for(i=0;i<N;i=i+1) begin
            for(j=0;j<N;j=j+1) begin
                if(i==j)
                    A[i][j] = 1;
                else
                    A[i][j] = 0;

                B[i][j] = i + j + 1;
            end
        end

        // Compute golden result
        for(i=0;i<N;i=i+1) begin
            for(j=0;j<N;j=j+1) begin
                C_golden[i][j] = 0;
                for(k=0;k<N;k=k+1)
                    C_golden[i][j] =
                        C_golden[i][j] + A[i][k]*B[k][j];
            end
        end

    end

    //---------------------------------------------------------
    // Stimulus
    //---------------------------------------------------------

    initial begin

        rst = 1;
        start = 0;
        act_data = 0;
        weight_data = 0;

        #20;
        rst = 0;

        //-----------------------------------------------------
        // Start TPU
        //-----------------------------------------------------

        #10;
        start = 1;
        #10;
        start = 0;

        //-----------------------------------------------------
        // Feed weights row by row
        //-----------------------------------------------------

        for(i=0;i<N;i=i+1) begin
            for(j=0;j<N;j=j+1) begin
                weight_data[j*DATA_W +: DATA_W] = B[i][j];
            end
            #10;
        end

        //-----------------------------------------------------
        // Feed activations row by row
        //-----------------------------------------------------

        for(i=0;i<N;i=i+1) begin
            for(j=0;j<N;j=j+1) begin
                act_data[j*DATA_W +: DATA_W] = A[i][j];
            end
            #10;
        end

        //-----------------------------------------------------
        // Wait for result
        //-----------------------------------------------------

        wait(output_valid == 1);

        #10;

        //-----------------------------------------------------
        // Compare Results
        //-----------------------------------------------------

        $display("----- Checking Results -----");

        for(i=0;i<N;i=i+1) begin
            for(j=0;j<N;j=j+1) begin

                if(result[(i*N+j)*ACC_W +: ACC_W]
                   !== C_golden[i][j]) begin

                    $display("Mismatch at (%0d,%0d): Expected %0d, Got %0d",
                        i, j,
                        C_golden[i][j],
                        result[(i*N+j)*ACC_W +: ACC_W]);

                    $finish;
                end
            end
        end

        $display("=================================");
        $display("         TEST PASSED             ");
        $display("=================================");

        $finish;

    end

endmodule
