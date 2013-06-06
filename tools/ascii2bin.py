#! /usr/bin/env python
import sys
import struct

for line in sys.stdin:
	data = int(line.strip(), 0)
	if data > 32768:
		data -= 65536
	sys.stdout.write(struct.pack('i',data));
