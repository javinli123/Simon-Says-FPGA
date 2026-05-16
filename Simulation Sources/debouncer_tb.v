`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2026 09:57:10 PM
// Design Name: 
// Module Name: debouncer_tb
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


module debouncer_tb();
    reg clk;
    reg noisy_button;
    wire clean_button;
    wire pulse;

    debouncer #(.MAX(10)) uut (
        .clk(clk),
        .noisy_button(noisy_button),
        .clean_button(clean_button),
        .pulse(pulse)
    );

    initial begin
        clk = 0; 
        forever #5 clk = ~clk; 
    end

    initial begin
        noisy_button = 0;
        force uut.clean_button = 0;
        force uut.counter = 0;
        force uut.last_clean_state = 0;
        #20; 
        release uut.clean_button;
        release uut.counter;
        release uut.last_clean_state;

        #50;
        noisy_button = 1; #10; 
        noisy_button = 0; #10;
        noisy_button = 1; #10; 
        noisy_button = 0; #10;
        #50;
        noisy_button = 1; 
        #200; 

        #50;
        noisy_button = 0; #10;
        noisy_button = 1; #10;
        noisy_button = 0; 
        
        #200;
        $display("Simulation Finished");
        $finish;
    end
endmodule