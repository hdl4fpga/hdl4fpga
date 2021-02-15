#!/bin/bash
TTY="${TTY:-/dev/ttyUSB0}"
SPEED="${SPEED:-3000000}"
DEVFD="${DEVFD:-1}"
SETUART="${SETUART:-YES}"
STDOUT="${STDOUT:-NO}"

if [ "${STDOUT}" == "NO" ] ; then
	STDOUT="-o"
fi

if [ "$HOST" == "" ] ; then
	if [ "${SETUART}" == "YES" ] ; then
		export TTY SPEED
		./scripts/setuart.sh
	fi
	if [ "${PKMODE}" == "" ] ; then
		(eval "exec ${DEVFD}<>${TTY} ./bin/sioahdlc ${STDOUT} ${@} -p")
	elif [ "${PKMODE}" == "PKT" ] ; then
		(eval "exec ${DEVFD}<>${TTY} ./bin/sioahdlc ${STDOUT} ${@} -p")
	else
		(eval "exec ${DEVFD}<>${TTY} ./bin/sioahdlc ${STDOUT} ${@}")
	fi
else
	if [ "${PKMODE}" == "" ] ; then
		(eval "exec ./bin/sioahdlc -h ${HOST} ${STDOUT} ${@} -p")
	elif [ "${PKMODE}" == "PKT" ] ; then
		(eval "exec ./bin/sioahdlc -h ${HOST} ${STDOUT} ${@} -p")
	else
		(eval "exec ./bin/sioahdlc -h ${HOST} ${STDOUT} ${@}")
	fi
fi
