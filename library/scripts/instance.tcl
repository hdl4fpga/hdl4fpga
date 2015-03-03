#!/usr/bin/tclsh

array set arg $::argv; 
set temp [open $arg(1) r]
set data [read temp ]
regsub -all ({%byte%})FS($argv[2]) $data "" data 
puts $data
