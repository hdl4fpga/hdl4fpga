#!/bin/bash
TTY="${TTY:-/dev/ttyUSB0}"
SPEED="${SPEED:-3000000}"
DEVFD="${DEVFD:-1}"

if [ "$HOST" == "" ] ; then
	export TTY SPEED
	./scripts/setuart.sh
	if [ "${PKMODE}" == "" ] ; then
		(eval "exec ${DEVFD}<>${TTY} ./bin/sendbyahdlc -p")
	elif [ "${PKMODE}" == "PKT" ] ; then
		(eval "exec ${DEVFD}<>${TTY} ./bin/sendbyahdlc -p")
	else
		(eval "exec ${DEVFD}<>${TTY} stdbuf -i0 -o0 -e0 ./bin/sendbyahdlc")
	fi
fi
