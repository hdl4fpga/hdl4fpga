#!/bin/sh
for file in *.svg ; do
	inkscape -D -z --file=$file  --export-eps=${file%.svg}.eps
done
