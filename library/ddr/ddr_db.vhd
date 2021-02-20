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

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library hdl4fpga;
use hdl4fpga.std.all;

package ddr_db is

	constant ANY         : natural := 0;

	constant SPARTAN3    : natural := 1;
	constant VIRTEX5     : natural := 2;
	constant LATTICEECP3 : natural := 3;
	constant VIRTEX7     : natural := 4;


	constant SDRAM : natural := 0;
	constant DDR1  : natural := 1;
	constant DDR2  : natural := 2;
	constant DDR3  : natural := 3;

	constant M6T  : natural := 1;
	constant M15E : natural := 2;
	constant M3   : natural := 3;
	constant M125 : natural := 3;
	constant M7E  : natural := 4;

	constant tPreRST : natural :=  1;
	constant tPstRST : natural :=  2;
	constant tXPR    : natural :=  3;
	constant tWR     : natural :=  4;
	constant tRP     : natural :=  5;
	constant tRCD    : natural :=  6;
	constant tRFC    : natural :=  7;
	constant tMRD    : natural :=  8;
	constant tREFI   : natural :=  9;
	constant tRPA    : natural := 10;

	constant CL  : natural := 1;
	constant BL  : natural := 2;
	constant WRL : natural := 3;
	constant CWL : natural := 4;

	-- Latencies 
	constant cDLL   : natural := 1;
	constant MRD    : natural := 2;
	constant MODu   : natural := 3;
	constant XPR    : natural := 4;
	constant STRL   : natural := 5;
	constant RWNL   : natural := 6;
	constant DQSZL  : natural := 7;
	constant DQSL   : natural := 8;
	constant DQZL   : natural := 9;
	constant WWNL   : natural := 10;
	constant STRXL  : natural := 11;
	constant RWNXL  : natural := 12;
	constant DQSZXL : natural := 13;
	constant DQSXL  : natural := 14;
	constant DQZXL  : natural := 15;
	constant WWNXL  : natural := 16;
	constant WIDL   : natural := 17;
	constant ZQINIT : natural := 18;
	constant RDFIFO_LAT : natural := 19;
	constant RDFIFO_DELAY : natural := 20;

	constant code_size : natural := 3;
	subtype code_t is std_logic_vector(0 to code_size-1);
	type cnfglat_record is record
		stdr : natural;
		rgtr : natural;
		lat  : integer;
		code : code_t;
	end record;

	type cnfglat_tab is array (natural range <>) of cnfglat_record;

	type tmark_record is record
		mark : natural;
		stdr : natural;
	end record;

	type tmark_tab is array (natural range <>) of tmark_record;

	constant tmark_db : tmark_tab := (
		tmark_record'(mark => M7E,  stdr => SDRAM),
		tmark_record'(mark => M6T,  stdr => DDR1),
		tmark_record'(mark => M3,   stdr => DDR2),
		tmark_record'(mark => M15E, stdr => DDR3),
		tmark_record'(mark => M125, stdr => DDR3));

	type latency_record is record
		fpga  : natural;
		param : natural; -- Latency
		value : integer;
	end record;

	type latency_tab is array (natural range <>) of latency_record;

	type timing_record is record
		mark  : natural;
		param : natural;
		value : natural;
	end record;

	type cntlrcnfg_boolean is record
		fpga  : natural;
		param : natural;
		value : boolean;
	end record;

	type cntlrcnfgboolean_tab is array (natural range <>) of cntlrcnfg_boolean;

	type timing_tab is array (natural range <>) of timing_record;

	constant timing_db : timing_tab := (
		timing_record'(mark => M7E,  param => tPreRST, value => 100*1_000_000),
--		timing_record'(mark => M7E,  param => tWR,   value => 14000),
		timing_record'(mark => M7E,  param => tWR,   value => 14000+11000),
		timing_record'(mark => M7E,  param => tRP,   value => 15000),
		timing_record'(mark => M7E,  param => tRCD,  value => 15000),
		timing_record'(mark => M7E,  param => tRFC,  value => 66000),
		timing_record'(mark => M7E,  param => tMRD,  value => 15000),
		timing_record'(mark => M7E,  param => tREFI, value => integer(64.0e9/8192.0)),
--		timing_record'(mark => M7E,  param => tREFI, value => 800000),
--		timing_record'(mark => M7E,  param => tREFI, value => 8000),

		timing_record'(mark => M6T,  param => tPreRST, value => 200*1_000_000),
--		timing_record'(mark => M6T,  param => tPreRST, value => 1*1_000_000),
		timing_record'(mark => M6T,  param => tWR,   value => 15000),
		timing_record'(mark => M6T,  param => tRP,   value => 15000),
		timing_record'(mark => M6T,  param => tRCD,  value => 15000),
		timing_record'(mark => M6T,  param => tRFC,  value => 72000),
		timing_record'(mark => M6T,  param => tMRD,  value => 12000),
		timing_record'(mark => M6T,  param => tREFI, value => 7000000),
--		timing_record'(mark => M6T,  param => tREFI, value => 700000),

		timing_record'(mark => M3,  param => tPreRST, value => 200*1_000_000),
		timing_record'(mark => M3,  param => tXPR,  value => 400000),
		timing_record'(mark => M3,  param => tWR,   value => 15000),
		timing_record'(mark => M3,  param => tRP,   value => 15000),
		timing_record'(mark => M3,  param => tRCD,  value => 15000),
		timing_record'(mark => M3,  param => tRFC,  value => 130000),
		timing_record'(mark => M3,  param => tRPA,  value => 15000),
		timing_record'(mark => M3,  param => tREFI, value => 7800000),

		timing_record'(mark => M15E, param => tPreRST, value => 200*1_000_000),
		timing_record'(mark => M15E, param => tPstRST, value => 500*1_000_000),
		timing_record'(mark => M15E, param => tWR,   value => 15000),
		timing_record'(mark => M15E, param => tRCD,  value => 13910),
		timing_record'(mark => M15E, param => tRP,   value => 13910),
		timing_record'(mark => M15E, param => tMRD,  value => 15000),
		timing_record'(mark => M15E, param => tRFC,  value => 110000),
		timing_record'(mark => M15E, param => tXPR,  value => 110000 + 10000),
		timing_record'(mark => M15E, param => tREFI, value => 7800000));

	constant latency_db : latency_tab := (
		latency_record'(fpga => spartan3,    param => cDLL,       value => 200),
		latency_record'(fpga => spartan3,    param => STRL,       value =>   0),
		latency_record'(fpga => spartan3,    param => RWNL,       value =>   0),
		latency_record'(fpga => spartan3,    param => DQSZL,      value =>   0),
		latency_record'(fpga => spartan3,    param => DQSL,       value =>   1),
		latency_record'(fpga => spartan3,    param => DQZL,       value =>   0),
		latency_record'(fpga => spartan3,    param => WWNL,       value =>   0),
--		latency_record'(fpga => spartan3,    param => STRXL,      value =>   2),
		latency_record'(fpga => spartan3,    param => STRXL,      value =>   0),
		latency_record'(fpga => spartan3,    param => RWNXL,      value => 2*0),
		latency_record'(fpga => spartan3,    param => DQSZXL,     value =>  1),
		latency_record'(fpga => spartan3,    param => DQSXL,      value =>   0),
		latency_record'(fpga => spartan3,    param => DQZXL,      value =>   0),
		latency_record'(fpga => spartan3,    param => WWNXL,      value =>   0),
		latency_record'(fpga => spartan3,    param => WIDL,       value =>   1),
		latency_record'(fpga => spartan3,    param => RDFIFO_LAT, value => 2),

		latency_record'(fpga => virtex5,     param => cDLL,       value => 200),
		latency_record'(fpga => virtex5,     param => MRD,        value =>   2),
		latency_record'(fpga => virtex5,     param => STRL,       value =>   -4),
		latency_record'(fpga => virtex5,     param => RWNL,       value =>   4),
		latency_record'(fpga => virtex5,     param => DQSL,       value =>  -0),
		latency_record'(fpga => virtex5,     param => DQSZL,      value =>  -2),
		latency_record'(fpga => virtex5,     param => DQZL,       value =>  -2),
		latency_record'(fpga => virtex5,     param => WWNL,       value =>  -4),
		latency_record'(fpga => virtex5,     param => STRXL,      value =>   1),
		latency_record'(fpga => virtex5,     param => RWNXL,      value =>   0),
		latency_record'(fpga => virtex5,     param => DQSXL,      value =>   0),
		latency_record'(fpga => virtex5,     param => DQSZXL,     value =>  4),
		latency_record'(fpga => virtex5,     param => DQZXL,      value =>   2),
		latency_record'(fpga => virtex5,     param => WWNXL,      value =>   2),
		latency_record'(fpga => virtex5,     param => WIDL,       value =>   4),
		latency_record'(fpga => virtex5,     param => RDFIFO_LAT, value => 2),

		latency_record'(fpga => latticeECP3, param => cDLL,       value => 500),
		latency_record'(fpga => latticeECP3, param => STRL,       value =>   4),
		latency_record'(fpga => latticeECP3, param => RWNL,       value =>   4),
		latency_record'(fpga => latticeECP3, param => DQSL,       value =>  -4),
		latency_record'(fpga => latticeECP3, param => DQSZL,      value =>  -2),
		latency_record'(fpga => latticeECP3, param => DQZL,       value =>   0),
		latency_record'(fpga => latticeECP3, param => WWNL,       value =>   0),
		latency_record'(fpga => latticeECP3, param => STRXL,      value =>   0),
		latency_record'(fpga => latticeECP3, param => RWNXL,      value =>   0),
		latency_record'(fpga => latticeECP3, param => DQSXL,      value =>   4),
		latency_record'(fpga => latticeECP3, param => DQSZXL,     value =>  4),
		latency_record'(fpga => latticeECP3, param => DQZXL,      value =>   4),
		latency_record'(fpga => latticeECP3, param => WWNXL,      value =>   2),
		latency_record'(fpga => latticeECP3, param => ZQINIT,     value => 500),
		latency_record'(fpga => latticeECP3, param => MRD,        value =>   4),
		latency_record'(fpga => latticeECP3, param => MODu,       value =>  12),
		latency_record'(fpga => latticeECP3, param => XPR,        value =>   5),
		latency_record'(fpga => latticeECP3, param => WIDL,       value =>   4),
		latency_record'(fpga => latticeECP3, param => RDFIFO_LAT, value => 3),
	
		latency_record'(fpga => virtex7,     param => cDLL,       value => 500),
		latency_record'(fpga => virtex7,     param => STRL,       value =>   0),
		latency_record'(fpga => virtex7,     param => RWNL,       value =>   4),
		latency_record'(fpga => virtex7,     param => DQSL,       value =>  -4),
		latency_record'(fpga => virtex7,     param => DQSZL,      value =>  -4),
		latency_record'(fpga => virtex7,     param => DQZL,       value =>  -5),
		latency_record'(fpga => virtex7,     param => WWNL,       value =>  -5),
		latency_record'(fpga => virtex7,     param => STRXL,      value =>   0),
		latency_record'(fpga => virtex7,     param => RWNXL,      value =>   0),
		latency_record'(fpga => virtex7,     param => DQSXL,      value =>   2),
		latency_record'(fpga => virtex7,     param => DQSZXL,     value =>  4),
		latency_record'(fpga => virtex7,     param => DQZXL,      value =>   0),
		latency_record'(fpga => virtex7,     param => WWNXL,      value =>   0),
		latency_record'(fpga => virtex7,     param => ZQINIT,     value => 500),
		latency_record'(fpga => virtex7,     param => MRD,        value =>   4),
		latency_record'(fpga => virtex7,     param => MODu,       value =>  12),
		latency_record'(fpga => virtex7,     param => XPR,        value =>   5),
		latency_record'(fpga => virtex7,     param => WIDL,       value =>   4),
		latency_record'(fpga => virtex7,     param => RDFIFO_LAT, value => 4));

	constant cntlrcnfgboolean_db : cntlrcnfgboolean_tab := (
		cntlrcnfg_boolean'(fpga => spartan3,    param => RDFIFO_DELAY, value => FALSE),
		cntlrcnfg_boolean'(fpga => virtex5,     param => RDFIFO_DELAY, value => FALSE),
		cntlrcnfg_boolean'(fpga => latticeECP3, param => RDFIFO_DELAY, value => FALSE));
		
	constant cnfglat_db : cnfglat_tab := (

		-- SDRAM standard --
		--------------------

		-- CL register --

		cnfglat_record'(stdr => SDRAM, rgtr => CL,  lat =>  1, code => "001"),
		cnfglat_record'(stdr => SDRAM, rgtr => CL,  lat =>  2, code => "010"),
		cnfglat_record'(stdr => SDRAM, rgtr => CL,  lat =>  3, code => "011"),

		-- BL register --

		cnfglat_record'(stdr => SDRAM, rgtr => BL,  lat =>  0, code => "000"),
		cnfglat_record'(stdr => SDRAM, rgtr => BL,  lat =>  1, code => "001"),
		cnfglat_record'(stdr => SDRAM, rgtr => BL,  lat =>  2, code => "010"),
		cnfglat_record'(stdr => SDRAM, rgtr => BL,  lat =>  4, code => "011"),

		-- CWL register --

		cnfglat_record'(stdr => SDRAM, rgtr => CWL, lat =>  0, code => "000"),

		-- DDR1 standard --
		-------------------

		-- CL register --

		cnfglat_record'(stdr => DDR1, rgtr => CL,  lat =>  2*2, code => "010"),
		cnfglat_record'(stdr => DDR1, rgtr => CL,  lat =>  1*5, code => "110"),
		cnfglat_record'(stdr => DDR1, rgtr => CL,  lat =>  2*3, code => "011"),

		-- BL register --

		cnfglat_record'(stdr => DDR1, rgtr => BL,  lat =>  2*1, code => "001"),
		cnfglat_record'(stdr => DDR1, rgtr => BL,  lat =>  2*2, code => "010"),
		cnfglat_record'(stdr => DDR1, rgtr => BL,  lat =>  2*4, code => "011"),

		-- CWL register --

		cnfglat_record'(stdr => DDR1, rgtr => CWL, lat =>  2*1, code => "000"),

		-- DDR2 standard --
		-------------------

		-- CL register --

		cnfglat_record'(stdr => DDR2, rgtr => CL,  lat =>  3*2, code => "011"),
		cnfglat_record'(stdr => DDR2, rgtr => CL,  lat =>  4*2, code => "100"),
		cnfglat_record'(stdr => DDR2, rgtr => CL,  lat =>  5*2, code => "101"),
		cnfglat_record'(stdr => DDR2, rgtr => CL,  lat =>  6*2, code => "110"),
		cnfglat_record'(stdr => DDR2, rgtr => CL,  lat =>  7*2, code => "111"),

		-- BL register --

		cnfglat_record'(stdr => DDR2, rgtr => BL,  lat =>  2*2, code => "010"),
		cnfglat_record'(stdr => DDR2, rgtr => BL,  lat =>  4*2, code => "011"),

		-- WRL register --

		cnfglat_record'(stdr => DDR2, rgtr => WRL, lat =>  2*2, code => "001"),
		cnfglat_record'(stdr => DDR2, rgtr => WRL, lat =>  3*2, code => "010"),
		cnfglat_record'(stdr => DDR2, rgtr => WRL, lat =>  4*2, code => "011"),
		cnfglat_record'(stdr => DDR2, rgtr => WRL, lat =>  5*2, code => "100"),
		cnfglat_record'(stdr => DDR2, rgtr => WRL, lat =>  6*2, code => "101"),
		cnfglat_record'(stdr => DDR2, rgtr => WRL, lat =>  7*2, code => "110"),
		cnfglat_record'(stdr => DDR2, rgtr => WRL, lat =>  8*2, code => "111"),

		-- DDR3 standard --
		-------------------

		-- CL register --

		cnfglat_record'(stdr => DDR3, rgtr => CL, lat =>  5*2, code => "001"),
		cnfglat_record'(stdr => DDR3, rgtr => CL, lat =>  6*2, code => "010"),
		cnfglat_record'(stdr => DDR3, rgtr => CL, lat =>  7*2, code => "011"),
		cnfglat_record'(stdr => DDR3, rgtr => CL, lat =>  8*2, code => "100"),
		cnfglat_record'(stdr => DDR3, rgtr => CL, lat =>  9*2, code => "101"),
		cnfglat_record'(stdr => DDR3, rgtr => CL, lat => 10*2, code => "110"),
		cnfglat_record'(stdr => DDR3, rgtr => CL, lat => 2*11, code => "111"),

		-- BL register --

		cnfglat_record'(stdr => DDR3, rgtr => BL, lat => 8, code => "000"),
		cnfglat_record'(stdr => DDR3, rgtr => BL, lat => 8, code => "001"),
		cnfglat_record'(stdr => DDR3, rgtr => BL, lat => 8, code => "010"),

		-- WRL register --

		cnfglat_record'(stdr => DDR3, rgtr => WRL, lat =>  5*2,  code => "001"),
		cnfglat_record'(stdr => DDR3, rgtr => WRL, lat =>  6*2,  code => "010"),
		cnfglat_record'(stdr => DDR3, rgtr => WRL, lat =>  7*2,  code => "011"),
		cnfglat_record'(stdr => DDR3, rgtr => WRL, lat =>  8*2,  code => "100"),
		cnfglat_record'(stdr => DDR3, rgtr => WRL, lat => 10*2, code => "101"),
		cnfglat_record'(stdr => DDR3, rgtr => WRL, lat => 12*2, code => "110"),

		-- CWL register --

		cnfglat_record'(stdr => DDR3, rgtr => CWL, lat =>  5*2, code => "000"),
		cnfglat_record'(stdr => DDR3, rgtr => CWL, lat =>  6*2, code => "001"),
		cnfglat_record'(stdr => DDR3, rgtr => CWL, lat =>  7*2, code => "010"),
		cnfglat_record'(stdr => DDR3, rgtr => CWL, lat =>  8*2, code => "011"));

	function ddr_stdr (
		mark : natural) 
		return natural;

	function ddr_query_size (
		constant stdr : natural;
		constant rgtr  : natural)
		return natural;

	function ddr_cnfglat (
		constant stdr : natural;
		constant rgtr : natural;
		constant lat  : natural)
		return std_logic_vector;

	function ddr_timing (
		constant mark  : natural;
		constant param : natural) 
		return natural;

	function ddr_latency (
		constant fpga  : natural;
		constant param : natural)
		return integer;

	function ddr_lattab (
		constant stdr : natural;
		constant rgtr : natural)
		return natural_vector;

	function ddr_schtab (
		constant stdr  : natural;
		constant fpga  : natural;
		constant tabid : natural)
		return natural_vector;

	function to_ddrlatency (
		period : natural;
		timing : natural)
		return natural;

	function to_ddrlatency (
		constant period : natural;
		constant mark   : natural;
		constant param  : natural)
		return natural;

	function ddr_latcod (
		constant stdr : natural;
		constant rgtr : natural)
		return std_logic_vector;

	function ddr_selcwl (
		constant stdr : natural)
		return natural;

	function ddr_cntlrcnfg (
		constant fpga  : natural;
		constant param : natural)
		return boolean;
end package;

package body ddr_db is

	function ddr_stdr (
		mark : natural) 
		return natural is
	begin
		for i in tmark_db'range loop
			if tmark_db(i).mark = mark then
				return tmark_db(i).stdr;
			end if;
		end loop;
		return 0;
	end;

	function ddr_query_size (
		constant stdr : natural;
		constant rgtr : natural)
		return natural is
		variable val : natural := 0;
	begin
		for i in cnfglat_db'range loop
			if cnfglat_db(i).stdr = stdr then
				if cnfglat_db(i).rgtr = rgtr then
					val := val + 1;
				end if;
			end if;
		end loop;
		return val;
	end;

	function ddr_query_data (
		constant stdr : natural;
		constant rgtr : natural)
		return cnfglat_tab is
		constant query_size : natural := ddr_query_size(stdr, rgtr);
		variable query_data : cnfglat_tab (0 to query_size-1);
		variable query_row  : natural := 0;
	begin
		for i in cnfglat_db'range loop
			if cnfglat_db(i).stdr = stdr then
				if cnfglat_db(i).rgtr = rgtr then
					query_data(query_row) := cnfglat_db(i);
					query_row := query_row + 1;
				end if;
			end if;
		end loop;
		return query_data;
	end;

	function ddr_cnfglat (
		constant stdr : natural;
		constant rgtr : natural;
		constant lat  : natural)
		return std_logic_vector is
	begin
		for i in cnfglat_db'range loop
			if cnfglat_db(i).stdr = stdr then
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
		constant mark  : natural;
		constant param : natural) 
		return natural is
	begin
		for i in timing_db'range loop
			if timing_db(i).mark = mark then
				if timing_db(i).param = param then
					return timing_db(i).value;
				end if;
			end if;
		end loop;

		return 0;
	end;

	function ddr_latency (
		constant fpga  : natural;
		constant param : natural)
		return integer is
	begin
		for i in latency_db'range loop
			if latency_db(i).fpga = fpga then
				if latency_db(i).param = param then
					return latency_db(i).value;
				end if;
			end if;
		end loop;
		return 0;
	end;

	function to_ddrlatency (
		period : natural;
		timing : natural)
		return natural is
	begin
		if (timing/period)*period < timing then
			return (timing+period)/period;
		else
			return timing/period;
		end if;
	end;

	function to_ddrlatency (
		constant period : natural;
		constant mark   : natural;
		constant param  : natural)
		return natural is
	begin
		return to_ddrlatency(period, ddr_timing(mark, param));
	end;

	function ddr_lattab (
		constant stdr : natural;
		constant rgtr : natural)
		return natural_vector is
		constant query_size : natural := ddr_query_size(stdr, rgtr);
		constant query_data : cnfglat_tab(0 to query_size-1) := ddr_query_data(stdr, rgtr);
		variable lattab : natural_vector(0 to query_size-1);
	begin
		for i in lattab'range loop
			lattab(i) := query_data(i).lat;
		end loop;
		return lattab;
	end;

	function ddr_schtab (
		constant stdr  : natural;
		constant fpga  : natural;
		constant tabid : natural)
		return natural_vector is

		constant cwlsel : natural := ddr_selcwl(stdr);
		constant cltab  : natural_vector := ddr_lattab(stdr, CL);
		constant cwltab : natural_vector := ddr_lattab(stdr, cwlsel);

		variable lat : integer := ddr_latency(fpga, tabid);
		variable clval  : natural_vector(cltab'range);
		variable cwlval : natural_vector(cwltab'range);

	begin
		case tabid is
		when WWNL =>
			case stdr is
			when SDRAM|DDR1|DDR3 =>
				for i in cwltab'range loop
					cwlval(i) := cwltab(i) + lat;
				end loop;
				return cwlval;
			when DDR2 =>
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
		when DQSZL|DQSL|DQZL|CWL =>
			if stdr=2 then
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
		constant stdr : natural;
		constant rgtr : natural)
		return std_logic_vector is
		constant query_size : natural := ddr_query_size(stdr, rgtr);
		constant query_data : cnfglat_tab(0 to query_size-1) := ddr_query_data(stdr, rgtr);
		variable latcode : unsigned(0 to code_size*query_size-1);
	begin
		for i in query_data'reverse_range loop
			latcode := latcode srl code_size;
			latcode(code_t'range) := unsigned(query_data(i).code);
		end loop;
		return std_logic_vector(latcode);
	end;

	function ddr_selcwl (
		constant stdr : natural)
		return natural is
	begin
		if stdr = 2 then
			return CL;
		end if;
		return CWL;
	end;

	function ddr_cntlrcnfg (
		constant fpga : natural;
		constant param : natural)
		return boolean is
	begin
		for i in cntlrcnfgboolean_db'range loop
			if cntlrcnfgboolean_db(i).fpga = fpga then
				if cntlrcnfgboolean_db(i).param = param then
					return cntlrcnfgboolean_db(i).value;
				end if;
			end if;
		end loop;
		assert FALSE severity FAILURE;
		return FALSE;
	end;

end package body;
