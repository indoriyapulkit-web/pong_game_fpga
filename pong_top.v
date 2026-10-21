module pong_top(
    input clk,rst,
    input player1_up,
    input player1_down,
    input player2_up,
    input player2_down,    
    output [3:0] red_o,
    output [3:0] green_o,
    output [3:0] blue_o,
    output hsync_o,
    output vsync_o,
    output reg [6:0] seg_o,
    output reg [7:0] an_o
    );
    wire pong_tick,hsync,vsync,video_on,game_over;
    wire [9:0] pixel_x,pixel_y;
    wire [9:0] ball_x,ball_y,paddle_1,paddle_2;
    wire [3:0] red,green,blue,score_1,score_2;
    
    pong_tick_gen ptg(clk,rst,pong_tick);
    
    VGA_controller vc(clk,rst,hsync,vsync,video_on,pixel_x,pixel_y);
    
    pong_logic pl(rst,pong_tick,player1_up,player1_down,player2_up,player2_down,ball_x,ball_y,paddle_1,paddle_2,game_over,score_1,score_2);
    
    pong_render pr(pixel_x,pixel_y,ball_x,ball_y,paddle_1,paddle_2,video_on,red,green,blue);
    
assign red_o=red;
assign green_o=green;
assign blue_o=blue;
assign hsync_o= hsync;
assign vsync_o=vsync;

reg [19:0] seg_counter;
    reg seg_select;

reg [6:0] seg_pattern;


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            seg_counter <= 0;
            seg_select  <= 0;
        end
        else begin
            if (seg_counter == 20'd49999) begin
                seg_counter <= 0;
                seg_select  <= ~seg_select;
            end
            else begin
                seg_counter <= seg_counter + 1'b1;
            end
        end
    end
    always @(*) begin

        if (seg_select == 1'b0) begin
            case (score_1)
                4'd0: seg_pattern = 7'b1000000;
                4'd1: seg_pattern = 7'b1111001;
                4'd2: seg_pattern = 7'b0100100;
                4'd3: seg_pattern = 7'b0110000;
                4'd4: seg_pattern = 7'b0011001;
                4'd5: seg_pattern = 7'b0010010;
                4'd6: seg_pattern = 7'b0000010;
                4'd7: seg_pattern = 7'b1111000;
                4'd8: seg_pattern = 7'b0000000;
                4'd9: seg_pattern = 7'b0010000;
                default: seg_pattern = 7'b1111111;
            endcase
        end

        else begin
            case (score_2)
                4'd0: seg_pattern = 7'b1000000;
                4'd1: seg_pattern = 7'b1111001;
                4'd2: seg_pattern = 7'b0100100;
                4'd3: seg_pattern = 7'b0110000;
                4'd4: seg_pattern = 7'b0011001;
                4'd5: seg_pattern = 7'b0010010;
                4'd6: seg_pattern = 7'b0000010;
                4'd7: seg_pattern = 7'b1111000;
                4'd8: seg_pattern = 7'b0000000;
                4'd9: seg_pattern = 7'b0010000;
                default: seg_pattern = 7'b1111111;
            endcase
        end
    end

    always @(*) begin

        seg_o = seg_pattern;

        an_o = 8'b11111111;

        if (seg_select == 1'b0) begin
            an_o[0] = 1'b0;       
        end
        else begin
            an_o[1] = 1'b0;       
        end
    end
endmodule
