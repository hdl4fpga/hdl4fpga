#!/usr/bin/env python

import sys
import struct
import re

ddra = []
n = ""
for k in p:
	m = re.match("(\w+\D)(\d+)\s", k['net'])
	if m: 
		if n == m.group(1) :
			ddra.append(k['loc'])
		else :
			if n != "" :
				f(n,ddra)
			ddra = []
			n = m.group(1)
			ddra.insert(int (m.group(2)),k['loc'])
	else :
		if ddra != [] :
			f(n,ddra)
			ddra = []
			n = ""
		n = k['net']
		ddra.append(k['loc'])


for k in sorted(pp.keys()) :
	print ("\t\t" + k + " : std_logic_vector("+ str(len(pp[k])) + "-1 downto 0);")

print(");\n\tattribute loc : string;\n\n")
for k in sorted(pp.keys()) :
	print ("\tattribute loc of " +k + " : signal is \"" + pp[k] +'";')
