#!/bin/sh
TTY="${TTY:-/dev/ttyUSB0}"
make
ujprog ../ULX3S/diamond/graphics/demos_graphics.bit
sleep 1
stty -F /dev/ttyUSB0 115200 cs8 -cstopb -parenb raw -onlcr
sleep 1
cat ./dataset/blank.strm > "${TTY}"
sleep 1
cat ./dataset/image.strm > "${TTY}"
