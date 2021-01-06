#!/bin/sh
TTY="${TTY:-/dev/ttyUSB0}"
SPEED="${SPEED:-3000000}"

echo make 1>&2
make all 1>&2

if [ "$HOST" == "" ] ; then
	export TTY SPEED
	./scripts/setuart.sh
	(exec 1<>${TTY} ./bin/sendbyahdlc -p)
fi
