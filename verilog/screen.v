`include "../verilog/preamble.h"

module Screen(input wire clock,
	       input wire	       reset,
	       input wire signed [yBits: 0] top, 
	       input wire signed [xBits: 0] right,
	       input wire signed [yBits: 0] bottom, 
	       input wire signed [xBits: 0] left,
	       output reg	       move,
               output wire	       signal);
    reg [xBits:0] row;
    reg [yBits:0] column;   

   always @(posedge clock, posedge reset)
     if (reset)
       begin
       row <= 0;
       column <=0;
       end
     	  
     //At the end of a row
   else if (lastColumn)
       begin
       column <= 0;

       //If it is the last row, set the row to 0
       if (row >= height - 1)
          row <= 0;
       else //Increment the row.
	 row <= row + 1;
       end     
   else //It is not the last column
        column <= column + 1; //There is NO += in Yosys, or is there

always @(posedge clock)
   if (lastColumn & lastRow)
     move <= TRUE;
   else
     move <= FALSE;

   wire	displayPixel;

    //If the pixel is withing the box, then display Pixel = TRUE;   
    assign displayPixel = (row <= bottom-1) &
                          (row >= top) &
                          (column >= left) &
                          (column <= right-1);
   
   wire lastColumn = (column == width -1) ;
   wire lastRow = (row == height -1);

always @(posedge clock)   
  begin
  if (displayPixel)
    $write ("O");
  else 
        
  $write (".") ;
     
 
  //At the end of the page, add a few blank lines.
  if (column >= width -1) 
        $display(); //START a new line
  end 
   
endmodule   
