# Pico Ice Video

This repository displays a 320 x180 video signal from the Pico Ice FPGA on the
desktop computer, over USB, using the USB Video Device Class (UVC).
You can then take screenshots, record the video, or use it as a demo
during a Zoom call.

## LIMITATIONS

There are three different limiting factors on how large an image this can generate. 

- **USB Bandwidth:** on the RP2040 is limited to 480 Mhz.  In practice less is achievable. A display image of 320*180 * 60 FPS requires a bandwidth of 3,450,000 Hz, so this is not the limiting factor. 

- **FPGA Memory:** 320 *180 pixels requries 57,600 pixels, but the 4 SPRAM blocks have 1 Megabit, so this is not the limiting factor.

- **FPGA<->RP2040 Bandwidth:** There is an 8 bit bus between the two two chips, running at 48Mhz.  Almost 500Mhz, so this is not the limiting factor. 

- **FPGA Loops:*  The code is doing 255 iterations per pixel per frame.  Maybe there are 4 Mandlebrot generators.   It is not clear if the Mandlebrot is being continusously updated, or just generated once. 

Here is the [FPGA interface](https://git.shylie.info/shylie/pico-ice-video/src/branch/main/ice/mandelbrot/source/impl_1/top.sv). There is a start wire, really that is the vertical sync signal.  There are 8 bits of data that get sent to the RP2040.  The RP2040 reads the data
using PIO, writes the data to the inactive frame buffer using direct
memory access.  Meanwhile the TinyUSB library is writing uncompressed
data to the desktop over USB using the active frame buffer.  The
RP2040 sysclk runs at120 MHz, the clkdiv for the pio is 2.5 and the
FPGA runs at 48Mhz.  The image size is 320 * 180.  The next version of
the Pico-Ice will have the RP2350 Chip which will also support a
higher resolution HDMI output. 

This software is based on the [Tiny video USB Capture example](
https://github.com/hathach/tinyusb/tree/master/examples/device/video_capture).
UVC does not need to be fully synchronous: there is no timing to
keep-up with: if you send the frame sometimes slow sometimes fast, it
is fine.  In particular if using BULK (throw data in like it's a
truck) endpoint rather than ISOCHRONOUS (always same time
interval...)

There is a verilator simulator with a graphics display, so that one can debug the whole system on the desktop. 

## Contact

If you have questions, first please search the Pico Ice discord
server, and then ask.  This is a private repository, to make
contributions, please post your branch somewhere and notify the author
@shylie on the Pico Ice Discord server.

## Development

This application uses the Lattice Radiant Tools, so it may not work with YOSYS.  In particular there are two constraints files, which I suspect are not supported by YOSYS. 

## INSTALLATION

To install it on linux , [put the Pico-Ice into install mode](
https://pico-ice.tinyvision.ai/md_programming_the_mcu.html )

Using the command

picocom) --baud 1200 /dev/ttyACM0

Then drag the executable onto the RP2040 drive on the desktop. 

## TO DO

**Implement compression**.  There are lower complexity compression
  techniques,PEG-XS seems to be one of the newer standards thats meant
  for low latency and reasonable compression. This may be doable with
  the RPi in FW. Doubt MJPG is possible for larger frames as that
  requires multiple frames to be in memory.

**Free UP SPI and UART pins** The interface requires 9 pins.  There
  are 8 RP2040<->FPGA pins, so one of the spi pins is also used. One
  could solder a pin between the FPGA and RP2040 and preserve the SPI
  bus.  Better yet, solder 3 pins and preserve both the SPI bus, and
  the default part. 

## Special Thanks

Christopher Lozinski (@clozinski) - wrote this README file. Thank you!
josuah (@josuah.demangeon) - helped answer questions during the development of this project
venkat_tv (@venkat_tv) - developed the pico-ice hardware