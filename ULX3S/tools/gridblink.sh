#!/bin/sh
stty raw 115200 < /dev/ttyUSB0
while true
do
  # set grid bg green
  /bin/echo -ne "\x00\x00\x11\x01\x01\x01\x00" > /dev/ttyUSB0
  sleep 1
  # set grid bg red
  /bin/echo -ne "\x00\x00\x11\x01\x02\x01\x00" > /dev/ttyUSB0
  sleep 1
done
