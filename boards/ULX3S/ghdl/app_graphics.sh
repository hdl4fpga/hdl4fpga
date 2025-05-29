#!/bin/bash
if [ !  -e work ] ; then
	mkdir work
fi

pushd ../../../library/ghdl && ./hdl4fpga.sh  && ./ecp5sh  
popd
for file in \
"../common/ulx3s.vhd" \
"../apps/graphics.vhd" \
; do 
	if ghdl -a --std=02 -P../../../library/ghdl/ecp5u -P../../../library/ghdl/hdl4fpga --workdir=./work --work=work $file ; then
		echo $file
	else
		exit
	fi
done

exit

