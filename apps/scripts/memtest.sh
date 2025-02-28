#!/bin/sh
# Copyright (c) 2015 Miguel Angel Sagreras                                       #
#                                                                                #
# Permission is hereby granted, free of charge, to any person obtaining a copy   #
# of this software and associated documentation files (the "Software"), to deal  #
# in the Software without restriction, including without limitation the rights   #
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      #
# copies of the Software, and to permit persons to whom the Software is          #
# furnished to do so, subject to the following conditions:                       #
#                                                                                #
# The above copyright notice and this permission notice shall be included in all #
# copies or substantial portions of the Software.                                #
#                                                                                #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  #
# SOFTWARE.                                                                      #
#                                                                                #

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




