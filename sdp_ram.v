// ============================================================
// Simple Dual-Port SRAM
// - Infers BRAM in FPGA
// - Maps to SRAM macro in ASIC
// ============================================================

module simple_sram #(
    parameter ADDR_W = 10,
    parameter DATA_W = 64
)(
    input  wire clk,

    input  wire we,
    input  wire [ADDR_W-1:0] waddr,
    input  wire [DATA_W-1:0] wdata,

    input  wire [ADDR_W-1:0] raddr,
    output reg  [DATA_W-1:0] rdata
);

    reg [DATA_W-1:0] mem [0:(1<<ADDR_W)-1];

    always @(posedge clk) begin
        if (we)
            mem[waddr] <= wdata;

        rdata <= mem[raddr];
    end

endmodule
