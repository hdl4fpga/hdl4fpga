#!/bin/sh
#stty raw 115200 < /dev/ttyUSB0
while true
do
  # set grid bg green
  /bin/echo -ne "\x11\x01\x01\x02" | socat - UDP-SENDTO:192.168.18.186:57001
  sleep 1
  # set grid bg red
  /bin/echo -ne "\x11\x01\x02\x02" | socat - UDP-SENDTO:192.168.18.186:57001
  sleep 1
done
