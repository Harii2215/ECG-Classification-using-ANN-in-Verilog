`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/22/2024 10:10:11 PM
// Design Name: 
// Module Name: TopModule
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module TopModule (
    input clk,
    input reset,
    output reg [15:0] outO1,
    output reg [15:0] outO2, 
    output reg [15:0] outO3, 
    output reg [15:0] outO4, 
    output reg [15:0] outO5
);

    // Memory to hold the input data
    reg signed [15:0] input_data [0:186];
    reg signed [15:0] weightsL1 [0:3739];
    reg signed [15:0] biasesL1[0:19];
    reg signed [15:0] weightsL2 [0:199];
    reg signed [15:0] biasesL2[0:9];
    reg signed [15:0] weightsO [0:49];
    reg signed [15:0] biasesO[0:4];

    // Output data
    reg signed [15:0] data_outL1[0:19];
    reg signed [15:0] data_outL2[0:9];
    reg signed [15:0] data_outO[0:4];

    initial begin
       
        $readmemb("C:/Users/rgukt/Desktop/Vivado_CODES/project_5/sample3_1.txt", input_data);
        $readmemh("C:/Users/rgukt/Desktop/Vivado_CODES/project_5/layer_new_0_weights.mem", weightsL1);
        $readmemh("C:/Users/rgukt/Desktop/Vivado_CODES/project_5/layer_new_0_biases.mem", biasesL1);
        $readmemh("C:/Users/rgukt/Desktop/Vivado_CODES/project_5/layer_new_1_weights.mem", weightsL2);
        $readmemh("C:/Users/rgukt/Desktop/Vivado_CODES/project_5/layer_new_1_biases.mem", biasesL2);
        $readmemh("C:/Users/rgukt/Desktop/Vivado_CODES/project_5/layer_new_2_weights.mem", weightsO);
        $readmemh("C:/Users/rgukt/Desktop/Vivado_CODES/project_5/layer_new_2_biases.mem", biasesO);
    end

    // Layer 1 calculations
    integer i, j;
    reg signed [15:0] sum1[0:19];
    reg signed [15:0] out1[0:19];

    always @ (posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 20; i = i + 1) begin
                sum1[i] <= 0;
                data_outL1[i] <= 0;
                out1[i] <= 0;
            end
        end else begin
            for (i = 0; i < 20; i = i + 1) begin
                sum1[i] = 0;
                for (j = 0; j < 187; j = j + 1) begin
                    sum1[i] = sum1[i] + input_data[j] * weightsL1[i * 187 + j];
                end
                sum1[i] = sum1[i] + biasesL1[i];
                out1[i] = (sum1[i][15] == 1'b1) ? 16'b0 : sum1[i];  // Apply ReLU
                data_outL1[i] <= out1[i];
                $display("Layer 1 - sum1[%0d]: %d, out1[%0d]: %d", i, sum1[i], i, out1[i]);
            end
        end
    end

    // Layer 2 calculations
    integer u, v;
    reg signed [15:0] sum2[0:9];
    reg signed [15:0] out2[0:9];

    always @ (posedge clk or posedge reset) begin
        if (reset) begin
            for (u = 0; u < 10; u = u + 1) begin
                sum2[u] <= 0;
                data_outL2[u] <= 0;
                out2[u] <= 0;
            end
        end else begin
            for (u = 0; u < 10; u = u + 1) begin
                sum2[u] = 0;
                for (v = 0; v < 20; v = v + 1) begin
                    sum2[u] = sum2[u] + data_outL1[v] * weightsL2[u * 20 + v];
                end
                sum2[u] = sum2[u] + biasesL2[u];
                out2[u] = (sum2[u][15] == 1'b1) ? 16'b0 : sum2[u];  // Apply ReLU
                data_outL2[u] <= out2[u];
                $display("Layer 2 - sum2[%0d]: %d, out2[%0d]: %d", u, sum2[u], u, out2[u]);
            end
        end
    end

    // Output layer calculations
    integer m, n;
    reg signed [15:0] sum3[0:4];

    always @ (posedge clk or posedge reset) begin
        if (reset) begin
            for (m = 0; m < 5; m = m + 1) begin
                sum3[m] <= 0;
                data_outO[m] <= 0;
            end
        end else begin
            for (m = 0; m < 5; m = m + 1) begin
                sum3[m] = 0;
                for (n = 0; n < 10; n = n + 1) begin
                    sum3[m] = sum3[m] + data_outL2[n] * weightsO[m * 10 + n];
                end
                sum3[m] = sum3[m] + biasesO[m];
                data_outO[m] <= sum3[m];
                $display("Output Layer - sum3[%0d]: %d", m, sum3[m]);
            end
        end
    end

    always @ (posedge clk or posedge reset) begin
        if (reset) begin
            outO1 <= 16'b0;
            outO2 <= 16'b0;
            outO3 <= 16'b0;
            outO4 <= 16'b0;
            outO5 <= 16'b0;
        end else begin

            if (sum3[0] >= sum3[1] && sum3[0] >= sum3[2] && sum3[0] >= sum3[3] && sum3[0] >= sum3[4]) outO1 <= 16'b00001;
            else if (sum3[1] >= sum3[0] && sum3[1] >= sum3[2] && sum3[1] >= sum3[3] && sum3[1] >= sum3[4]) outO2 <= 16'b00010;
            else if (sum3[2] >= sum3[0] && sum3[2] >= sum3[1] && sum3[2] >= sum3[3] && sum3[2] >= sum3[4]) outO3 <= 16'b00100;
            else if (sum3[3] >= sum3[0] && sum3[3] >= sum3[1] && sum3[3] >= sum3[2] && sum3[3] >= sum3[4]) outO4 <= 16'b01000;
            else if (sum3[4] >= sum3[0] && sum3[4] >= sum3[1] && sum3[4] >= sum3[2] && sum3[4] >= sum3[3]) outO5 <= 16'b10000;

            $display("Time=%0t: output_data0=%d, output_data1=%d, output_data2=%d, output_data3=%d, output_data4=%d",
                      $time, outO1, outO2, outO3, outO4, outO5);
        end
    end
endmodule
