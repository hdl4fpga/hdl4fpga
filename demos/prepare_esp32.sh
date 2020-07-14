#!/bin/sh
IMAGE=$1
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


echo Converting "${IMAGE}" to "${WIDTH}" pixel wide for ESP32 1>&2
convert -resize "${WIDTH}" -size "${WIDTH}" "${IMAGE}" rgb:- |./bin/rgb8topixel -r -f ${PIXEL} > $2
