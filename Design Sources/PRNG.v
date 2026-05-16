`timescale 1ns / 1ps

module PRNG(
    input clk,
    input rst,
    input load,
    input [15:0] seed,
    output reg [15:0] out
);

    wire feedback = out[15] ^ out[14] ^ out[12] ^ out[3];
    wire [15:0] nextOut;
    assign nextOut = {out[14:0], feedback};

    always @ (posedge clk or posedge rst)
    begin
        if(rst)
        begin
            out <= 16'hFFFF;
        end
        else
        begin
            if(load)
                out <= seed;
            else
                out <= nextOut;
        end
    end

endmodule