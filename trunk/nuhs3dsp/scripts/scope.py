#! /usr/bin/python

ddr_nuhs3dsp = [
	{
		'delayed_dqs' :  {
			'lut' :  [ 
				{ 'inst' : 'lutn', 'slice' : "X0Y82", 'bel' : "G" } ,
				{ 'inst' : 'lutp', 'slice' : "X0Y82", 'bel' : "F" } ] },
#			'taps' : [
#				[ "X0Y83", "F" ], [ "X2Y83", "F" ], [ "X0Y83", "G" ], [ "X2Y83", "G" ] ] } ,
		'read' : {
			'sys_cntr' : [ "X2Y80", "X2Y80", "X2Y81", "X2Y81" ],
			'ddr_cntr' : [
				[ "X0Y80", "X0Y80", "X0Y81", "X0Y81" ],
				[ "X3Y80", "X3Y80", "X3Y81", "X3Y81" ] ],
			'ram' : [
				[ "X2Y86", "X2Y87", "X2Y84", "X2Y85", "X2Y78", "X2Y77", "X2Y76", "X2Y75" ],
				[ "X0Y86", "X0Y87", "X0Y84", "X0Y85", "X0Y78", "X0Y77", "X0Y76", "X0Y75" ] ] },
		'write' :  {
			'sys_cntr' : [ "X5Y81", "X5Y81", "X5Y80", "X5Y80" ],
			'ddr_cntr' : [
				[ "X7Y72", "X7Y72", "X7Y73", "X7Y73" ],
				[ "X5Y72", "X5Y72", "X5Y73", "X5Y73" ] ],
			'ram' : [
				[ "X6Y86", "X6Y87", "X6Y84", "X6Y85", "X6Y78", "X6Y77", "X6Y76", "X6Y75" ],
				[ "X4Y86", "X4Y87", "X4Y84", "X4Y85", "X4Y78", "X4Y77", "X4Y76", "X4Y75" ] ] },
			},
	{
		'delayed_dqs' :  {
			'lut' :  [ 
				{ 'inst'  : 'lutn', 'slice' : "X0Y60", 'bel'   : "G" } ,
				{ 'inst'  : 'lutp', 'slice' : "X0Y60", 'bel'   : "F" } ] },
#			'taps' : [ 
#				[ "X0Y61", "F" ], [ "X2Y61", "F" ], [ "X0Y61", "G" ], [ "X2Y61", "G" ] ] },
		'read' : {
			'sys_cntr' : [ "X2Y64", "X2Y64", "X2Y65", "X2Y65" ],
			'ddr_cntr' : [
				[ "X0Y64", "X0Y64", "X0Y65", "X0Y65" ],
				[ "X3Y64", "X3Y64", "X3Y65", "X3Y65" ] ],
			'ram' : [
				[ "X2Y68", "X2Y71", "X2Y62", "X2Y67", "X2Y58", "X2Y59", "X2Y54", "X2Y55" ],
				[ "X0Y68", "X0Y71", "X0Y62", "X0Y67", "X0Y58", "X0Y59", "X0Y54", "X0Y55" ] ] },
		'write' :  {
			'sys_cntr' : [ "X5Y65", "X5Y65", "X5Y64", "X5Y64" ],
#			'ddr_cntr' : [
#				[ "X7Y72", "X7Y72", "X7Y73", "X7Y73" ],
#				[ "X5Y72", "X5Y72", "X5Y73", "X5Y73" ] ],
			'ram' : [
				[ "X6Y68", "X6Y71", "X6Y62", "X6Y67", "X6Y58", "X6Y59", "X6Y54", "X6Y55" ],
				[ "X4Y68", "X4Y71", "X4Y62", "X4Y67", "X4Y58", "X4Y59", "X4Y54", "X4Y55" ] ] },
			},
	]

ddr_dio = ddr_nuhs3dsp

