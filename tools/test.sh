#!/bin/sh
XFR=`which "${XFR:-cat}"`
TTY="${TTY:-/dev/ttyUSB0}"
IMAGE="${IMAGE:-./dataset/image.png}"
SIZE="${SIZE:-800x600}"
BASE="${BASE:-./}"

if [ ! -f "${IMAGE}" ] ; then
	echo Image file "${IMAGE}" not found ;
	exit -1
fi

if [ ! -f "${IMAGE}" ] ; then
	echo Image file "${IMAGE}" not found ;
	exit -1
fi

if [ ! -c "${TTY}" ] ; then
	echo Serial port "${TTY}" not found
	exit -1
fi

if [ ! -f "${XFR}" ] ; then
	echo Binary transfer "${XFR}" no found
	exit -1
fi

echo Converting "${IMAGE}" to "${SIZE}" RGB8
convert -resize "${SIZE}" -size "${SIZE}" "${IMAGE}" ./dataset/image.rgb
make
echo Setting serial port "${TTY}"
stty -F  "${TTY}" sane
stty -F  "${TTY}" 115200 cs8 -cstopb -parenb raw -onlcr
sleep 1
echo Blanking screen 
$XFR < ./dataset/blank.strm > "${TTY}"
sleep 1
echo Sending to "${TTY}"
$XFR < ./dataset/image.strm > "${TTY}"
