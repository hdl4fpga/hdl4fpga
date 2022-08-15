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

library hdl4fpga;
use hdl4fpga.std.all;

package sdr_param is

	type sdram_parameters   is (tPreRST, tPstRST, tXPR, tWR, tRP, tRCD, tRFC, tMRD, tREFI, tRPA);
	type sdram_latency_rgtr is (CL, BL, WRL, CWL);
	type sdram_latencies    is (cDLL, MRD, MODu, XPR, ZQINIT);
	type device_latencies   is (
		strl,   rwnl,  dqszl, dqsl,  dqzl, wwnl, strxl, rwnxl,
		dqszxl, dqsxl, dqzxl, wwnxl, widl, rdfifo_lat);

	type sdr_standards is (sdr, ddr, ddr2, ddr3);

	type sdram_latency_record is record
		stdr  : sdr_standards;
		param : sdram_latencies;
		value : natural;
	end record;
	type sdram_latency_vector is array (natural range <>) of sdram_latency_record;

	constant code_size : natural := 3;
	subtype code_t is std_logic_vector(0 to code_size-1);

	type cfglat_record is record
		stdr  : sdr_standards;
		rgtr  : sdram_latency_rgtr;
		lat   : natural;
		code  : code_t;
	end record;
	type cfglat_vector is array (natural range <>) of cfglat_record;

	constant cfglat_tab : cfglat_vector := (

		-- stdr standard --
		--------------------

		-- CL register --

		(stdr => sdr, rgtr => CL,  lat =>  1, code => "001"),
		(stdr => sdr, rgtr => CL,  lat =>  2, code => "010"),
		(stdr => sdr, rgtr => CL,  lat =>  3, code => "011"),

		-- BL register --

		(stdr => sdr, rgtr => BL,  lat =>  0, code => "000"),
		(stdr => sdr, rgtr => BL,  lat =>  1, code => "001"),
		(stdr => sdr, rgtr => BL,  lat =>  2, code => "010"),
		(stdr => sdr, rgtr => BL,  lat =>  4, code => "011"),

		-- CWL register --

		(stdr => sdr, rgtr => CWL, lat =>  0, code => "000"),

		-- DDR1 standard --
		-------------------

		-- CL register --

		(stdr => ddr, rgtr => CL,  lat =>  2*2, code => "010"),
		(stdr => ddr, rgtr => CL,  lat =>  1*5, code => "110"),
		(stdr => ddr, rgtr => CL,  lat =>  2*3, code => "011"),

		-- BL register --

		(stdr => ddr, rgtr => BL,  lat =>  2*1, code => "001"),
		(stdr => ddr, rgtr => BL,  lat =>  2*2, code => "010"),
		(stdr => ddr, rgtr => BL,  lat =>  2*4, code => "011"),

		-- CWL register --

		(stdr => ddr, rgtr => CWL, lat =>  2*1, code => "000"),

		-- DDR2 standard --
		-------------------

		-- CL register --

		(stdr => DDR2, rgtr => CL,  lat =>  3*2, code => "011"),
		(stdr => DDR2, rgtr => CL,  lat =>  4*2, code => "100"),
		(stdr => DDR2, rgtr => CL,  lat =>  5*2, code => "101"),
		(stdr => DDR2, rgtr => CL,  lat =>  6*2, code => "110"),
		(stdr => DDR2, rgtr => CL,  lat =>  7*2, code => "111"),

		-- BL register --

		(stdr => DDR2, rgtr => BL,  lat =>  2*2, code => "010"),
		(stdr => DDR2, rgtr => BL,  lat =>  4*2, code => "011"),

		-- WRL register --

		(stdr => DDR2, rgtr => WRL, lat =>  2*2, code => "001"),
		(stdr => DDR2, rgtr => WRL, lat =>  3*2, code => "010"),
		(stdr => DDR2, rgtr => WRL, lat =>  4*2, code => "011"),
		(stdr => DDR2, rgtr => WRL, lat =>  5*2, code => "100"),
		(stdr => DDR2, rgtr => WRL, lat =>  6*2, code => "101"),
		(stdr => DDR2, rgtr => WRL, lat =>  7*2, code => "110"),
		(stdr => DDR2, rgtr => WRL, lat =>  8*2, code => "111"),

		-- DDR3 standard --
		-------------------

		-- CL register --

		(stdr => DDR3, rgtr => CL, lat =>  5*2, code => "001"),
		(stdr => DDR3, rgtr => CL, lat =>  6*2, code => "010"),
		(stdr => DDR3, rgtr => CL, lat =>  7*2, code => "011"),
		(stdr => DDR3, rgtr => CL, lat =>  8*2, code => "100"),
		(stdr => DDR3, rgtr => CL, lat =>  9*2, code => "101"),
		(stdr => DDR3, rgtr => CL, lat => 10*2, code => "110"),
		(stdr => DDR3, rgtr => CL, lat => 2*11, code => "111"),

		-- BL register --

		(stdr => DDR3, rgtr => BL, lat => 8, code => "000"),
		(stdr => DDR3, rgtr => BL, lat => 8, code => "001"),
		(stdr => DDR3, rgtr => BL, lat => 8, code => "010"),

		-- WRL register --

		(stdr => DDR3, rgtr => WRL, lat =>  5*2,  code => "001"),
		(stdr => DDR3, rgtr => WRL, lat =>  6*2,  code => "010"),
		(stdr => DDR3, rgtr => WRL, lat =>  7*2,  code => "011"),
		(stdr => DDR3, rgtr => WRL, lat =>  8*2,  code => "100"),
		(stdr => DDR3, rgtr => WRL, lat => 10*2, code => "101"),
		(stdr => DDR3, rgtr => WRL, lat => 12*2, code => "110"),

		-- CWL register --

		(stdr => DDR3, rgtr => CWL, lat =>  5*2, code => "000"),
		(stdr => DDR3, rgtr => CWL, lat =>  6*2, code => "001"),
		(stdr => DDR3, rgtr => CWL, lat =>  7*2, code => "010"),
		(stdr => DDR3, rgtr => CWL, lat =>  8*2, code => "011"));

	type sdr_cmd is record
		cs  : std_logic;
		ras : std_logic;
		cas : std_logic;
		we  : std_logic;
	end record;

	constant sdr_nop : sdr_cmd := (cs => '0', ras => '1', cas => '1', we => '1');
	constant sdr_mrs : sdr_cmd := (cs => '0', ras => '0', cas => '0', we => '0');
	constant sdr_pre : sdr_cmd := (cs => '0', ras => '0', cas => '1', we => '0');
	constant sdr_ref : sdr_cmd := (cs => '0', ras => '0', cas => '0', we => '1');
	constant sdr_zqc : sdr_cmd := (cs => '0', ras => '1', cas => '1', we => '0');

	constant mpu_nop   : std_logic_vector(0 to 2) := "111";
	constant mpu_act   : std_logic_vector(0 to 2) := "011";
	constant mpu_read  : std_logic_vector(0 to 2) := "101";
	constant mpu_write : std_logic_vector(0 to 2) := "100";
	constant mpu_pre   : std_logic_vector(0 to 2) := "010";
	constant mpu_aut   : std_logic_vector(0 to 2) := "001";
	constant mpu_dcare : std_logic_vector(0 to 2) := "000";

	function sdr_cnfglat (
		constant stdr : sdr_standards;
		constant rgtr  : sdram_latency_rgtr;
		constant lat   : natural)
		return std_logic_vector;

	function sdr_query_size (
		constant stdr : sdr_standards;
		constant rgtr  : sdram_latency_rgtr)
		return natural;

	function sdr_latcod (
		constant stdr : sdr_standards;
		constant rgtr : sdram_latency_rgtr)
		return std_logic_vector;

	function sdr_selcwl (
		constant stdr : sdr_standards)
		return sdram_latency_rgtr;

	function sdr_lattab (
		constant stdr : sdr_standards;
		constant rgtr  : sdram_latency_rgtr)
		return natural_vector;

