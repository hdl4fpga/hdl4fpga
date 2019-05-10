#!/bin/sh
SEDSCRIPT="s#hdl4fpga[.]#work.#1"
exec sed --in-place=".bak" -e $SEDSCRIPT $1
