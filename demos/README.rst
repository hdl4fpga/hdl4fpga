upload-image.sh
---------------

What it does ?
~~~~~~~~~~~~~~

Loads and image on SDRAM throught the serial port and displays it using the HDMI.

ULX3S
-----

What do I need to run it ?
~~~~~~~~~~~~~~~~~~~~~~~~~~

On UN*X
~~~~~~~

.. _upload-image.sh: ./upload-image.sh

.. _Imagemagick: https://imagemagick.org

Imagemagick_ is required to convert *your_image.your_format* to 800x600 RGB8. There is no need to change your image to that format. Imagemagick_ will be called by upload-image.sh_ script and will do it for you.

200 MHz SDR RAM 3000000 bps UART
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Download https://github.com/hdl4fpga/hdl4fpga.github.io/raw/master/demos/graphic/ULX3S/bits/demos_graphic-12F200MHz-3000000bps.bit

**IMAGE="your_image_path/your_image.your_format" PROG="ujprog your_bit_path/demos_graphic-12F200MHz-3000000bps.bit" TTY="your_serial_device" ./upload-image.sh**

Open a console on demos directory and run

Remember that all the **bold text** should be on the same line

motion.sh
---------

.. _motion.sh: ./motion.sh

.. _Imagemagick: https://imagemagick.org

.. _ffmpeg: https://ffmpeg.org/

ffmpeg_ is required to convert *your_motion.your_format* not image frames and Imagemagick_ is required to the images frames to 800x600 RGB8.

200 MHz SDR RAM 3000000 bps UART
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Download https://github.com/hdl4fpga/hdl4fpga.github.io/raw/master/demos/graphic/ULX3S/bits/demos_graphic-12F200MHz-3000000bps.bit

**MOTION="your_motion_path/your_motion.your_format" PROG="ujprog your_bit_path/demos_graphic-12F200MHz-3000000bps.bit" TTY="your_serial_device" ./motion.sh**

Open a console on demos directory and run

Remember that all the **bold text** should be on the same line

I'm curious : Where is the project file ?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. _demos: ../ULX3S/diamond/demos.ldf

Here you can find the demos_ project file.

Enjoy it!
