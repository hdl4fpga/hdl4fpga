#! /usr/bin/python

ddr_dio = [
	{
		'delayed_dqs' :  {
			'lut' :  [ 
				{ 'inst' : 'lutn', 'slice' : "X0Y82", 'bel' : "g" } ,
				{ 'inst' : 'lutp', 'slice' : "X0Y82", 'bel' : "f" } ],
			'taps' : [
				[ "X0Y83", "f" ], [ "X2Y83", "f" ], [ "X0Y83", "g" ], [ "X2Y83", "g" ] ] } ,
		'read' : {
			'sys_cntr' : [ "X2Y80", "X2Y80", "X2Y81", "X2Y81" ],
			'ddr_cntr' : [
				[ "X0Y80", "X0Y80", "X0Y81", "X0Y81" ],
				[ "X3Y80", "X3Y80", "X3Y81", "X3Y81" ] ],
			'ram' : [
				[ "X2Y86", "X2Y87", "X2Y84", "X2Y85", "X2Y78", "X2Y77", "X2Y76", "X2Y75" ],
				[ "X0Y86", "X0Y87", "X0Y84", "X0Y85", "X0Y78", "X0Y77", "X0Y76", "X0Y75" ] ] },
		'write' :  {}
			},
	{
		'delayed_dqs' :  {
			'lut' :  [ 
				{ 'inst'  : 'lutn', 'slice' : "X0Y60", 'bel'   : "g" } ,
				{ 'inst'  : 'lutp', 'slice' : "X0Y60", 'bel'   : "f" } ],
			'taps' : [ 
				[ "X0Y61", "f" ], [ "X2Y61", "f" ], [ "X0Y61", "g" ], [ "X2Y61", "g" ] ] },
		'read' : {
			'sys_cntr' : [ "X2Y64", "X2Y64", "X2Y65", "X2Y65" ],
			'ddr_cntr' : [
				[ "X0Y64", "X0Y64", "X0Y65", "X0Y65" ],
				[ "X3Y64", "X3Y64", "X3Y65", "X3Y65" ] ],
			'ram' : [
				[ "X2Y68", "X2Y71", "X2Y62", "X2Y67", "X2Y58", "X2Y59", "X2Y54", "X2Y55" ],
				[ "X0Y68", "X0Y71", "X0Y62", "X0Y67", "X0Y58", "X0Y59", "X0Y54", "X0Y55" ] ] },
		'write' :  {}
		} 
]

for byte in range(len(ddr_dio)):
	dqs = ddr_dio[byte]['delayed_dqs']
	for lut in dqs['lut']:
		print ('INST "*/ddr_rd_fifo_e/fifo_bytes_g[' + str(byte) + '].dqs_delayed_e/' + lut['inst'] + ' LOC = SLICE_'  + lut['slice'] + ';')
		print ('INST "*/ddr_rd_fifo_e/fifo_bytes_g[' + str(byte) + '].dqs_delayed_e/' + lut['inst'] + ' BEL = ' + lut['bel'] + ';')
	for i in range(len(dqs['taps'])):
		tap = dqs['taps'][i]
		print ('INST "*/ddr_rd_fifo_e/fifo_bytes_g[' + str(byte) + '].dqs_delayed_e/chain_g[' + str(i) + '] LOC = SLICE_' + tap[0] + ';')
		print ('INST "*/ddr_rd_fifo_e/fifo_bytes_g[' + str(byte) + '].dqs_delayed_e/chain_g[' + str(i) + '] BEL = ' + tap[1] + ';')
	print()

	sys_cntr = ddr_dio[byte]['read']['sys_cntr']
	for i in range(len(sys_cntr)):
		print (
			'INST "*/*ddr_rd_fifo_e/fifo_bytes_g[' + str(byte) + 
			'].o_cntr_g[' + str(i) + '].ffd_i" LOC = SLICE_' +
			sys_cntr[i] + ';')
	print()

	ddr_cntr = ddr_dio[byte]['read']['ddr_cntr']
	for edge in range(len(ddr_cntr)):
		for i in range(len(ddr_cntr[edge])):
			print (
				'INST "*/*ddr_rd_fifo_e/fifo_bytes_g[' +
				str(byte) + '].ddr_fifo[' +
				str(edge) + '].i_cntr_g[' +
				str(i)    + '].ffd_i" LOC = SLICE_X1' +
				ddr_cntr[edge][i] + ';')
		print()

