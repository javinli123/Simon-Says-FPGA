module clk_divider(
    input clk,          // 100 MHz clock
    output reg out_clk  // 1 Hz clock
);
    
    reg [26:0] count = 0;

    always @(posedge clk) begin
        if (count == 49999999) begin
            count <= 0;
            out_clk <= ~out_clk;
        end else begin
            count <= count + 1;
        end
    end
endmodule