for byte in range(len(ddr_dio)):

	print ("# ########### #");
	print ("# Data Byte {} #".format(byte))
	print ("# ########### #");
	print ()

	print("# Read FIFO #")
	print("# ######### #")
	print()

	print("# Delayed DSQ Taps #")
	print()

	dqs = ddr_dio[byte]['delayed_dqs']
	for lut in dqs['lut']:
		print ('INST "*/ddr_rd_fifo_e/fifo_bytes_g[' + str(byte) + '].dqs_delayed_e/' + lut['inst'] + '" LOC = SLICE_'  + lut['slice'] + ';')
		try:
			print ('INST "*/ddr_rd_fifo_e/fifo_bytes_g[' + str(byte) + '].dqs_delayed_e/' + lut['inst'] + '" BEL = ' + lut['bel'] + ';')
		except KeyError:
			pass

		try:
			for i in range(len(dqs['taps'])):
				tap = dqs['taps'][i]
				try:
					print ('INST "*/ddr_rd_fifo_e/fifo_bytes_g[' + str(byte) + '].dqs_delayed_e/chain_g[' + str(i+1) + ']" LOC = SLICE_' + tap[0] + ';')
					print ('INST "*/ddr_rd_fifo_e/fifo_bytes_g[' + str(byte) + '].dqs_delayed_e/chain_g[' + str(i+1) + ']" BEL = ' + tap[1] + ';')
				except IndexError:
					pass
		except KeyError:
			pass
	print()

	print("# To Sys Cntrs #")
	print()

	sys_cntr = ddr_dio[byte]['read']['sys_cntr']
	for i in range(len(sys_cntr)):
		print (
			'INST "*/*ddr_rd_fifo_e/fifo_bytes_g[' + str(byte) + 
			'].o_cntr_g[' + str(i) + '].ffd_i" LOC = SLICE_' +
			sys_cntr[i] + ';')
	print()

	print("# To DDR Cntrs #")
	print()

	ddr_cntr = ddr_dio[byte]['read']['ddr_cntr']
	for edge in range(len(ddr_cntr)):
		for bit in range(len(ddr_cntr[edge])):
			print (
				'INST "*/*ddr_rd_fifo_e/fifo_bytes_g[' +
				str(byte) + '].ddr_fifo[' +
				str(edge) + '].i_cntr_g[' +
				str(bit)  + '].ffd_i" LOC = SLICE_' +
				ddr_cntr[edge][bit] + ';')
	print()

	print("# Distributed RAM  #")
	print()

	ram = ddr_dio[byte]['read']['ram']
	for edge in range(len(ram)):
		for bit in range(len(ram[edge])):
			print (
				'INST "*/*ddr_rd_fifo_e/fifo_bytes_g[' +
				str(byte) + '].ddr_fifo[' +
				str(edge) + '].ram_g[' +
				str(bit)  + '].ram16x1d_i" LOC = SLICE_' +
				ram[edge][bit] + ';')
		print()

	print("# Write FIFO #")
	print("# ########## #")
	print()

	print("# To Sys Cntrs #")
	print()

	sys_cntr = ddr_dio[byte]['write']['sys_cntr']
	for bit in range(len(sys_cntr)):
		print (
			'INST "*/ddr_wr_fifo_e/data_byte_g[' +
			str(byte) + '].sys_cntr_g[' +
			str(bit)  + '].ffd_i" LOC = SLICE_' +
			sys_cntr[bit] + ';')
	print()

	try:
		ddr_cntr = ddr_dio[byte]['write']['ddr_cntr']

		print("# To DDR Cntrs #")
		print()

		for edge in range(len(ddr_cntr)):
			for bit in range(len(ddr_cntr[edge])):
				print (
					'INST "*/ddr_wr_fifo_e/data_byte_g[' + 
					str(byte) + '].ddr_data_g[' + 
					str(edge) + '].ddr_word_g.cntr_g['  +
					str(bit)  + '].ffd_i" LOC = SLICE_' +
					ddr_cntr[edge][bit] + ';')
			print()
	except KeyError:
		pass

	print("# Distributed RAM  #")
	print()

	ram = ddr_dio[byte]['write']['ram']
	for edge in range(len(ram)):
		for bit in range(len(ram[edge])):
			print (
				'INST "*/ddr_wr_fifo_e/data_byte_g[' +
				str(byte) + '].ddr_data_g[' +
				str(edge) + '].ram_g[' +
				str(bit)  + '].ram16x1d_i" LOC = SLICE_' +
				ram[edge][bit] + ';')
		print()
