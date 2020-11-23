#!/bin/sh
XFR=`which "${XFR:-cat}"`
TTY="${TTY:-/dev/ttyUSB0}"
WIDTH="${WIDTH:-800}"
SPEED="${SPEED:-3000000}"
PROG="${PROG}"
PIXEL="${PIXEL:-rgb565}"
WSIZE="${WSIZE:-16}"
BSIZE="${BSIZE:-256}"
BADDR="${BADDR:-0x0}"
BLANK="${BLANK:-YES}"

if [ "${IMAGE}" = "" ] ; then
	echo Image filename empty
	exit -1
fi

if [ ! -f "${IMAGE}" ] ; then
	echo Image file "${IMAGE}" not found 1>&2
	exit -1
fi

echo make 1>&2
make all 1>&2

if [ "${PROG}" != "" ] ; then
	echo "${PROG}" 1>&2
	$PROG 1>&2
	sleep 1;
fi

DESTINATION=${HOST}
if [ "$HOST" == "" ] ; then

	DESTINATION=${TTY}
	if [ ! -c "${TTY}" ] ; then
		echo Serial port "${TTY}" not found 1>&2
		exit -1
	fi

	if [ ! -f "${XFR}" ] ; then
		echo Binary transfer "${XFR}" no found 1>&2
		exit -1
	fi

	echo Setting serial speed ${SPEED} to port "${TTY}" 1>&2
	stty -F  "${TTY}" sane 1>&2
	stty -F  "${TTY}" "${SPEED}" cs8 raw -cstopb -parenb -onlcr -ocrnl -onlcr -ofdel -onlret -opost 1>&2

	sleep 1
fi

send_data()
{
	if [ "$HOST" == "" ] ; then
		./bin/bundle -b "${BADDR}"|./bin/stream|$XFR > "${TTY}"

	else
		./bin/bundle -b "${BADDR}" -p|./bin/sendbyudp -p -h "${HOST}"
#		./bin/bundle -b "${BADDR}" -p > out.raw
	fi
}

convert_image ()
{
	convert -resize "${WIDTH}" -size "${WIDTH}" "${IMAGE}" rgb:- |./bin/rgb8topixel -f ${PIXEL}|./bin/format -b "${BSIZE}" -w "${WSIZE}"
}

#if [ "${BLANK}" == "YES" ] ; then
#	echo Blanking screen  1>&2
#	cat src/blank.hex|xxd -r -ps|send_data
#	sleep 1
#fi

echo Converting "${IMAGE}" to "${WIDTH}" pixel wide and sending it to "${DESTINATION}" 1>&2
time convert_image|send_data
