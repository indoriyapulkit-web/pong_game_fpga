module pong_logic(
    input rst,
    input pong_tick,

    input player1_up,
    input player1_down,
    input player2_up,
    input player2_down,

    output reg [9:0] ball_x,
    output reg [9:0] ball_y,
    output reg [9:0] paddle_1,
    output reg [9:0] paddle_2,

    output reg game_over,
    output reg [3:0] score_1,
    output reg [3:0] score_2
);

    localparam BALL_SIZE     = 10;
    localparam PADDLE_WIDTH  = 10;
    localparam PADDLE_HEIGHT = 80;
    localparam SCREEN_WIDTH  = 640;
    localparam SCREEN_HEIGHT = 480;

    localparam LEFT_PADDLE_X  = 30;
    localparam RIGHT_PADDLE_X = 600;

    // Ball velocity
    reg signed [3:0] ball_dx;
    reg signed [3:0] ball_dy;

    // Internal signal: stays high for one pong_tick after a score
    reg scored;

    // Predicted next position
    wire signed [10:0] next_x;
    wire signed [10:0] next_y;

    assign next_x = $signed({1'b0, ball_x}) + ball_dx;
    assign next_y = $signed({1'b0, ball_y}) + ball_dy;


    always @(posedge pong_tick or posedge rst) begin

        if (rst) begin

            // Initial ball position
            ball_x <= 315;
            ball_y <= 235;

            // Initial paddle positions
            paddle_1 <= 200;
            paddle_2 <= 200;

            // Initial ball velocity
            ball_dx <= 2;
            ball_dy <= 1;

            // Initial score
            score_1 <= 0;
            score_2 <= 0;

            // Initial game state
            game_over <= 0;
            scored    <= 0;
        end

        else begin

            // =================================================
            // ONE CYCLE AFTER A SCORE
            // Reset game objects, but keep scores/game_over
            // =================================================

            if (scored) begin

                ball_x   <= 315;
                ball_y   <= 235;

                paddle_1 <= 200;
                paddle_2 <= 200;

                ball_dx  <= 2;
                ball_dy  <= 1;

                scored   <= 0;
            end


            // =================================================
            // NORMAL GAME
            // =================================================

            else if (!game_over) begin

                // ---------------------------------------------
                // CHECK FOR SCORING FIRST
                // ---------------------------------------------

                // Player 1 scores
                if ((next_x + BALL_SIZE) > SCREEN_WIDTH) begin

                    if (score_1 == 8) begin
                        score_1   <= 9;
                        game_over <= 1;
                    end
                    else begin
                        score_1 <= score_1 + 1;
                    end

                    scored <= 1;
                end


                // Player 2 scores
                else if (next_x < 0) begin

                    if (score_2 == 8) begin
                        score_2   <= 9;
                        game_over <= 1;
                    end
                    else begin
                        score_2 <= score_2 + 1;
                    end

                    scored <= 1;
                end


                // ---------------------------------------------
                // NO SCORE -> NORMAL GAME
                // ---------------------------------------------

                else begin

                    // Default: move ball
                    ball_x <= next_x;
                    ball_y <= next_y;


                    // =========================================
                    // TOP / BOTTOM WALL COLLISION
                    // =========================================

                    if ((next_y <= 0) ||
                        (next_y + BALL_SIZE >= SCREEN_HEIGHT)) begin
                        ball_dy <= -ball_dy;
                    end 


                    // =========================================
                    // LEFT PADDLE COLLISION
                    // =========================================

                    if ((ball_dx < 0) &&
                             (next_x < LEFT_PADDLE_X + PADDLE_WIDTH) &&
                             (next_x + BALL_SIZE > LEFT_PADDLE_X) &&
                             (next_y < paddle_1 + PADDLE_HEIGHT) &&
                             (next_y + BALL_SIZE > paddle_1)) begin

                        ball_dx <= -ball_dx;
                    end


                    // =========================================
                    // RIGHT PADDLE COLLISION
                    // =========================================

                    else if ((ball_dx > 0) &&
                             (next_x + BALL_SIZE > RIGHT_PADDLE_X) &&
                             (next_x < RIGHT_PADDLE_X + PADDLE_WIDTH) &&
                             (next_y < paddle_2 + PADDLE_HEIGHT) &&
                             (next_y + BALL_SIZE > paddle_2)) begin

                        ball_dx <= -ball_dx;
                    end


                    // =========================================
                    // PADDLE 1 MOVEMENT
                    // =========================================

                    if (player1_up && !player1_down) begin

                        if (paddle_1 >= 4)
                            paddle_1 <= paddle_1 - 4;
                        else
                            paddle_1 <= 0;

                    end

                    else if (player1_down && !player1_up) begin

                        if (paddle_1 <= 396)
                            paddle_1 <= paddle_1 + 4;
                        else
                            paddle_1 <= 400;

                    end


                    // =========================================
                    // PADDLE 2 MOVEMENT
                    // =========================================

                    if (player2_up && !player2_down) begin

                        if (paddle_2 >= 4)
                            paddle_2 <= paddle_2 - 4;
                        else
                            paddle_2 <= 0;

                    end

                    else if (player2_down && !player2_up) begin

                        if (paddle_2 <= 396)
                            paddle_2 <= paddle_2 + 4;
                        else
                            paddle_2 <= 400;

                    end

                end
            end
        end
    end

endmodule