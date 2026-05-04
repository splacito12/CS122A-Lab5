module top (
    /** Input Ports */
    input CLK,

    /** Output Ports */
    output LCD_CLK,
    output LCD_DEN,
    output [4:0] LCD_R,
    output [4:0] LCD_G,
    output [4:0] LCD_B,
);

/** Logic */

//the parameters for the horizontal(x) and vertical(y) axis have been given
/*
    Parameter	            Horizontal	    Vertical
    Active region	        480 pixels	    272 lines
    Buffer Region	        45 clocks	    13 lines
    Total per line/frame	525 clocks	    285 lines
*/
parameter active_x = 480;
parameter totFrame_x = 526; //we have to consider 0 as well. 
parameter active_y = 272;
parameter totFrame_y = 286; //we have to consider 0 as well

reg [9:0] x_cnt = 0;
reg [9:0] y_cnt = 0;

assign LCD_CLK = CLK;

always @(posedge CLK) begin
    if(x_cnt < totFrame_x - 1) begin
        x_cnt <= x_cnt + 1;
    end else begin
        x_cnt <= 0;
        if(y_cnt < totFrame_y - 1) begin
            y_cnt <= y_cnt + 1;
        end else begin
            y_cnt <= 0;
        end
    end
end

//Display Enable (DE)
//only high during active. So, we have to make sur ethe axis cnt is less than the active region.
assign LCD_DEN = (x_cnt < active_x) && (y_cnt < active_y);

//Color encoding
/* - we have to make sure that its in active region
   - Since we have a width of 480 and we need 3 regions, we divide by 3 and get 160.
   - Following the ST7735 table:
        1. Red: assigned the lower bits (when its < 160)
        2. Green: assigned the middle bits (when its < 320)
        3. Blue: assigned the upper bits (when its >= 320)
*/
if(LCD_DEN) begin
    if(x_cnt < 160) begin
        LCD_R = 5'd31;
        LCD_G = 6'd0;
        LCD_B = 5'd0;
    end else if(x_cnt < 320) begin
        LCD_R = 5'd0;
        LCD_G = 6'd63;
        LCD_B = 5'd0;
    end else begin
        LCD_R = 5'd0;
        LCD_G = 6'd0;
        LCD_B = 5'd31;
    end
end


endmodule