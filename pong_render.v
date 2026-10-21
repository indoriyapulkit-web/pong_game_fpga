module pong_render(
    input [9:0] pixel_x,pixel_y,
     input  [9:0] ball_x,
    input  [9:0] ball_y,

    input  [9:0] paddle1_y,
    input  [9:0] paddle2_y,
    input video_on,

    output reg [3:0] red,
    output reg [3:0] green,
    output reg [3:0] blue
    );
wire paddle_hit =
        (pixel_x >= 30  && pixel_x < 40  &&
         pixel_y >= paddle1_y && pixel_y < paddle1_y + 80) ||
        (pixel_x >= 600 && pixel_x < 610 &&
         pixel_y >= paddle2_y && pixel_y < paddle2_y + 80);

    wire ball_hit =
        pixel_x >= ball_x && pixel_x < ball_x + 10 &&
        pixel_y >= ball_y && pixel_y < ball_y + 10;

    always @(*) begin
        {red, green, blue} = 12'h000;            // black during blanking
        if (video_on) begin
            {red, green, blue} = 12'hFFF;        // white background
            if (paddle_hit)    {red, green, blue} = 12'h000;  // black paddles
            else if (ball_hit) {red, green, blue} = 12'hF00;  // red ball
        end
    end
endmodule
