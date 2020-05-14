Graphic
-------


What it does ?
~~~~~~~~~~~~~~

Loads and image on SDRAM throught the serial port and displays it using the HDMI.

ULX3S
-----

What do I need to run it ?
~~~~~~~~~~~~~~~~~~~~~~~~~~

On UN*X
~~~~~~~

Install Imagemagick https://imagemagick.org to convert *your_image.your_format*

Download https://github.com/hdl4fpga/hdl4fpga.github.io/raw/master/demos/graphic/ULX3S/bits/demos_graphic-12F.bit

Open a console on demos directory and run

IMAGE="*your_image_path*/*your_image.your_format*" PROG="ujprog *your_bit_path*/demos_graphic-12F.bit" ./demos.sh

I'm curious : Where is the project file ?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

https://github.com/hdl4fpga/hdl4fpga/blob/work/ULX3S/diamond/demos.ldf

Enjoy it!
