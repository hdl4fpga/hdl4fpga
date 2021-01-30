#!/bin/bash
TTY="${TTY:-/dev/ttyUSB0}"
SPEED="${SPEED:-3000000}"
DEVFD="${DEVFD:-1}"
SETUART="${SETUART:-YES}"

if [ "$HOST" == "" ] ; then
	if [ "{SETUART}" == "YES" ] ; then
		export TTY SPEED
		./scripts/setuart.sh
	fi
	if [ "${PKMODE}" == "" ] ; then
		(eval "exec ${DEVFD}<>${TTY} ./bin/sendbyahdlc -p")
	elif [ "${PKMODE}" == "PKT" ] ; then
		(eval "exec ${DEVFD}<>${TTY} ./bin/sendbyahdlc -p")
	else
		(eval "exec ${DEVFD}<>${TTY} ./bin/sendbyahdlc")
	fi
fi
