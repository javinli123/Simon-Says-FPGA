module debouncer #(
    parameter MAX = 1000000
)(
    input clk,
    input noisy_button,
    output reg clean_button,
    output pulse 
);
    reg [19:0] counter; 
    reg last_clean_state; 

    
    always @(posedge clk) begin
        if (noisy_button != clean_button) begin
            counter <= counter + 1'b1;
            if (counter >= MAX) begin
                clean_button <= noisy_button;
                counter <= 0;
            end
        end 
        else begin
            counter <= 0;
        end
        last_clean_state <= clean_button;
    end

    assign pulse = (clean_button == 1'b1 && last_clean_state == 1'b0);

endmodule