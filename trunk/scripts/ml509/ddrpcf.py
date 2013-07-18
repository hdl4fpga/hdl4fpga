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

	[ "AB28", "Y35" ],
	[ "AG28", "Y33" ],
	[ "AJ26", "Y28" ],
	[ "AG25", "Y26" ],
	[ "AA28", "Y34" ],
	[ "AH28", "Y32" ],
	[ "AF28", "Y30" ],
	[ "AH27", "Y29" ],

	[ "AE29", "Y46" ],
	[ "AD29", "Y45" ],
	[ "AF29", "Y42" ],
	[ "AJ30", "Y40" ],
	[ "AD30", "Y48" ],
	[ "AF31", "Y47" ],
	[ "AK31", "Y43" ],
	[ "AF30", "Y41" ]
]

wr_cntr_i = [ "Y44", "Y29" ]

pads.reverse()
for l in range(len(wr_cntr_i)):
	for i in range(4):
		print (
			'INST "*/DDR_WR_FIFO_E/DATA_BYTE_G[0].DDR_DATA_G[' + 
			str(l) + '].DDR_WORD_G.CNTR_G['  +
			str(i) + '].FFD_I" LOC = SLICE_' +
			'X2' + wr_cntr_i[l] + ';')
	for i in range(4):
		print (
			'INST "*/DDR_WR_FIFO_E/DATA_BYTE_G[' +
			str(l) + '].SYS_CNTR_G[' +
			str(i) + '].FFD_I" LOC = SLICE_' +
			'X3' + wr_cntr_i[l] + ';')
	print("\n");

	for e in range(2) :
		for i in range(8):
			for k in range(2):
			inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[1].ram_g[0].ram16x1d_i" loc = slice_x0y68;
			print (
				'INST "*/DDR_WR_FIFO_E/DATA_BYTE_G[' +
				str(e)      + '].DDR_DATA_G[' +
				str(l) + '].RAM_G[' +
				str(i) + '].RAM16X1D_I" LOC = SLICE_' +
				'X' + str(4*e) + pads[8*l+i][1] + ';')
		print("\n");
