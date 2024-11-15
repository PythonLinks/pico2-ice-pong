/*********************************************************
This is a bouncing square ball.  
The ball is a square, it bounces off of the walls. 
x and column are measured left to right
y and row are measured top to bottom. 
***********************************************************/ 

`include "../verilog/preamble.h"

//parameter width = 320;  //Screen width
//parameter height = 180; //Screen height

parameter width = 20;  //Screen width
parameter height = 10; //Screen height

parameter xBits = $clog2(width); //Number of bits for x Position
parameter yBits = $clog2(height); //Number of bits for yPositin 

`include "../verilog/bouncing.v"
`include "../verilog/screen.v"

module tb();
   reg clock;
   reg reset;
   
   wire  signed [yBits: 0] top;   //Top side of block
   wire  signed [xBits: 0] right; //Right side of block
   wire  signed [yBits: 0] bottom;//Bottom side of block   
   wire  signed [xBits: 0] left;  //Leftside of block
   wire		     move;  //Move the block
   wire		     signal;
    
   always #10 clock = ~clock; 
 
   Bouncing ball(.move(move),
		 .top(top),
		 .right(right),
		 .bottom(bottom),
                 .left(left)
);
   
   
   Screen window (.clock(clock),
		   .reset(reset),
		   .top(top),
   		   .right(right),
		   .bottom(bottom),		  
		   .left(left),
		   .move(move),
                   .signal(signal));
   
 
initial begin
   clock = 0;
   reset = 0;
   #20 reset = 1;
   #10 reset = 0;
   #10000000 $finish;
   end
     
endmodule


