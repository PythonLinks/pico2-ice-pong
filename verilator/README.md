# FPGA SIMULATION

Based on what was learned from documenting this code, a slighty different
path is being pursued, so this documentation has not been perfected. 

This is documentation of @Shylie's pico-ice-video code for the purpose of
creating an easy-to-understand pong demo for other developers to use. 

This directory contains a Verilator simulator of the FPGA driving the
RP2040 which drives a usb video device to display on the desktop.
This simulator takes the interchip signals and displays them using a
GUI.

pico-ice-video is a Mandelbrot simulation.  Mandelbrot is a set of
imaginary numbers.  Each point on the graph represents one number.
The x axis is the real part, the y axis is the imaginary part. If a
point on the graph is a Mandelbrot number, the point is displayed, if
not, it is blank.  To debug the Mandelbrot Verilog, both the C++ and
Verilog can generate the mandelbrot numbers, a key press toggles
between them. Any discrepancy in instantly visible.  The details of
the mandelbrot calculations are not covered, but it was important to
understand what he is trying to do.

The top level program creates a frame buffer 256 * 256 * 2 bytes long.
First it does a bunch of initializations, with nice error
messags. Then it starts driving the Verilog.  When the Verilog sends a
`req` signal that means there is valid data, and the single frame buffer
pointer is incremented, and the data is written.  When the frame buffer is full
it is redisplayed, and the frame buffer pointer is reset to 0.  When the FPGA
raises the `fin` value, the simulation ends. 

Here is the top level interface between the two chips. 
	input wire clk,
	input wire dir,
	inout wire req,
	output wire fin,
	inout wire [7:0] data

`dir` is the signal direction.  it starts off at 1 meaning that the RP
chip is sending data to the FPGA. When `dir` = 1, the FPGA I/O ouput
wires go to `z`, and the FPGA calculation ciruitry resets. On the
positive edge of dir, the system is reset, an instruction is
sent to the FPGA. . When `dir <= 0` the FPGA can start transmitting data.
When the FPGA sets `req` to 1, the frame buffer index is incremented,
and the data is stored in the Frame Buffer.  When the index reaches the
end of the frame buffer, the image is redisplayed. 

When `dir && req`, data is written to memory. 


The `req` wire is used to transmit an instuction to the FPGA. When dir
&& req, data can be written from the RP to the FPGA, the FPGA's
`command_buffer` is write enabled and stores the data.

When the FPGA is transmiting data, the RP chip grabs two bytes in two
clock cycles from the FPGA, and loads them into the Frame Buffer.  As
long as the dut-> is 0, the looping continues.  When the frame is
displayed Done <=1.

if (req && req_last)
   the write address is incremented.  Otherwise it goes to 0.

req_last is the previous value of req.

## MANDELBROT NOTES There are currently 4 mandelbrot calculators, and
multiple vectors representing their state.  There is some circuitry
which determins which one claculates which point. Presumably they
calculate the next 4 bits. 
