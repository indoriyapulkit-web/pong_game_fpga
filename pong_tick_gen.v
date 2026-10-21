module pong_tick_gen(
    input clk,rst,
    output reg pong_tick
    );
    reg [19:0] counter;
    always@(posedge clk or posedge rst)begin
        if(rst) begin
            pong_tick<=0;
            counter<=0;
        end
        else begin
            if(counter>=833333)begin
                pong_tick<=~pong_tick;
                counter<=0;
            end
            else 
                counter<=counter+1;  
        end
    end
endmodule
