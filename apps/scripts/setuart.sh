#!/bin/sh
TTY="${TTY:-/dev/ttyUSB0}"
SPEED="${SPEED:-3000000}"

if [ ! -c "${TTY}" ] ; then
	echo Serial port "${TTY}" not found 1>&2
	exit -1
fi

echo Setting serial speed ${SPEED} to port "${TTY}" 1>&2
stty -F  "${TTY}" sane 1>&2
stty -F  "${TTY}" "${SPEED}" cs8 raw -echo -cstopb -parenb -onlcr -ocrnl -onlcr -ofdel -onlret -opost 1>&2