end package;

package body sdr_param is

	function sdr_cnfglat (
		constant stdr : sdr_standards;
		constant rgtr  : sdram_latency_rgtr;
		constant lat   : natural)
		return std_logic_vector is
	begin
		for i in cfglat_tab'range loop
			if cfglat_tab(i).stdr = stdr then
				if cfglat_tab(i).rgtr = rgtr then
					if cfglat_tab(i).lat = lat then
						return cfglat_tab(i).code;
					end if;
				end if;
			end if;
		end loop;

		assert false
		report ">>>sdr_cfglat<<<" & " : " & 
			sdr_standards'image(stdr) & " : " &
			sdram_latency_rgtr'image(rgtr) & " : " &
			natural'image(lat)    & " : " &
			"not found"
		severity failure;

		return "XXX";

	end;

	function sdr_query_size (
		constant stdr : sdr_standards;
		constant rgtr  : sdram_latency_rgtr)
		return natural is
		variable val : natural := 0;
	begin
		for i in cfglat_tab'range loop
			if cfglat_tab(i).stdr = stdr then
				if cfglat_tab(i).rgtr = rgtr then
					val := val + 1;
				end if;
			end if;
		end loop;
		return val;
	end;

	function sdr_query_data (
		constant stdr : sdr_standards;
		constant rgtr  : sdram_latency_rgtr)
		return cfglat_vector is
		constant query_size : natural := sdr_query_size(stdr, rgtr);
		variable query_data : cfglat_vector (0 to query_size-1);
		variable query_row  : natural := 0;
	begin
		for i in cfglat_tab'range loop
			if cfglat_tab(i).stdr = stdr then
				if cfglat_tab(i).rgtr = rgtr then
					query_data(query_row) := cfglat_tab(i);
					query_row := query_row + 1;
				end if;
			end if;
		end loop;
		return query_data;
	end;

	function sdr_latcod (
		constant stdr : sdr_standards;
		constant rgtr : sdram_latency_rgtr)
		return std_logic_vector is
		constant query_size : natural := sdr_query_size(stdr, rgtr);
		constant query_data : cfglat_vector(0 to query_size-1) := sdr_query_data(stdr, rgtr);
		variable latcode    : unsigned(0 to code_size*query_size-1);
	begin
		for i in query_data'reverse_range loop
			latcode := latcode srl code_size;
			latcode(code_t'range) := unsigned(query_data(i).code);
		end loop;
		return std_logic_vector(latcode);
	end;

	function sdr_selcwl (
		constant stdr : sdr_standards)
		return sdram_latency_rgtr is
	begin
		if stdr = ddr2 then
			return CL;
		end if;
		return CWL;
	end;

	function sdr_lattab (
		constant stdr : sdr_standards;
		constant rgtr  : sdram_latency_rgtr)
		return natural_vector is
		constant query_size : natural := sdr_query_size(stdr, rgtr);
		constant query_data : cfglat_vector(0 to query_size-1) := sdr_query_data(stdr, rgtr);
		variable lattab     : natural_vector(0 to query_size-1);
	begin
		for i in lattab'range loop
			lattab(i) := query_data(i).lat;
		end loop;
		return lattab;
	end;

end package body;
