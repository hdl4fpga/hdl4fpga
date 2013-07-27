#! /usr/bin/python

def chip(desc):

	for byte in range(len(desc)):

		print ("# ########### #");
		print ("# Data Byte {} #".format(byte))
		print ("# ########### #");
		print ()

		print("# Read FIFO #")
		print("# ######### #")
		print()

		print("# Delayed DSQ Taps #")
		print()

		dqs = desc[byte]['delayed_dqs']
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

		sys_cntr = desc[byte]['read']['sys_cntr']
		for i in range(len(sys_cntr)):
			print (
				'INST "*/*ddr_rd_fifo_e/fifo_bytes_g[' + str(byte) + 
				'].o_cntr_g[' + str(i) + '].ffd_i" LOC = SLICE_' +
				sys_cntr[i] + ';')
		print()

		print("# To DDR Cntrs #")
		print()

		ddr_cntr = desc[byte]['read']['ddr_cntr']
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

		ram = desc[byte]['read']['ram']
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

		sys_cntr = desc[byte]['write']['sys_cntr']
		for bit in range(len(sys_cntr)):
			print (
				'INST "*/ddr_wr_fifo_e/data_byte_g[' +
				str(byte) + '].sys_cntr_g[' +
				str(bit)  + '].ffd_i" LOC = SLICE_' +
				sys_cntr[bit] + ';')
		print()

		try:
			ddr_cntr = desc[byte]['write']['ddr_cntr']

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

		ram = desc[byte]['write']['ram']
		for edge in range(len(ram)):
			for bit in range(len(ram[edge])):
				print (
					'INST "*/ddr_wr_fifo_e/data_byte_g[' +
					str(byte) + '].ddr_data_g[' +
					str(edge) + '].ram_g[' +
					str(bit)  + '].ram16x1d_i" LOC = SLICE_' +
					ram[edge][bit] + ';')
			print()
