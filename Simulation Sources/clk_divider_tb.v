`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2026 09:24:49 PM
// Design Name: 
// Module Name: clk_divider_tb
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

module clk_divider_tb(); //pproves that if count = 49999999 , out_clk = 1
    reg clk;
    wire out_clk;

    clk_divider uut (.clk(clk), .out_clk(out_clk));

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        force uut.out_clk = 0; 
        #10 release uut.out_clk; 
        
        #10 force uut.count = 49999998;
        #20 release uut.count;

        #200;
        $finish;
    end
endmodule