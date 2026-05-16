`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2026 10:33:08 PM
// Design Name: 
// Module Name: PRNG_tb
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

`timescale 1ns / 1ps

module PRNG_tb();
    reg clk;
    reg rst;
    reg load;
    reg [15:0] seed;
    wire [15:0] out;

    PRNG uut (
        .clk(clk),
        .rst(rst),
        .load(load),
        .seed(seed),
        .out(out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 0;
        load = 0;
        seed = 16'h0000;
        
        #20 rst = 1;
        #20 rst = 0;
        #100;
        
        seed = 16'hACE1; 
        load = 1;
        #10;
        load = 0;
        
        #200;

        $finish;
    end
endmodule