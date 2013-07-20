#!/usr/bin/env python

import sys
import struct
import re

pads = [
	[ "L24",  "Y139" ],
	[ "L25",  "Y138" ],
	[ "M25",  "Y136" ],
	[ "J27",  "Y135" ],
	[ "L26",  "Y138" ],
	[ "J24",  "Y137" ],
	[ "M26",  "Y136" ],
	[ "G25",  "Y134" ],

	[ "G26",  "Y134" ],
	[ "H24",  "Y133" ],
	[ "K28",  "Y126" ],
	[ "K27",  "Y125" ],
	[ "H25",  "Y133" ],
	[ "F25",  "Y132" ],
	[ "L28",  "Y126" ],
	[ "M28",  "Y124" ],

	[ "N28",  "Y124" ],
	[ "P27",  "Y123" ],
	[ "N25",  "Y121" ],
	[ "T24",  "Y120" ],
	[ "P26",  "Y123" ],
	[ "N24",  "Y122" ],
	[ "P25",  "Y121" ],
	[ "R24",  "Y120" ],

	[ "V24",  "Y59" ],
	[ "W26",  "Y58" ],
	[ "W25",  "Y57" ],
	[ "V28",  "Y54" ],
	[ "W24",  "Y59" ],
	[ "Y26",  "Y58" ],
	[ "Y27",  "Y56" ],
	[ "V29",  "Y52" ],

	[ "W27",  "Y56" ],
	[ "V27",  "Y54" ],
	[ "W29",  "Y52" ],
	[ "AC30", "Y49" ],
	[ "V30",  "Y55" ],
	[ "W31",  "Y53" ],
	[ "AB30", "Y49" ],
	[ "AC29", "Y46" ],

	[ "AA25", "Y39" ],
	[ "AB27", "Y38" ],
	[ "AA24", "Y37" ],
	[ "AB26", "Y36" ],
	[ "AA26", "Y39" ],
	[ "AC27", "Y38" ],
	[ "AB25", "Y36" ],
	[ "AC28", "Y35" ],

	[ "AB28", "Y31", "Y34", "Y33", "Y35" ],
	[ "AG28", "Y31", "Y34", "Y33", "Y35" ],
	[ "AJ26", "Y27", "Y29", "Y28", "Y30" ],
	[ "AG25", "Y27", "Y29", "Y28", "Y30" ],
	[ "AA28", "Y31", "Y34", "Y33", "Y35" ],
	[ "AH28", "Y31", "Y34", "Y33", "Y35" ],
	[ "AF28", "Y27", "Y29", "Y28", "Y30" ],
	[ "AH27", "Y27", "Y29", "Y28", "Y30" ],

	[ "AE29", "Y45", "Y47", "Y46", "Y48" ],
	[ "AD29", "Y45", "Y47", "Y46", "Y48" ],
	[ "AF29", "Y40", "Y42", "Y41", "Y44" ],
	[ "AJ30", "Y40", "Y42", "Y41", "Y44" ],
	[ "AD30", "Y45", "Y47", "Y46", "Y48" ],
	[ "AF31", "Y45", "Y47", "Y46", "Y48" ],
	[ "AK31", "Y40", "Y42", "Y41", "Y44" ],
	[ "AF30", "Y40", "Y42", "Y41", "Y44" ]
]

wr_ddr_i = [ "Y34" ]
wr_sys_i = [ "Y44", "Y29" ]

pads.reverse()
for l in range(2):
	for i in range(4):
		print (
			'INST "*/DDR_WR_FIFO_E/DATA_BYTE_G[' +
			str(1-l) + '].SYS_CNTR_G[' +
			str(i) + '].FFD_I" LOC = SLICE_X1' +
			wr_sys_i[l] + ';')
	print("\n")

	if l % 2 == 0:
		for i in range(4):
			print (
				'INST "*/DDR_WR_FIFO_E/DATA_BYTE_G[0].DDR_DATA_G[' + 
				str(0) + '].DDR_WORD_G.CNTR_G['  +
				str(i) + '].FFD_I" LOC = SLICE_X1' +
				wr_ddr_i[(l //  2)] + ';')
		print("\n")

	for e in range(2) :
		for i in range(8):
			print (
				'INST "*/DDR_WR_FIFO_E/DATA_BYTE_G[' +
				str(1-l)      + '].DDR_DATA_G[' +
				str(e) + '].RAM_G[' +
				str(7-i) + '].RAM16X1D_I" LOC = SLICE_X0' +
				pads[8*l+i][e+1] + ';')
		print("\n")

	for e in range(2) :
		for i in range(8):
			print (
				'INST "*/*DDR_RD_FIFO_E/FIFO_BYTES_G[' +
				str(1-l) + '].DDR_FIFO[' +
				str(e) + '].RAM_G[' +
				str(7-i) + '].RAM16X1D_I" LOC = SLICE_X0' +
				pads[8*l+i][2+e+1] + ';')
		print("\n")
