Demos
=====

On UN*X
-------

ULX3S
-----

Graphic
-------

What it does ?
~~~~~~~~~~~~~~

Load and image on SDRAM throught serial port and dispaly it by HDMI.

How is it loaded ?
~~~~~~~~~~~~~~~~~~

Download https://github.com/hdl4fpga/hdl4fpga.github.io/raw/master/demos/graphic/ULX3S/bits/demos_graphic-12F.bit

Open a console on demos directory and run

IMAGE="~/*your_image_path*/*your_image*.*your_format*" PROG="ujprog *your_bit_path*/demos_graphic-12F.bit" ./demos.sh

Enjoy it!
