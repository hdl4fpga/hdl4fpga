#!/bin/bash

#                                                                            #
# Author(s):                                                                 #
#   Miguel Angel Sagreras                                                    #
#                                                                            #
# Copyright (C) 2015                                                         #
#    Miguel Angel Sagreras                                                   #
#                                                                            #
# This source file may be used and distributed without restriction provided  #
# that this copyright statement is not removed from the file and that any    #
# derivative work contains  the original copyright notice and the associated #
# disclaimer.                                                                #
#                                                                            #
# This source file is free software; you can redistribute it and/or modify   #
# it under the terms of the GNU General Public License as published by the   #
# Free Software Foundation, either version 3 of the License, or (at your     #
# option) any later version.                                                 #
#                                                                            #
# This source is distributed in the hope that it will be useful, but WITHOUT #
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      #
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   #
# more details at http://www.gnu.org/licenses/.                              #
#                                                                            #

TTY="${TTY:-/dev/ttyUSB0}"
SPEED="${SPEED:-3000000}"
PKMODE="STREAM"
DEVFD="${DEVFD:-3}"
STDOUT="YES"
export TTY SPEED PKMODE DEVFD STDOUT HOST

ADDR="${ADDR:-${1}}"
ADDR="${ADDR:-0}"
ADDR="$((${ADDR} | (1 << 31)))"
ADDR=`printf %08x ${ADDR}`
ADDR="${ADDR: -8}"

LENGTH="${LENGTH:-${2}}"
LENGTH="${LENGTH:-0}"
LENGTH=`printf %06x $(( ${LENGTH} ))`
LENGTH="${LENGTH: -6}"
#$echo -n $ADDR ' : '
data=`echo "1702${LENGTH}1603${ADDR}"|xxd -r -ps|./scripts/siocomm.sh |xxd -ps| tr -d '\n'`
data=`echo $data|cut -b 15-`
while [ "$data" != "" ] ; do
	len=`echo -n $data|cut -b 1-2`
	len=`printf %d $(( 0x${len} ))`
	data=`echo -n $data|cut -b 3-`

	len=`expr 2 \* \( $len \+ 1 \)`
	line=`echo -n $data|cut -b 1-$len|tr -d '\n'`
	while [ "$line" != "" ] ; do
		echo -n $line|cut -b 1-32
	    line=`echo -n $line|cut -b 33-|tr -d '\n'`
	done
	len=`expr  $len \+ 3 `
	data=`echo -n $data|cut -b $len-`
done
echo
