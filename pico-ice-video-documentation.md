There are 4 modules on the FPGA.   Multiplier, unsurprisingly, multiplies two 16 bit numbers, returns a 32 bit number. 

Renderer generates the Mandelbrot.  Without understanding Mandelbrot it is a bit tricky. 

SPRAM.sv This represents a single spram.  It has a 14 bit address, 16 bits of write and read data and a 4 bit write enable.  It looks like he limits the writing to 4 bits at a time.   spram_big.sv.  This represents a single large memory made out of 4 sprams. It has 4 sixteen bit signals going in and one sixteen bit signal going out.  The address is also 16 bits.  14 bits determine the address for each of the SPRAMs, the last 2 bits determine which SPRAM will be read.  Note that there is a 16 bit data_out, and 4 x 16 bit datas_out.   There are 4 x 4 bit write enable input.  Each  spram gets its own 4 bit write enable..  

