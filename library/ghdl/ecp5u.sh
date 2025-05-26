#!/bin/bash
if [ !  -e ecp5u ] ; then
    mkdir ecp5u
fi

for file in \
"./ecp5u_components.vhd" \
; do 
	if ghdl -a --std=02 --workdir=ecp5u --work=ecp5u $file ; then
		echo $file
	else
		exit
	fi
done
