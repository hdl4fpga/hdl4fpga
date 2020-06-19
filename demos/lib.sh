#!/bin/sh

function write()
{
	echo "${SPEED}"
}

function set_tty()
{ 
	echo Setting serial speed ${SPEED} to port "${TTY}" 1>&2
	stty -F "${TTY}" sane 1>&2
	stty -F "${TTY}" "${SPEED}" cs8 raw -cstopb -parenb -onlcr -ocrnl -onlcr -ofdel -onlret -opost 1>&2
}

function program_device()
{
	if [ "${PROG}" != "" ] ; then
		echo "${PROG}" 1>&2
		$PROG 1>&2
		sleep 1;
	fi
}
