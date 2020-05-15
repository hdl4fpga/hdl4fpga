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

.. _demo.sh: ./demo.sh

.. _Imagemagick: https://imagemagick.org

Imagemagick_ is required to convert *your_image.your_format* to 800x600 RGB8. There is no need to change your image to that format. Imagemagick_ will be called by demo.sh_ script and will do it for you.

Download https://github.com/hdl4fpga/hdl4fpga.github.io/raw/master/demos/graphic/ULX3S/bits/demos_graphic-12F.bit

Open a console on demos directory and run

**IMAGE="*your_image_path*/*your_image.your_format*" PROG="ujprog *your_bit_path*/demos_graphic-12F.bit" TTY="*your_serial_device*" ./demos.sh**

All the **bold text** on the same line

I'm curious : Where is the project file ?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. _demos: ../ULX3S/diamond/demos.ldf

Here you can find the demos_ project file.

Enjoy it!