#		for i in range(8):
#			print (
#				'INST "*/*ddr_rd_fifo_e/fifo_bytes_g[' +
#				str(1-l) + '].ddr_fifo[' +
#				str(e) + '].ram_g[' +
#				str(7-i) + '].ram16x1d_i" LOC = SLICE_X0' +
#				pads[8*l+i][2+e+1] + ';')
#		print("\n")
#
#	for i in range(4):
#		print (
#			'INST "*/ddr_wr_fifo_e/data_byte_g[' +
#			str(1-l) + '].sys_cntr_g[' +
#			str(i) + '].ffd_i" LOC = SLICE_X1' +
#			wr_sys_i[1-l] + ';')
#	print("\n")

#	for e in range(2):
#		for i in range(4):
#			print (
#				'INST "*/ddr_wr_fifo_e/data_byte_g[' + 
#				str(1-l)  + '].ddr_data_g[' + 
#				str(e) + '].ddr_word_g.cntr_g['  +
#				str(i) + '].ffd_i" LOC = SLICE_X1' +
#				wr_ddr_i[l][e] + ';')
#		print("\n")
#
#		for i in range(8):
#			print (
#				'INST "*/ddr_wr_fifo_e/data_byte_g[' +
#				str(1-l) + '].ddr_data_g[' +
#				str(e)   + '].ram_g[' +
#				str(7-i) + '].ram16x1d_i" LOC = SLICE_X0' +
#				pads[8*l+i][e+1] + ';')
#		print("\n")

# ################# #
# DDR read counters #
# ################# #

#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].o_cntr_g[0].ffd_i" loc = slice_x2y80;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].o_cntr_g[1].ffd_i" loc = slice_x2y80;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].o_cntr_g[2].ffd_i" loc = slice_x2y81;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].o_cntr_g[3].ffd_i" loc = slice_x2y81;
#
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[0].i_cntr_g[0].ffd_i" loc = slice_x0y80;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[0].i_cntr_g[1].ffd_i" loc = slice_x0y80;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[0].i_cntr_g[2].ffd_i" loc = slice_x0y81;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[0].i_cntr_g[3].ffd_i" loc = slice_x0y81;
#
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[1].i_cntr_g[0].ffd_i" loc = slice_x3y80;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[1].i_cntr_g[1].ffd_i" loc = slice_x3y80;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[1].i_cntr_g[2].ffd_i" loc = slice_x3y81;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[1].i_cntr_g[3].ffd_i" loc = slice_x3y81;
#
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].o_cntr_g[0].ffd_i" loc = slice_x2y64;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].o_cntr_g[1].ffd_i" loc = slice_x2y64;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].o_cntr_g[2].ffd_i" loc = slice_x2y65;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].o_cntr_g[3].ffd_i" loc = slice_x2y65;
#                                    
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[0].i_cntr_g[0].ffd_i" loc = slice_x0y64;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[0].i_cntr_g[1].ffd_i" loc = slice_x0y64;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[0].i_cntr_g[2].ffd_i" loc = slice_x0y65;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[0].i_cntr_g[3].ffd_i" loc = slice_x0y65;
#
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[1].i_cntr_g[0].ffd_i" loc = slice_x3y64;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[1].i_cntr_g[1].ffd_i" loc = slice_x3y64;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[1].i_cntr_g[2].ffd_i" loc = slice_x3y65;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[1].i_cntr_g[3].ffd_i" loc = slice_x3y65;
#
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[0].ram_g[0].ram16x1d_i" loc = slice_x2y86;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[0].ram_g[1].ram16x1d_i" loc = slice_x2y87;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[0].ram_g[2].ram16x1d_i" loc = slice_x2y84;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[0].ram_g[3].ram16x1d_i" loc = slice_x2y85;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[0].ram_g[4].ram16x1d_i" loc = slice_x2y78;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[0].ram_g[5].ram16x1d_i" loc = slice_x2y77;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[0].ram_g[6].ram16x1d_i" loc = slice_x2y76;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[0].ram_g[7].ram16x1d_i" loc = slice_x2y75;
#
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[1].ram_g[0].ram16x1d_i" loc = slice_x0y86;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[1].ram_g[1].ram16x1d_i" loc = slice_x0y87;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[1].ram_g[2].ram16x1d_i" loc = slice_x0y84;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[1].ram_g[3].ram16x1d_i" loc = slice_x0y85;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[1].ram_g[4].ram16x1d_i" loc = slice_x0y78;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[1].ram_g[5].ram16x1d_i" loc = slice_x0y77;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[1].ram_g[6].ram16x1d_i" loc = slice_x0y76;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[0].ddr_fifo[1].ram_g[7].ram16x1d_i" loc = slice_x0y75;
#
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[0].ram_g[0].ram16x1d_i" loc = slice_x2y68;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[0].ram_g[1].ram16x1d_i" loc = slice_x2y71;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[0].ram_g[2].ram16x1d_i" loc = slice_x2y62;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[0].ram_g[3].ram16x1d_i" loc = slice_x2y67;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[0].ram_g[4].ram16x1d_i" loc = slice_x2y58;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[0].ram_g[5].ram16x1d_i" loc = slice_x2y59;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[0].ram_g[6].ram16x1d_i" loc = slice_x2y54;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[0].ram_g[7].ram16x1d_i" loc = slice_x2y55;
#
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[1].ram_g[0].ram16x1d_i" loc = slice_x0y68;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[1].ram_g[1].ram16x1d_i" loc = slice_x0y71;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[1].ram_g[2].ram16x1d_i" loc = slice_x0y62;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[1].ram_g[3].ram16x1d_i" loc = slice_x0y67;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[1].ram_g[4].ram16x1d_i" loc = slice_x0y58;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[1].ram_g[5].ram16x1d_i" loc = slice_x0y59;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[1].ram_g[6].ram16x1d_i" loc = slice_x0y54;
#inst "*/*ddr_rd_fifo_e/fifo_bytes_g[1].ddr_fifo[1].ram_g[7].ram16x1d_i" loc = slice_x0y55;

