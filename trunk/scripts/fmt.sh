#!/bin/sh
for file in "$@" ;do
	expand --tabs=4 $file |cat ../tmplt/header.tlt - > expand.tmp
	ghdl --pp-html expand.tmp|grep -v small|grep -v expand > ${file%.vhdl}.html
done
