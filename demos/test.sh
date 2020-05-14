#!/bin/sh
XFR=`which "${XFR:-cat}"`
TTY="${TTY:-/dev/ttyUSB0}"
IMAGE="${IMAGE:-./dataset/image.png}"
SIZE="${SIZE:-800x600}"
PROG="${PROG:-./}"

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

echo Making command to process RGB8 image
make

echo Setting serial port "${TTY}"
stty -F  "${TTY}" sane
stty -F  "${TTY}" 115200 cs8 -cstopb -parenb raw -onlcr
sleep 1
echo Blanking screen 
$XFR < ./data/blank.strm > "${TTY}"
sleep 1
echo Converting "${IMAGE}" to "${SIZE}" and sending to "${TTY}"
convert -resize "${SIZE}" -size "${SIZE}" "${IMAGE}" rgb:- |./bin/rgb8to16bpp|./bin/stream|$XFR > "${TTY}"
