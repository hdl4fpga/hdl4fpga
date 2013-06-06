#! /usr/bin/env python
import sys

#		print hex(b), ' ', hex(a), ' ',  hex(c),  n
n = 0
for line in sys.stdin:
	x = int(line.strip(), 0)
	if x >= 32768:
		x = x-65536
	print "%8d %4d " % (n, x)
	n = n + 1
