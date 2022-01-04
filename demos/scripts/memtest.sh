#!/bin/bash
TTY="${TTY:-/dev/ttyUSB0}"
SPEED="${SPEED:-3000000}"
DEVFD="${DEVFD:-3}"
SETUART="YES"
STDOUT="YES"
export TTY SPEED PKMODE DEVFD SETUART STDOUT

if [ "${STDOUT}" == "NO" ] ; then
	STDOUT="-o"
else
	unset STDOUT
fi

if [ "${LOG}" == "YES" ] ; then
	LOG="-l 3"
fi

if [ "$HOST" == "" ] ; then
	if [ "${SETUART}" == "YES" ] ; then
		export TTY SPEED 
		./scripts/setuart.sh
	fi
	(eval "exec ${DEVFD}<>${TTY} ./bin/memtest  ${LOG} ${STDOUT} ${@}")
else
	(eval "exec ./bin/memtest -h ${HOST} ${LOG} ${STDOUT} ${@}")
fi