## ################## #
## DDR write counters #
## ################## #
#
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[0].ddr_word_g.cntr_g[0].ffd_i" loc = slice_x7y72;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[0].ddr_word_g.cntr_g[1].ffd_i" loc = slice_x7y72;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[0].ddr_word_g.cntr_g[2].ffd_i" loc = slice_x7y73;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[0].ddr_word_g.cntr_g[3].ffd_i" loc = slice_x7y73;
#
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[0].ddr_word_g.cntr_g[0].ffd_i" bel = f;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[0].ddr_word_g.cntr_g[1].ffd_i" bel = g;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[0].ddr_word_g.cntr_g[2].ffd_i" bel = f;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[0].ddr_word_g.cntr_g[3].ffd_i" bel = g;
#
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[1].ddr_word_g.cntr_g[0].ffd_i" loc = slice_x5y72;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[1].ddr_word_g.cntr_g[1].ffd_i" loc = slice_x5y72;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[1].ddr_word_g.cntr_g[2].ffd_i" loc = slice_x5y73;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[1].ddr_word_g.cntr_g[3].ffd_i" loc = slice_x5y73;
#
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[1].ddr_word_g.cntr_g[0].ffd_i" bel = f;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[1].ddr_word_g.cntr_g[1].ffd_i" bel = g;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[1].ddr_word_g.cntr_g[2].ffd_i" bel = f;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[1].ddr_word_g.cntr_g[3].ffd_i" bel = g;
#
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[0].ram_g[0].ram16x1d_i" loc = slice_x6y86;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[0].ram_g[1].ram16x1d_i" loc = slice_x6y87;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[0].ram_g[2].ram16x1d_i" loc = slice_x6y84;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[0].ram_g[3].ram16x1d_i" loc = slice_x6y85;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[0].ram_g[4].ram16x1d_i" loc = slice_x6y78;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[0].ram_g[5].ram16x1d_i" loc = slice_x6y77;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[0].ram_g[6].ram16x1d_i" loc = slice_x6y76;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[0].ram_g[7].ram16x1d_i" loc = slice_x6y75;
#
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[1].ram_g[0].ram16x1d_i" loc = slice_x4y86;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[1].ram_g[1].ram16x1d_i" loc = slice_x4y87;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[1].ram_g[2].ram16x1d_i" loc = slice_x4y84;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[1].ram_g[3].ram16x1d_i" loc = slice_x4y85;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[1].ram_g[4].ram16x1d_i" loc = slice_x4y78;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[1].ram_g[5].ram16x1d_i" loc = slice_x4y77;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[1].ram_g[6].ram16x1d_i" loc = slice_x4y76;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].ddr_data_g[1].ram_g[7].ram16x1d_i" loc = slice_x4y75;
#
#inst "*/ddr_wr_fifo_e/data_byte_g[1].ddr_data_g[0].ram_g[0].ram16x1d_i" loc = slice_x6y68;
#inst "*/ddr_wr_fifo_e/data_byte_g[1].ddr_data_g[0].ram_g[1].ram16x1d_i" loc = slice_x6y71;
#inst "*/ddr_wr_fifo_e/data_byte_g[1].ddr_data_g[0].ram_g[2].ram16x1d_i" loc = slice_x6y62;
#inst "*/ddr_wr_fifo_e/data_byte_g[1].ddr_data_g[0].ram_g[3].ram16x1d_i" loc = slice_x6y67;
#inst "*/ddr_wr_fifo_e/data_byte_g[1].ddr_data_g[0].ram_g[4].ram16x1d_i" loc = slice_x6y58;
#inst "*/ddr_wr_fifo_e/data_byte_g[1].ddr_data_g[0].ram_g[5].ram16x1d_i" loc = slice_x6y59;
#inst "*/ddr_wr_fifo_e/data_byte_g[1].ddr_data_g[0].ram_g[6].ram16x1d_i" loc = slice_x6y54;
#inst "*/ddr_wr_fifo_e/data_byte_g[1].ddr_data_g[0].ram_g[7].ram16x1d_i" loc = slice_x6y55;
#
#inst "*/ddr_wr_fifo_e/data_byte_g[1].ddr_data_g[1].ram_g[0].ram16x1d_i" loc = slice_x4y68;
#inst "*/ddr_wr_fifo_e/data_byte_g[1].ddr_data_g[1].ram_g[1].ram16x1d_i" loc = slice_x4y71;
#inst "*/ddr_wr_fifo_e/data_byte_g[1].ddr_data_g[1].ram_g[2].ram16x1d_i" loc = slice_x4y62;
#inst "*/ddr_wr_fifo_e/data_byte_g[1].ddr_data_g[1].ram_g[3].ram16x1d_i" loc = slice_x4y67;
#inst "*/ddr_wr_fifo_e/data_byte_g[1].ddr_data_g[1].ram_g[4].ram16x1d_i" loc = slice_x4y58;
#inst "*/ddr_wr_fifo_e/data_byte_g[1].ddr_data_g[1].ram_g[5].ram16x1d_i" loc = slice_x4y59;
#inst "*/ddr_wr_fifo_e/data_byte_g[1].ddr_data_g[1].ram_g[6].ram16x1d_i" loc = slice_x4y54;
#inst "*/ddr_wr_fifo_e/data_byte_g[1].ddr_data_g[1].ram_g[7].ram16x1d_i" loc = slice_x4y55;
#
#inst "*/ddr_wr_fifo_e/data_byte_g[0].sys_cntr_g[0].ffd_i" loc = slice_x5y81;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].sys_cntr_g[1].ffd_i" loc = slice_x5y81;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].sys_cntr_g[2].ffd_i" loc = slice_x5y80;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].sys_cntr_g[3].ffd_i" loc = slice_x5y80;
#
#inst "*/ddr_wr_fifo_e/data_byte_g[0].sys_cntr_g[0].ffd_i" bel = g;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].sys_cntr_g[1].ffd_i" bel = f;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].sys_cntr_g[2].ffd_i" bel = g;
#inst "*/ddr_wr_fifo_e/data_byte_g[0].sys_cntr_g[3].ffd_i" bel = f;
#
#inst "*/ddr_wr_fifo_e/data_byte_g[1].sys_cntr_g[0].ffd_i" loc = slice_x5y65;
#inst "*/ddr_wr_fifo_e/data_byte_g[1].sys_cntr_g[1].ffd_i" loc = slice_x5y65;
#inst "*/ddr_wr_fifo_e/data_byte_g[1].sys_cntr_g[2].ffd_i" loc = slice_x5y64;
#inst "*/ddr_wr_fifo_e/data_byte_g[1].sys_cntr_g[3].ffd_i" loc = slice_x5y64;
#
#inst "*/ddr_wr_fifo_e/data_byte_g[1].sys_cntr_g[0].ffd_i" bel = g;
#inst "*/ddr_wr_fifo_e/data_byte_g[1].sys_cntr_g[1].ffd_i" bel = f;
#inst "*/ddr_wr_fifo_e/data_byte_g[1].sys_cntr_g[2].ffd_i" bel = g;
#inst "*/ddr_wr_fifo_e/data_byte_g[1].sys_cntr_g[3].ffd_i" bel = f;
#
##NET  "ddr_ckp"                         IOSTANDARD = DIFF_SSTL2_II;
##NET  "ddr_ckn"                       IOSTANDARD = DIFF_SSTL2_II;
##NET  "ddr_ckp"                          LOC = "AB13" ;     #bank 3
##NET  "ddr_ckn"                          LOC = "AA14" ;     #bank 3
