module segment_display(
    input clk_refresh,      
    input [0:0] mode,       
    input [3:0] level,      
    output reg [7:0] an,    
    output reg [6:0] seg    
);

    reg [2:0] digit_select; 
    reg [4:0] current_char; 

    always @(posedge clk_refresh) digit_select <= digit_select + 1;

    always @(*) begin
        an = 8'b11111111;
        current_char = 5'd14; 

        case(digit_select)
            3'd0: begin an = 8'b11111110; current_char = level % 10; end
            3'd1: begin an = 8'b11111101; current_char = level / 10; end

            3'd4: begin 
                if (!mode) begin an = 8'b11101111; current_char = 5'd11; end // O 
                else       begin an = 8'b11101111; current_char = 5'd1;  end // 1 
            end
            3'd5: begin 
                if (!mode) begin an = 8'b11011111; current_char = 5'd12; end // L 
                else       begin an = 8'b11011111; current_char = 5'd13; end // V
            end
            3'd6: begin 
                if (!mode) begin an = 8'b10111111; current_char = 5'd11; end // O
                else       begin an = 8'b10111111; current_char = 5'd1;  end // 1
            end
            3'd7: begin 
                if (!mode) begin an = 8'b01111111; current_char = 5'd10; end // S
            end
            default: ;
        endcase
    end

    always @(*) begin
        case(current_char)
            5'd0:  seg = 7'b1000000; // 0
            5'd1:  seg = 7'b1111001; // 1
            5'd2:  seg = 7'b0100100; // 2
            5'd3:  seg = 7'b0110000; // 3
            5'd4:  seg = 7'b0011001; // 4
            5'd5:  seg = 7'b0010010; // 5
            5'd6:  seg = 7'b0000010; // 6
            5'd7:  seg = 7'b1111000; // 7
            5'd8:  seg = 7'b0000000; // 8
            5'd9:  seg = 7'b0010000; // 9
            5'd10: seg = 7'b0010010; // S
            5'd11: seg = 7'b1000000; // O
            5'd12: seg = 7'b1000111; // L
            5'd13: seg = 7'b1100011; // v (u)
            default: seg = 7'b1111111; // blank
        endcase
    end
endmodule