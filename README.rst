The code that is on the reposiroty is not working now. You can find the latest stable release following the next link https://github.com/hdl4fpga/hdl4fpga/releases/tag/arty


scopeio : an Embedded Measurement System
========================================

What is it ?
------------

Simulation tools can't help you and you cannot guess what is happening inside
of the FPGA anymore. You need to see it now. You need an Embedded Measurement
System in the FPGA that lets you see as much data as you need using as few
resources as possible.

How it was born
---------------

I found myself in a situation in which I had to debug a high-performance open
source portable DDR Core. I needed to capture a lot of data to see as many
events as possible. There weren¿t just a few signals, but more than sixteen to
understand what was happening. That is how ScopeIO was born.

Its goals were:

- Small footprint to embed it.
- Portability.
- VGA to display data.
- Block RAM requirement only.
- UDP to communicate with the computer.

Small footprint to embed it
~~~~~~~~~~~~~~~~~~~~~~~~~~~

ADSL, DVB-T,  ISDB-T, LTE, WiFi and others are OFDM signals. In those cases, a
self-correlation function should be calculated to know when packets start or
end. That is not difficult to do. However, if the measurement instrument lacks
a self-correlation function it is not possible to trigger the signal at its
boundaries. One can see that it is important that ScopeIO be as small as
possible to embed it in the design to be debugged.

The table below shows the resources used by both implementations that are on
the youtube channel.

================== ======== =================== ================ =========== ========== ===================================
Kit                Channels Samples per Channel Video Resolution FPGA Slices Block Rams Project                            
================== ======== =================== ================ =========== ========== ===================================
Artix-7 35T Arty         9                6400         1920x1080  1791(8.5%)  23.5(47%) arty/vivado/scopeio/scopeio.xpr    
Spartan 3E Starter       2                 960           800x600     710(2%)    17(20%) s3estarter/ise/scopeio/scopeio.xise
================== ======== =================== ================ =========== ========== ===================================

VGA to display data
~~~~~~~~~~~~~~~~~~~

VGA is a well known video standard that is easy to implement, and it is pretty
much available on every monitor. Many monitors that have a DVI port are easy to
connect to a VGA port too through a mechanical adapter. A VGA port needs a
minimum of GND, VSYNC, HSYNC and RGB pins. Four wires are more than enough if
you don¿t mind a monochrome image, or six to have eight colors. But if you have
video dacs in the development kit, ScopeIO can display as many colors as there
are available.

Block RAM requirement only
~~~~~~~~~~~~~~~~~~~~~~~~~~

FPGAs have embedded memory blocks that are fast and easy to use but they are
small compared to dynamic ram. As much as possible, the memory is used to
capture the signal data to display. The memory is not used for video.

UDP to send data to the computer.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Commands to control ScopeIO are sent by UDP/IP. The commands are detected every
time a packet with the corresponding MAC address : ¿00:00:00:01:02:03¿ - not
much imagination there -  is received. A configuration in the PC is required as
described in the video. A simple JavaScript Application controls everything
else. Node,js and Nw.js are required to run it.

Portability
~~~~~~~~~~~

Portability is also one of the main goals. While videos on the channels are for
Xilinx's FPGA kits: Artix-7 35T Arty FPGA Evaluation Kit and Spartan 3E Starter
kit board, ScopeIO is easy to port to other manufactures' devices and kit
boards. You can find a porting to Latticesemi ECP3Versa at
ecp3versa/diamond/ecp3versa.ldf, kit to which I have access.

TODO
~~~~

| [x] Add DDR core to capture high speed data.
| |x] Add data output stream.
| [x] Add Axis within grid as an option.
