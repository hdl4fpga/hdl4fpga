#!/bin/sh
SCRIPTDIR=../../../
REPLACER=./change-inplace-hdl4fpga-to-work.sh
#REPLACER=ls
find $SCRIPTDIR -type f -name "*.vhd" -exec $REPLACER {} \;
