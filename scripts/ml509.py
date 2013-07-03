#!/usr/bin/env python

import sys
import struct
import re
pp = {}
def f(n, a):
	s = ""
	if not re.match("phy",n):
		ddra.reverse()
	for a in ddra:
		if s == "":
			s += a
		else :
			s += " " + a
	m1 = re.match("(.*)_\Z",n)
	if m1: 
		n = m1.group(1)
	pp[n] = s

p = []
for line in sys.stdin:
	m = re.match ("NET\s+(\w+\s)\s*LOC=\"(\w+)\".*\#\s*(.+)",line)
	if m :
		k = { \
			'net' : m.group(1).lower(), \
			'loc' : m.group(2).upper(), \
			'cmm' : m.group(3).lower()}
		p.append (k)

print("library ieee;\n\
use ieee.std_logic_1164.all;\n\
use ieee.numeric_std.all;\n\n\
entity ml505 is\n\
\tport(")
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
#		n = k['net']
#		ddra.append(k['loc'])


for k in sorted(pp.keys()) :
	print ("\t\t" + k + " : std_logic_vector("+ len(pp[k])+ downto 0);")

print(");\n\tattribute loc : string;\n\n")
for k in sorted(pp.keys()) :
	print ("\tattribute loc of " +k + " : signal is \"" + pp[k] +'";')
