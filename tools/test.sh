#!/bin/sh
ujprog ../ULX3S/diamond/graphics/demos_graphics.bit
sleep 1
stty -F /dev/ttyUSB0 115200 cs8 -cstopb -parenb
sleep 1
bin-xfr -i dataset/black.strm -o /dev/ttyUSB0
sleep 1
bin-xfr -i dataset/iguazu.strm -o /dev/ttyUSB0
