/*********************************************************
This is a bouncing square ball.  
The ball is a square, it bounces off of the walls. 
***********************************************************/ 

//`timescale 1ns / 100ps
`default_nettype none
`include "../verilog/preamble.h"


parameter size = 4;    //Ball size

module Bouncing (input  wire		 move,
                 output reg  signed [yBits:0] top,		
                 output wire signed [xBits:0] right,
                 output wire signed [yBits:0] bottom,
                 output reg  signed [xBits:0] left);
   
   initial top = 0;
   initial left = 0;
      
   reg signed [2:0]   xVelocity = 3'd2;
   reg signed [2:0]   yVelocity = 3'd1;
   
    wire touchesTop =    (top    + yVelocity <= 0);
    wire touchesBottom = (bottom + yVelocity >= height-1);
    wire touchesLeft =   (left   + xVelocity <= 0);
    wire touchesRight =  (right  + xVelocity >= width - 1);

//Increment the top and left side positions based on the velocity.
always @ (posedge move)
  begin
  left <= ((left==0)? -1: 0) + left + xVelocity;
  top  <=  top  + yVelocity;
  end

assign right = (left==0)? (size -1): left + size;   
assign bottom = (top==0)? (size-1):  top + size;
   
//When the ball hits the right or left wall change the xVelocity   
always @(posedge move)
  case ({touchesRight,touchesLeft})
      2'b10: xVelocity <= -3'd2;     
      2'b01: xVelocity <=  3'd2; 
      default xVelocity <= xVelocity;
  endcase // case ({touchesTop,touchesRight,touchesBottom, touchesLeft})
   
//When the ball hits the top or bottom wall, change the yVelocity.    
always @(posedge move)
  case ({touchesTop,touchesBottom})
    2'b10: yVelocity <=  3'd1;
    2'b01: yVelocity <= -3'd1;
    default xVelocity <= xVelocity;    
endcase

// THERE ARE TWO DISPLAYS.  ONE SHOWS THE LOGGING OF EVERY STEP
// THE OTHER DISPLAYS THE BOUNCING SQUARE

   initial 
       begin
       $dumpfile("out.vcd");
       $dumpvars(0, ball);
       $dumpon;
       end





always @(posedge move)
   begin
      $display ("The top of the ball is at: %d",top); 
      $display ("The Left side of the ball is at: %d",left);
      $display ("The Right side of the ball is at: %d",right);           
      $display ("The bottom of the ball is at: %d",bottom);
      $display ("Horizontal velocity is:%d", xVelocity);
      if (touchesLeft)
        $display("The ball is touching the left wall");
      if (touchesRight)
        $display("The ball is touching the right wall");
      $display ("\n");
	  
   end

 
endmodule   
      		       

