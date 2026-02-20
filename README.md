# Parametric-INT8-Weight-Stationary-Systolic-TPU-Accelerator
Developed a parametric INT8 weight-stationary systolic TPU accelerator in Verilog for high-throughput matrix multiplication. Implemented pipelined MAC array, row-wise weight loading, accumulator control, ReLU stage, and self-checking verification.
# BRIEF DATAFLOW
The architecture consists of pipelined signed INT8 MAC units with 32-bit accumulation, organized into a 2D systolic array with row-wise weight loading and streamed activations. A dedicated FSM-based controller manages accumulator clearing, weight loading, compute scheduling, and output valid signaling to ensure deterministic latency. The design integrates a post-accumulation ReLU activation stage and follows a clean modular hierarchy (MAC → PE → Array → Controller → Top), making it scalable and FPGA/ASIC friendly. A self-checking testbench with a golden matrix multiplication model verifies functional correctness.
# MODULE FLOW IN BRIEF
<img width="1251" height="567" alt="image" src="https://github.com/user-attachments/assets/af0700df-bb13-4df4-a773-de2482001bce" />
