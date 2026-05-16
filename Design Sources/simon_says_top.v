module simon_says_top(
    input clk,            
    input btnCpuReset,    
    input btn_center,       
    input [3:0] btn,      
    input [0:0] swt,        
    output [3:0] led,      
    output [7:0] an,        
    output [6:0] seg        
);

    // Internal wires & registers
    wire clk_1hz, clk_refresh, btn_center_pulse;
    wire [3:0] btn_pulse;
    reg [3:0] playback_idx, step_idx, current_level;
    reg [27:0] delay_timer, reset_timer;
    reg [3:0] led_out;
    reg [1:0] sequence_mem [0:15];
    
    // PRNG
    wire [15:0] raw_rand;
    reg [15:0] seed_counter;
    assign led = led_out;

    // Reset logic
    wire hard_reset = (reset_timer >= 150_000_000) || (!btnCpuReset);

    clk_divider game_timer (.clk(clk), .out_clk(clk_1hz));
    reg [16:0] refresh_cnt;
    always @(posedge clk) refresh_cnt <= refresh_cnt + 1;
    assign clk_refresh = refresh_cnt[16];

    debouncer db0 (.clk(clk), .noisy_button(btn[0]), .pulse(btn_pulse[0]));
    debouncer db1 (.clk(clk), .noisy_button(btn[1]), .pulse(btn_pulse[1]));
    debouncer db2 (.clk(clk), .noisy_button(btn[2]), .pulse(btn_pulse[2]));
    debouncer db3 (.clk(clk), .noisy_button(btn[3]), .pulse(btn_pulse[3]));
    debouncer db_center (.clk(clk), .noisy_button(btn_center), .pulse(btn_center_pulse));

    PRNG game_randomizer (.clk(clk), .rst(hard_reset), .load(1'b0), .seed(seed_counter), .out(raw_rand));

    segment_display screen (.clk_refresh(clk_refresh), .mode(swt[0]), .level(current_level), .an(an), .seg(seg));

    // FSM
    parameter IDLE=3'b000, START=3'b001, SET_VS=3'b010, SHOW=3'b011, INPUT=3'b100, DELAY=3'b101, NEXT_LVL=3'b110, GAMEOVER=3'b111;
    reg [2:0] state = IDLE;

    always @(posedge clk) begin
        seed_counter <= seed_counter + 1;
        reset_timer <= (btn_center) ? reset_timer + 1 : 0;

        if (hard_reset) begin
            state <= IDLE;
            current_level <= 0;
            led_out <= 4'b0000;
        end else begin
            case (state)
                IDLE: begin
                    led_out <= 4'b0000;
                    step_idx <= 0;
                    playback_idx <= 0;
                    delay_timer <= 0;
                    if (btn_center_pulse) begin
                        current_level <= 4;
                        state <= (swt[0]) ? SET_VS : START;
                    end
                end

                SET_VS: begin
                    if (btn_pulse != 4'b0000 && step_idx < current_level) begin
                        sequence_mem[step_idx] <= (btn_pulse[0]) ? 0 : 
                                                  (btn_pulse[1]) ? 1 : 
                                                  (btn_pulse[2]) ? 2 : 3;
                        step_idx <= step_idx + 1;
                    end
                    
                    led_out <= btn_pulse; 

                    if (step_idx == current_level) begin
                        led_out <= 4'b0000; 
                        if (delay_timer >= 100000000) begin 
                            delay_timer <= 0;
                            step_idx <= 0;
                            playback_idx <= 0; 
                            state <= SHOW; 
                        end else begin
                            delay_timer <= delay_timer + 1;
                        end
                    end
                end

                START: begin
                    sequence_mem[0] <= raw_rand[1:0]; sequence_mem[1] <= raw_rand[5:4];
                    sequence_mem[2] <= raw_rand[9:8]; sequence_mem[3] <= raw_rand[13:12];
                    playback_idx <= 0;
                    state <= SHOW;
                end

                SHOW: begin
                    if (clk_1hz) led_out <= (1 << sequence_mem[playback_idx]);
                    else led_out <= 4'b0000;

                    if (clk_1hz == 0 && led_out != 4'b0000) begin
                        if (playback_idx + 1 == current_level) begin
                            step_idx <= 0;
                            state <= INPUT;
                        end else playback_idx <= playback_idx + 1;
                    end
                end

                INPUT: begin
                    if (btn_pulse != 4'b0000) begin
                        if (btn_pulse[sequence_mem[step_idx]]) begin
                            if (step_idx + 1 == current_level) state <= DELAY;
                            else step_idx <= step_idx + 1;
                        end else state <= GAMEOVER;
                    end
                end

                DELAY: begin
                    led_out <= 4'b0000;
                    if (delay_timer >= 100_000_000) begin
                        delay_timer <= 0;
                        state <= (current_level == 17) ? GAMEOVER : NEXT_LVL;
                    end else delay_timer <= delay_timer + 1;
                end

                NEXT_LVL: begin
                    current_level <= current_level + 1;
                    step_idx <= 0;
                    playback_idx <= 0;
                    if (swt[0]) state <= SET_VS; 
                    else begin
                        sequence_mem[current_level] <= raw_rand[3:2]; 
                        state <= SHOW;
                    end
                end

                GAMEOVER: begin
                    led_out <= 4'b1111; 
                    if (delay_timer >= 150000000) begin
                        delay_timer <= 0;
                        current_level <= 0; 
                        state <= IDLE;
                    end else begin
                        delay_timer <= delay_timer + 1;
                    end
                    
                    if (btn_center_pulse) begin
                        delay_timer <= 0;
                        state <= IDLE;
                    end                    
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule