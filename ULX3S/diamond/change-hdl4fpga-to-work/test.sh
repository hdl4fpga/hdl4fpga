#!/bin/sh
SEDSCRIPT="s#hdl4fpga[.]#work.#1"
sed -e $SEDSCRIPT < ../../../library/common/btod.vhd
