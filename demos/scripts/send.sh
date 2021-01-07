#!/bin/sh
TTY="${TTY:-/dev/ttyUSB0}"
SPEED="${SPEED:-3000000}"

if [ "$HOST" == "" ] ; then
	export TTY SPEED
	./scripts/setuart.sh
	if [ "${PKMODE}" == "" ] ; then
		(exec 1<>${TTY} ./bin/sendbyahdlc -p)
	elif [ "${PKMODE}" == "PKT" ] ; then
		(exec 1<>${TTY} ./bin/sendbyahdlc -p)
	else
		(exec 1<>${TTY} ./bin/sendbyahdlc)
	fi
fi
