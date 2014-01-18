#!/bin/sh
for file in "$@" ;do
	expand --tabs=4 $file |cat ../hdl4fpga.lic - > expand.tmp
	ghdl --pp-html expand.tmp|grep -v small|grep -v expand > ${file%.vhdl}.html
done
