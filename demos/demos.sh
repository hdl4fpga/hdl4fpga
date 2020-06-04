#!/bin/sh
XFR=`which "${XFR:-cat}"`
TTY="${TTY:-/dev/ttyUSB0}"
WIDTH="${WIDTH:-800}"
SPEED="${SPEED:-115200}"
PROG="${PROG}"
PIXEL="${PIXEL:-rgb565}"
WSIZE="${WSIZE:-16}"
BSIZE="${BSIZE:-128}"
BADDR="${BADDR:-0x0}"

if [ "${IMAGE}" = "" ] ; then
	echo Image filename empty
	exit -1
fi

if [ ! -f "${IMAGE}" ] ; then
	echo Image file "${IMAGE}" not found ;
	exit -1
fi

echo make
make all

if [ "${PROG}" != "" ] ; then
	echo "${PROG}"
	$PROG
	sleep 1;
fi

convert_image ()
{
	convert -resize "${WIDTH}" -size "${WIDTH}" "${IMAGE}" rgb:- |./bin/rgb8topixel -f ${PIXEL}|./bin/format -b "${BSIZE}" -w "${WSIZE}"
}

if [ "$HOST" == "" ] ; then

	if [ ! -c "${TTY}" ] ; then
		echo Serial port "${TTY}" not found
		exit -1
	fi

	if [ ! -f "${XFR}" ] ; then
		echo Binary transfer "${XFR}" no found
		exit -1
	fi

	echo Setting serial port "${TTY}"
	stty -F  "${TTY}" sane
	stty -F  "${TTY}" "${SPEED}" cs8 -cstopb -parenb raw -onlcr
	sleep 1

	echo Blanking screen 
	./bin/stream < ./src/blank.pkt|$XFR > "${TTY}"
	sleep 1

	echo Converting "${IMAGE}" to "${WIDTH}" pixel wide and sending it to "${TTY}"
	convert_image|./bin/stream|$XFR > "${TTY}"

else

#	echo Blanking screen 
#	./bin/sendbyudp -h ${HOST} < ./src/blank.pkt
#	sleep 1

	echo Converting "${IMAGE}" to "${WIDTH}" pixel wide and sending it to "${HOST}"
	convert_image|./bin/sendbyudp -b "${BADDR}" -h "${HOST}"

fi


