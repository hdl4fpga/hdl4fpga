#!/bin/sh
stty raw 115200 < /dev/ttyUSB0
while true
do
  # set grid bg black
  /bin/echo -ne "\x00\x00\x11\x5c\x00\x01\x00" > /dev/ttyUSB0
  sleep 1
  # set grid bg yellow
  /bin/echo -ne "\x00\x00\x11\x5c\x00\x61\x00" > /dev/ttyUSB0
  sleep 1
done
