# Pico2-Ice Pong Demo

The goal of this project is to drive the pico2-ice RP2350 DVI output from the FPGA. 

This is a bouncing square ball.  It bounces off of the walls. 
It currently works in Verilator test bench mode with ascii display. 
It shifts over 1 pixel and up 2 pixels or vice
versa on every clock tick.  No need for memory access.  It should be
quite fast, and quite simple.

It can be developed in several stages.

- A simple test bench. (Working)
- Drive @shylie’s verilattor graphics code.
- On the FPGA, drive @Shylie’s firmware.
- Potentially drive @xarks FPGA DVI output.

Once it is working, those who are good at firmware can use it to drive
the HDMI.  Later it can be expanded to do color.   

## INSTALLATION

First install iVerilog.  Then run the following commands. 

```
git clone https://github.com/PythonLinks/pico2-ice-pong
cd pico2-ice-pong
./run
```
