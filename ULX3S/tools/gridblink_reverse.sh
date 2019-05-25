#!/bin/sh
echo "if this works then scopeio is wrong, it reverses bit order of serial data"
stty raw 115200 < /dev/ttyUSB0
while true
do
  # set grid bg green
  /bin/echo -ne "\x00\x00\x88\x80\x80\x00" > /dev/ttyUSB0
  sleep 1
  # set grid bg red
  /bin/echo -ne "\x00\x00\x88\x80\x40\x00" > /dev/ttyUSB0
  sleep 1
done
