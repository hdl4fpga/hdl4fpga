#! /usr/bin/env python
import sys

#		print hex(b), ' ', hex(a), ' ',  hex(c),  n
n = 1
a = int(sys.stdin.readline(), 0)
c = 0
b = 0
for line in sys.stdin:
	c = b
	a = b
	b = int(line.strip(), 0)
	n = n+1
	a = ((a+1)%65536)
	if a != b:
		print "%04x %04x %04x %d" % (b, a, c, n)
