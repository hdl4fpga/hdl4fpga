#!/bin/bash

# Copyright (c) <2015> <Miguel Angel Sagreras>                                    #
#                                                                                 #
# Permission is hereby granted, free of charge, to any person obtaining a copy of #
# this software and associated documentation files (the "Software"), to deal in   #
# the Software without restriction, including without limitation the rights to    #
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies   #
# of the Software, and to permit persons to whom the Software is furnished to do  #
# so, subject to the following conditions:                                        #
#                                                                                 #
# The above copyright notice and this permission notice shall be included in all  #
# copies or substantial portions of the Software.                                 #
#                                                                                 #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR i    #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,        #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE     #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER          #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,   #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE   #
# SOFTWARE.                                                                       #
#                                                                                 #

TTY="${TTY:-/dev/ttyUSB0}"
SPEED="${SPEED:-3000000}"
DEVFD="${DEVFD:-1}"
SETUART="${SETUART:-YES}"

if [ "${LOG}" == "YES" ] ; then
	LOG="-l 3"
fi

if [ "$HOST" != "" ] ; then
	if [ "${PKMODE}" == "" ] ; then
		(eval "exec ./bin/siosend -h ${HOST} ${LOG} ${@} -p")
	elif [ "${PKMODE}" == "PKT" ] ; then
		(eval "exec ./bin/siosend -h ${HOST} ${LOG} ${@} -p")
	else
		(eval "exec ./bin/siosend -h ${HOST} ${LOG} ${@}")
	fi
elif [ "$USBDEV" != "" ] ; then
	if [ "${PKMODE}" == "" ] ; then
		(eval "exec ./bin/siosend -u ${USBDEV} ${LOG} ${@} -p")
	elif [ "${PKMODE}" == "PKT" ] ; then
		(eval "exec ./bin/siosend -u ${USBDEV} ${LOG} ${@} -p")
	else
		(eval "exec ./bin/siosend -u ${USBDEV} ${LOG} ${@}")
	fi
else
	if [ "${SETUART}" == "YES" ] ; then
		export TTY SPEED
		./scripts/setuart.sh
	fi
	if [ "${PKMODE}" == "" ] ; then
		(eval "exec ${DEVFD}<>${TTY} ./bin/siosend  ${LOG} ${@} -p")
	elif [ "${PKMODE}" == "PKT" ] ; then                   
		(eval "exec ${DEVFD}<>${TTY} ./bin/siosend  ${LOG} ${@} -p")
	else                                                  
		(eval "exec ${DEVFD}<>${TTY} ./bin/siosend  ${LOG} ${@}")
	fi
fi
