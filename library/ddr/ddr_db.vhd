--                                                                            --
-- Author(s):                                                                 --
--   Miguel Angel Sagreras                                                    --
--                                                                            --
-- Copyright (C) 2015                                                         --
--    Miguel Angel Sagreras                                                   --
--                                                                            --
-- This source file may be used and distributed without restriction provided  --
-- that this copyright statement is not removed from the file and that any    --
-- derivative work contains  the original copyright notice and the associated --
-- disclaimer.                                                                --
--                                                                            --
-- This source file is free software; you can redistribute it and/or modify   --
-- it under the terms of the GNU General Public License as published by the   --
-- Free Software Foundation, either version 3 of the License, or (at your     --
-- option) any later version.                                                 --
--                                                                            --
-- This source is distributed in the hope that it will be useful, but WITHOUT --
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or      --
-- FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for   --
-- more details at http://www.gnu.org/licenses/.                              --
--                                                                            --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library hdl4fpga;
use hdl4fpga.std.all;
use hdl4fpga.profiles.all;

package ddr_db is
	type sdrams is (
		sdr,
		ddr,
		ddr2,
		ddr3);

	type sdram_chips is (
		MT46V256M6T,
		MT41J1G15E,
		MT47H512M3,
		MT41K2G125,
		MT41K4G107,
		AS4CD3LC12,
		MT48LC256MA27E);

	type sdram_parameters is (
		tPreRST,
		tPstRST,
		tXPR,
		tWR,
		tRP,
		tRCD,
		tRFC,
		tMRD,
		tREFI,
		tRPA);

	type sdram_latency_rgtr is (
		CL,
		BL,
		WRL,
		CWL);

	type sdram_latencies is (
		cDLL,
		MRD,
		MODu,
		XPR,
		ZQINIT);

	type device_latencies is (
		STRL,
		RWNL,
		DQSZL,
		DQSL,
		DQZL,
		WWNL,
		STRXL,
		RWNXL,
		DQSZXL,
		DQSXL,
		DQZXL,
		WWNXL,
		WIDL,
		RDFIFO_LAT);

	constant code_size : natural := 3;
	subtype code_t is std_logic_vector(0 to code_size-1);
	type cnfglat_record is record
		sdram : sdrams;
		rgtr  : sdram_latency_rgtr;
		lat   : natural;
		code  : code_t;
	end record;

	type cnfglat_tab is array (natural range <>) of cnfglat_record;

	type tmark_record is record
		mark  : sdram_chips;
		sdram : sdrams;
	end record;

	type tmark_tab is array (natural range <>) of tmark_record;

	constant tmark_db : tmark_tab := (
		(mark => MT48LC256MA27E, sdram => sdr),
		(mark => MT46V256M6T,    sdram => ddr),
		(mark => MT47H512M3,     sdram => ddr2),
		(mark => MT41J1G15E,     sdram => ddr3),
		(mark => MT41K2G125,     sdram => ddr3),
		(mark => MT41K4G107,     sdram => ddr3),
		(mark => AS4CD3LC12,     sdram => ddr3));

	type sdram_latency_record is record
		sdram : sdrams;
		param : sdram_latencies;
		value : natural;
	end record;
	type sdram_latency_vector is array (natural range <>) of sdram_latency_record;

	type device_latency_record is record
		fpga  : fpga_devices;
		param : device_latencies;
		value : integer;
	end record;

	type device_latency_vector is array (natural range <>) of device_latency_record;

	type timing_record is record
		mark  : sdram_chips;
		param : sdram_parameters;
		value : real;
	end record;

	type timing_vector is array (natural range <>) of timing_record;

	constant timing_tab : timing_vector := (
		(mark => MT48LC256MA27E,    param => tPreRST, value => 100.0e-6),
		(mark => MT48LC256MA27E,    param => tWR,     value =>  14.0e-9+11.0e-9),
		(mark => MT48LC256MA27E,    param => tRP,     value =>  15.0e-9),
		(mark => MT48LC256MA27E,    param => tRCD,    value =>  15.0e-9),
		(mark => MT48LC256MA27E,    param => tRFC,    value =>  66.0e-9),
		(mark => MT48LC256MA27E,    param => tMRD,    value =>  15.0e-9),
		(mark => MT48LC256MA27E,    param => tREFI,   value =>  64.0e-3/8192),

		(mark => MT46V256M6T,param => tPreRST, value => 200.0e-6),
		(mark => MT46V256M6T,param => tWR,     value =>  15.0e-9),
		(mark => MT46V256M6T,param => tRP,     value =>  15.0e-9),
		(mark => MT46V256M6T,param => tRCD,    value =>  15.0e-9),
		(mark => MT46V256M6T,param => tRFC,    value =>  72.0e-9),
		(mark => MT46V256M6T,param => tMRD,    value =>  12.0e-9),
		(mark => MT46V256M6T,param => tREFI,   value =>  64.0e-3/8192),

		(mark => MT47H512M3, param => tPreRST, value => 200.0e-6),
		(mark => MT47H512M3, param => tXPR,    value => 400.0e-6),
		(mark => MT47H512M3, param => tWR,     value =>  15.0e-9),
		(mark => MT47H512M3, param => tRP,     value =>  15.0e-9),
		(mark => MT47H512M3, param => tRCD,    value =>  15.0e-9),
		(mark => MT47H512M3, param => tRFC,    value => 130.0e-9),
		(mark => MT47H512M3, param => tRPA,    value =>  15.0e-9),
		(mark => MT47H512M3, param => tREFI,   value =>  64.0e-3/8192),

		(mark => MT41J1G15E, param => tPreRST, value => 200.00e-6),
		(mark => MT41J1G15E, param => tPstRST, value => 500.00e-6),
		(mark => MT41J1G15E, param => tWR,     value =>  15.00e-9),
		(mark => MT41J1G15E, param => tRCD,    value =>  13.91e-9),
		(mark => MT41J1G15E, param => tRP,     value =>  13.91e-9),
		(mark => MT41J1G15E, param => tMRD,    value =>  15.00e-9),
		(mark => MT41J1G15E, param => tRFC,    value => 110.00e-9),
		(mark => MT41J1G15E, param => tXPR,    value => 110.00e-9 + 10.0e-9),
		(mark => MT41J1G15E, param => tREFI,   value =>  64.00e-3/8192),

		(mark => MT41K2G125, param => tPreRST, value => 200.00e-6),
		(mark => MT41K2G125, param => tPstRST, value => 500.00e-6),
		(mark => MT41K2G125, param => tWR,     value =>  15.00e-9),
		(mark => MT41K2G125, param => tRCD,    value =>  13.75e-9),
		(mark => MT41K2G125, param => tRP,     value =>  13.75e-9),
		(mark => MT41K2G125, param => tMRD,    value =>  15.00e-9),
		(mark => MT41K2G125, param => tRFC,    value => 160.00e-9),
		(mark => MT41K2G125, param => tXPR,    value => 160.00e-9 + 10.0e-9),
		(mark => MT41K2G125, param => tREFI,   value =>  64.00e-3/8192),

		(mark => MT41K4G107, param => tPreRST, value => 200.00e-6),
		(mark => MT41K4G107, param => tPstRST, value => 500.00e-6),
		(mark => MT41K4G107, param => tWR,     value =>  15.00e-9),
		(mark => MT41K4G107, param => tRCD,    value =>  13.91e-9),
		(mark => MT41K4G107, param => tRP,     value =>  13.91e-9),
		(mark => MT41K4G107, param => tMRD,    value =>  20.00e-9),
		(mark => MT41K4G107, param => tRFC,    value => 260.00e-9),
		(mark => MT41K4G107, param => tXPR,    value => 260.00e-9 + 10.0e-9),
		(mark => MT41K4G107, param => tREFI,   value =>  64.00e-3/8192),

		(mark => AS4CD3LC12,  param => tPreRST, value => 200.00e-6),
		(mark => AS4CD3LC12,  param => tPstRST, value => 500.00e-6),
		(mark => AS4CD3LC12,  param => tWR,     value =>  15.00e-9),
		(mark => AS4CD3LC12,  param => tRCD,    value =>  13.75e-9),
		(mark => AS4CD3LC12,  param => tRP,     value =>  13.75e-9),
		(mark => AS4CD3LC12,  param => tMRD,    value =>  15.00e-9),
		(mark => AS4CD3LC12,  param => tRFC,    value => 260.00e-9),
		(mark => AS4CD3LC12,  param => tXPR,    value => 260.00e-9 + 10.0e-9),
		(mark => AS4CD3LC12,  param => tREFI,   value =>  64.00e-3/8192));

	constant sdram_latency_tab : sdram_latency_vector := (
		(sdram => ddr,  param => cDLL,       value => 200),

		(sdram => ddr2, param => cDLL,       value => 200),
		(sdram => ddr2, param => MRD,        value =>   2),

		(sdram => ddr3, param => cDLL,       value => 500),
		(sdram => ddr3, param => ZQINIT,     value => 500),
		(sdram => ddr3, param => MRD,        value =>   4),
		(sdram => ddr3, param => MODu,       value =>  12),
		(sdram => ddr3, param => XPR,        value =>   5));

	constant device_latency_tab : device_latency_vector := (
		(fpga => xc3s, param => STRL,       value =>   0),
		(fpga => xc3s, param => RWNL,       value =>   0),
		(fpga => xc3s, param => DQSZL,      value =>   0),
		(fpga => xc3s, param => DQSL,       value =>   1),
		(fpga => xc3s, param => DQZL,       value =>   0),
		(fpga => xc3s, param => WWNL,       value =>   0),
		(fpga => xc3s, param => STRXL,      value =>   0),
		(fpga => xc3s, param => RWNXL,      value => 2*0),
		(fpga => xc3s, param => DQSZXL,     value =>  1),
		(fpga => xc3s, param => DQSXL,      value =>   0),
		(fpga => xc3s, param => DQZXL,      value =>   0),
		(fpga => xc3s, param => WWNXL,      value =>   0),
		(fpga => xc3s, param => WIDL,       value =>   1),
		(fpga => xc3s, param => RDFIFO_LAT, value =>   2),

		(fpga => xc5v, param => STRL,       value =>   0),
		(fpga => xc5v, param => RWNL,       value =>   4),
		(fpga => xc5v, param => DQSL,       value =>   0),
		(fpga => xc5v, param => DQSZL,      value =>  -2),
		(fpga => xc5v, param => DQZL,       value =>  -2),
		(fpga => xc5v, param => WWNL,       value =>  -4),
		(fpga => xc5v, param => STRXL,      value =>   0),
		(fpga => xc5v, param => RWNXL,      value =>   0),
		(fpga => xc5v, param => DQSXL,      value =>   0),
		(fpga => xc5v, param => DQSZXL,     value =>   4),
		(fpga => xc5v, param => DQZXL,      value =>   0),
		(fpga => xc5v, param => WWNXL,      value =>   2),
		(fpga => xc5v, param => WIDL,       value =>   4),
		(fpga => xc5v, param => RDFIFO_LAT, value =>   2),

		(fpga => xc7a, param => STRL,       value =>   0),
		(fpga => xc7a, param => RWNL,       value =>   4),
		(fpga => xc7a, param => DQSL,       value =>  -4),
		(fpga => xc7a, param => DQSZL,      value =>  -4),
		(fpga => xc7a, param => DQZL,       value =>  -5),
		(fpga => xc7a, param => WWNL,       value =>  -5),
		(fpga => xc7a, param => STRXL,      value =>   0),
		(fpga => xc7a, param => RWNXL,      value =>   0),
		(fpga => xc7a, param => DQSXL,      value =>   2),
		(fpga => xc7a, param => DQSZXL,     value =>  4),
		(fpga => xc7a, param => DQZXL,      value =>   0),
		(fpga => xc7a, param => WWNXL,      value =>   0),
		(fpga => xc7a, param => WIDL,       value =>   4),
		(fpga => xc7a, param => RDFIFO_LAT, value =>   4),

		(fpga => ecp3, param => STRL,       value =>   0),
		(fpga => ecp3, param => RWNL,       value =>   0),
		(fpga => ecp3, param => DQSL,       value =>   0),
		(fpga => ecp3, param => DQSZL,      value =>   0),
		(fpga => ecp3, param => DQZL,       value =>   2),
		(fpga => ecp3, param => WWNL,       value =>   2),
		(fpga => ecp3, param => STRXL,      value =>   0),
		(fpga => ecp3, param => RWNXL,      value =>   0),
		(fpga => ecp3, param => DQSXL,      value =>   2),
		(fpga => ecp3, param => DQSZXL,     value =>   2),
		(fpga => ecp3, param => DQZXL,      value =>   0),
		(fpga => ecp3, param => WWNXL,      value =>   2),
		(fpga => ecp3, param => WIDL,       value =>   4),
		(fpga => ecp3, param => RDFIFO_LAT, value =>   0),

		(fpga => ecp5, param => STRL,       value =>   0),
		(fpga => ecp5, param => RWNL,       value =>   0),
		(fpga => ecp5, param => DQSL,       value =>   2),
		(fpga => ecp5, param => DQSZL,      value =>   2),
		(fpga => ecp5, param => DQZL,       value =>   2),
		(fpga => ecp5, param => WWNL,       value =>   2),
		(fpga => ecp5, param => STRXL,      value =>   0),
		(fpga => ecp5, param => RWNXL,      value =>   0),
		(fpga => ecp5, param => DQSXL,      value =>   2),
		(fpga => ecp5, param => DQSZXL,     value =>   2),
		(fpga => ecp5, param => DQZXL,      value =>   0),
		(fpga => ecp5, param => WWNXL,      value =>   2),
		(fpga => ecp5, param => WIDL,       value =>   4),
		(fpga => ecp5, param => RDFIFO_LAT, value =>   0));

	constant cnfglat_db : cnfglat_tab := (

		-- SDRAM standard --
		--------------------

		-- CL register --

		cnfglat_record'(sdram => sdr, rgtr => CL,  lat =>  1, code => "001"),
		cnfglat_record'(sdram => sdr, rgtr => CL,  lat =>  2, code => "010"),
		cnfglat_record'(sdram => sdr, rgtr => CL,  lat =>  3, code => "011"),

		-- BL register --

		cnfglat_record'(sdram => sdr, rgtr => BL,  lat =>  0, code => "000"),
		cnfglat_record'(sdram => sdr, rgtr => BL,  lat =>  1, code => "001"),
		cnfglat_record'(sdram => sdr, rgtr => BL,  lat =>  2, code => "010"),
		cnfglat_record'(sdram => sdr, rgtr => BL,  lat =>  4, code => "011"),

		-- CWL register --

		cnfglat_record'(sdram => sdr, rgtr => CWL, lat =>  0, code => "000"),

		-- DDR1 standard --
		-------------------

		-- CL register --

		cnfglat_record'(sdram => ddr, rgtr => CL,  lat =>  2*2, code => "010"),
		cnfglat_record'(sdram => ddr, rgtr => CL,  lat =>  1*5, code => "110"),
		cnfglat_record'(sdram => ddr, rgtr => CL,  lat =>  2*3, code => "011"),

		-- BL register --

		cnfglat_record'(sdram => ddr, rgtr => BL,  lat =>  2*1, code => "001"),
		cnfglat_record'(sdram => ddr, rgtr => BL,  lat =>  2*2, code => "010"),
		cnfglat_record'(sdram => ddr, rgtr => BL,  lat =>  2*4, code => "011"),

		-- CWL register --

		cnfglat_record'(sdram => ddr, rgtr => CWL, lat =>  2*1, code => "000"),

		-- DDR2 standard --
		-------------------

		-- CL register --

		cnfglat_record'(sdram => DDR2, rgtr => CL,  lat =>  3*2, code => "011"),
		cnfglat_record'(sdram => DDR2, rgtr => CL,  lat =>  4*2, code => "100"),
		cnfglat_record'(sdram => DDR2, rgtr => CL,  lat =>  5*2, code => "101"),
		cnfglat_record'(sdram => DDR2, rgtr => CL,  lat =>  6*2, code => "110"),
		cnfglat_record'(sdram => DDR2, rgtr => CL,  lat =>  7*2, code => "111"),

		-- BL register --

		cnfglat_record'(sdram => DDR2, rgtr => BL,  lat =>  2*2, code => "010"),
		cnfglat_record'(sdram => DDR2, rgtr => BL,  lat =>  4*2, code => "011"),

		-- WRL register --

		cnfglat_record'(sdram => DDR2, rgtr => WRL, lat =>  2*2, code => "001"),
		cnfglat_record'(sdram => DDR2, rgtr => WRL, lat =>  3*2, code => "010"),
		cnfglat_record'(sdram => DDR2, rgtr => WRL, lat =>  4*2, code => "011"),
		cnfglat_record'(sdram => DDR2, rgtr => WRL, lat =>  5*2, code => "100"),
		cnfglat_record'(sdram => DDR2, rgtr => WRL, lat =>  6*2, code => "101"),
		cnfglat_record'(sdram => DDR2, rgtr => WRL, lat =>  7*2, code => "110"),
		cnfglat_record'(sdram => DDR2, rgtr => WRL, lat =>  8*2, code => "111"),

		-- DDR3 standard --
		-------------------

		-- CL register --

		cnfglat_record'(sdram => DDR3, rgtr => CL, lat =>  5*2, code => "001"),
		cnfglat_record'(sdram => DDR3, rgtr => CL, lat =>  6*2, code => "010"),
		cnfglat_record'(sdram => DDR3, rgtr => CL, lat =>  7*2, code => "011"),
		cnfglat_record'(sdram => DDR3, rgtr => CL, lat =>  8*2, code => "100"),
		cnfglat_record'(sdram => DDR3, rgtr => CL, lat =>  9*2, code => "101"),
		cnfglat_record'(sdram => DDR3, rgtr => CL, lat => 10*2, code => "110"),
		cnfglat_record'(sdram => DDR3, rgtr => CL, lat => 2*11, code => "111"),

		-- BL register --

		cnfglat_record'(sdram => DDR3, rgtr => BL, lat => 8, code => "000"),
		cnfglat_record'(sdram => DDR3, rgtr => BL, lat => 8, code => "001"),
		cnfglat_record'(sdram => DDR3, rgtr => BL, lat => 8, code => "010"),

		-- WRL register --

		cnfglat_record'(sdram => DDR3, rgtr => WRL, lat =>  5*2,  code => "001"),
		cnfglat_record'(sdram => DDR3, rgtr => WRL, lat =>  6*2,  code => "010"),
		cnfglat_record'(sdram => DDR3, rgtr => WRL, lat =>  7*2,  code => "011"),
		cnfglat_record'(sdram => DDR3, rgtr => WRL, lat =>  8*2,  code => "100"),
		cnfglat_record'(sdram => DDR3, rgtr => WRL, lat => 10*2, code => "101"),
		cnfglat_record'(sdram => DDR3, rgtr => WRL, lat => 12*2, code => "110"),

		-- CWL register --

		cnfglat_record'(sdram => DDR3, rgtr => CWL, lat =>  5*2, code => "000"),
		cnfglat_record'(sdram => DDR3, rgtr => CWL, lat =>  6*2, code => "001"),
		cnfglat_record'(sdram => DDR3, rgtr => CWL, lat =>  7*2, code => "010"),
		cnfglat_record'(sdram => DDR3, rgtr => CWL, lat =>  8*2, code => "011"));

	function ddr_stdr (
		mark : sdram_chips)
		return sdrams;

	function ddr_query_size (
		constant sdram : sdrams;
		constant rgtr  : sdram_latency_rgtr)
		return natural;

	function ddr_cnfglat (
		constant sdram : sdrams;
		constant rgtr  : sdram_latency_rgtr;
		constant lat   : natural)
		return std_logic_vector;

	function ddr_timing (
		constant mark  : sdram_chips;
		constant param : sdram_parameters)
		return real;

	function ddr_latency (
		constant sdram : sdrams;
		constant param : sdram_latencies)
		return natural;

	function ddr_latency (
		constant fpga  : fpga_devices;
		constant param : device_latencies)
		return natural;

	function ddr_lattab (
		constant sdram : sdrams;
		constant rgtr  : sdram_latency_rgtr)
		return natural_vector;

	function ddr_schtab (
		constant sdram  : sdrams;
		constant fpga  : fpga_devices;
		constant tabid : device_latencies)
		return natural_vector;

	function to_ddrlatency (
		constant period : real;
		constant timing : real)
		return natural;

	function to_ddrlatency (
		constant period : real;
		constant mark   : sdram_chips;
		constant param  : sdram_parameters)
		return natural;

	function ddr_latcod (
		constant sdram : sdrams;
		constant rgtr  : sdram_latency_rgtr)
		return std_logic_vector;

	function ddr_selcwl (
		constant sdram : sdrams)
		return sdram_latency_rgtr;

end package;

package body ddr_db is

	function ddr_stdr (
		mark : sdram_chips)
		return sdrams is
	begin
		for i in tmark_db'range loop
			if tmark_db(i).mark = mark then
				return tmark_db(i).sdram;
			end if;
		end loop;
	end;

	function ddr_query_size (
		constant sdram : sdrams;
		constant rgtr  : sdram_latency_rgtr)
		return natural is
		variable val : natural := 0;
	begin
		for i in cnfglat_db'range loop
			if cnfglat_db(i).sdram = sdram then
				if cnfglat_db(i).rgtr = rgtr then
					val := val + 1;
				end if;
			end if;
		end loop;
		return val;
	end;

	function ddr_query_data (
		constant sdram : sdrams;
		constant rgtr  : sdram_latency_rgtr)
		return cnfglat_tab is
		constant query_size : natural := ddr_query_size(sdram, rgtr);
		variable query_data : cnfglat_tab (0 to query_size-1);
		variable query_row  : natural := 0;
	begin
		for i in cnfglat_db'range loop
			if cnfglat_db(i).sdram = sdram then
				if cnfglat_db(i).rgtr = rgtr then
					query_data(query_row) := cnfglat_db(i);
					query_row := query_row + 1;
				end if;
			end if;
		end loop;
		return query_data;
	end;

	function ddr_cnfglat (
		constant sdram : sdrams;
		constant rgtr  : sdram_latency_rgtr;
		constant lat   : natural)
		return std_logic_vector is
	begin
		for i in cnfglat_db'range loop
			if cnfglat_db(i).sdram = sdram then
				if cnfglat_db(i).rgtr = rgtr then
					if cnfglat_db(i).lat = lat then
						return cnfglat_db(i).code;
					end if;
				end if;
			end if;
		end loop;

		return "XXX";
	end;

	function ddr_timing (
		constant mark  : sdram_chips;
		constant param : sdram_parameters)
		return real is
	begin
		for i in timing_tab'range loop
			if timing_tab(i).mark = mark then
				if timing_tab(i).param = param then
					return timing_tab(i).value;
				end if;
			end if;
		end loop;

		assert false
		report ">>> ddr_timing <<<"       & " : " & 
			sdram_chips'image(mark)       & " : " &
			sdram_parameters'image(param) & " : " &
			"not found, returning 0.0"
		severity warning;

		return 0.0;
	end;

	function ddr_latency (
		constant sdram : sdrams;
		constant param : sdram_latencies)
		return natural is
	begin
		for i in sdram_latency_tab'range loop
			if sdram_latency_tab(i).sdram = sdram then
				if sdram_latency_tab(i).param = param then
					return sdram_latency_tab(i).value;
				end if;
			end if;
		end loop;

		assert false
		report ">>> ddr_latency <<<"     & " : " & 
			sdrams'image(sdram)          & " : " &
			sdram_latencies'image(param) & " : " &
			"not found, returning 0"
		severity warning;

		return 0;
	end;

	function ddr_latency (
		constant fpga  : fpga_devices;
		constant param : device_latencies)
		return integer is
	begin
		for i in device_latency_tab'range loop
			if device_latency_tab(i).fpga = fpga then
				if device_latency_tab(i).param = param then
					return device_latency_tab(i).value;
				end if;
			end if;
		end loop;
		return 0;
	end;

	function to_ddrlatency (
		period : real;
		timing : real)
		return natural is
	begin
		return  natural(ceil(timing/period));
	end;

	function to_ddrlatency (
		constant period : real;
		constant mark   : sdram_chips;
		constant param  : sdram_parameters)
		return natural is
	begin
		return to_ddrlatency(period, ddr_timing(mark, param));
	end;

	function ddr_lattab (
		constant sdram : sdrams;
		constant rgtr  : sdram_latency_rgtr)
		return natural_vector is
		constant query_size : natural := ddr_query_size(sdram, rgtr);
		constant query_data : cnfglat_tab(0 to query_size-1) := ddr_query_data(sdram, rgtr);
		variable lattab     : natural_vector(0 to query_size-1);
	begin
		for i in lattab'range loop
			lattab(i) := query_data(i).lat;
		end loop;
		return lattab;
	end;

	function ddr_schtab (
		constant sdram : sdrams;
		constant fpga  : fpga_devices;
		constant tabid : device_latencies)
		return natural_vector is

		constant cwlsel : sdram_latency_rgtr := ddr_selcwl(sdram);
		constant cltab  : natural_vector := ddr_lattab(sdram, CL);
		constant cwltab : natural_vector := ddr_lattab(sdram, cwlsel);

		variable lat    : integer := ddr_latency(fpga, tabid);
		variable clval  : natural_vector(cltab'range);
		variable cwlval : natural_vector(cwltab'range);

	begin
		case tabid is
		when WWNL =>
			case sdram is
			when sdr|ddr|ddr3 =>
				for i in cwltab'range loop
					cwlval(i) := cwltab(i) + lat;
				end loop;
				return cwlval;
			when ddr2 =>
				for i in cltab'range loop
					clval(i) := cltab(i) + lat;
				end loop;
				return clval;
			when others =>
				return (0 to 0 => 0);
			end case;
		when STRL|RWNL =>
			for i in cltab'range loop
				clval(i) := cltab(i) + lat;
			end loop;
			return clval;
		when DQSZL|DQSL|DQZL =>
			if sdram=ddr2 then
				lat := lat - 2;
			end if;
			for i in cwltab'range loop
				cwlval(i) := cwltab(i) + lat;
			end loop;
			return cwlval;
		when others =>
			return (0 to 0 => 0);
		end case;
		return (0 to 0 => 0);
	end;

	function ddr_latcod (
		constant sdram : sdrams;
		constant rgtr  : sdram_latency_rgtr)
		return std_logic_vector is
		constant query_size : natural := ddr_query_size(sdram, rgtr);
		constant query_data : cnfglat_tab(0 to query_size-1) := ddr_query_data(sdram, rgtr);
		variable latcode : unsigned(0 to code_size*query_size-1);
	begin
		for i in query_data'reverse_range loop
			latcode := latcode srl code_size;
			latcode(code_t'range) := unsigned(query_data(i).code);
		end loop;
		return std_logic_vector(latcode);
	end;

	function ddr_selcwl (
		constant sdram : sdrams)
		return sdram_latency_rgtr is
	begin
		if sdram = ddr2 then
			return CL;
		end if;
		return CWL;
	end;

end package body;
