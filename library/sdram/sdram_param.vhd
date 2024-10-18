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
use hdl4fpga.base.all;
use hdl4fpga.hdo.all;

package sdram_param is


	constant : string := compact("{" &
		"sdr : {" &
		"    al  : { 000 : 0 }," &
		"    cl  : { 001 : 1, 010 : 2, 011 : 3 }," &
		"    bl  : { 000 : 0, 001 : 1, 010 : 2, '011' : 4 }," &
		"    cwl : { 000 : 0 }}," &
		"ddr : {" &
		"    al  : {000, 0}" &
		"    cl  : {010, 4, 110, 5, 011, 3}," &
		"    bl  : {001, 2, 010, 4, 011, 8}," &
		"    cwl : {000, 2}}," &
		"ddr2 : {" &
		"    al  : {000 : 0, 001 : 2, 010 :  4, 011 :  6, 100 :  8, 101 : 10, 110: 12}," &
		"    cl  : {011 : 6, 100 : 8, 101 : 10, 110 : 12, 111 : 14}," &
		"    bl  : {010 : 2, 011 : 8}," &
		"    wrl : {001 : 4, 010 : 6, 011 : 8, 100 : 10, 101 : 12, 110 : 14, 111 : 16}}," &
		"ddr3 : {" &
		"    al  : { 000 :  0, 001 :  2, 010 :  4}," &
		"    cl  : { 001 : 10, 010 : 12, 011 : 14, 100 : 16, 101 : 18, 110 : 20, 111 : 22}," &
		"    bl  : { 000 :  8, 001 :  8, 010 :  8}," &
		"    wrl : { 001 : 10, 010 : 12, 011 : 14, 100 : 16, 101 : 20, 110 : 24}," &
		"    cwl : { 000 : 10, 001 : 12, 010 : 14, 011 : 16}}};");

	type sdram_cmd is record
		cs  : std_logic;
		ras : std_logic;
		cas : std_logic;
		we  : std_logic;
	end record;

	constant sdram_nop : sdram_cmd := (cs => '0', ras => '1', cas => '1', we => '1');
	constant sdram_mrs : sdram_cmd := (cs => '0', ras => '0', cas => '0', we => '0');
	constant sdram_pre : sdram_cmd := (cs => '0', ras => '0', cas => '1', we => '0');
	constant sdram_ref : sdram_cmd := (cs => '0', ras => '0', cas => '0', we => '1');
	constant sdram_zqc : sdram_cmd := (cs => '0', ras => '1', cas => '1', we => '0');

	constant mpu_nop   : std_logic_vector(0 to 2) := "111";
	constant mpu_act   : std_logic_vector(0 to 2) := "011";
	constant mpu_read  : std_logic_vector(0 to 2) := "101";
	constant mpu_write : std_logic_vector(0 to 2) := "100";
	constant mpu_pre   : std_logic_vector(0 to 2) := "010";
	constant mpu_aut   : std_logic_vector(0 to 2) := "001";
	constant mpu_dcare : std_logic_vector(0 to 2) := "000";

	function sdram_query_size (
		constant stdr : sdram_standards;
		constant rgtr  : sdram_latency_rgtr)
		return natural;

	function sdram_latcod (
		constant stdr : sdram_standards;
		constant rgtr : sdram_latency_rgtr)
		return std_logic_vector;

	function sdram_selcwl (
		constant stdr : sdram_standards)
		return sdram_latency_rgtr;

	function sdram_lattab (
		constant stdr : sdram_standards;
		constant rgtr  : sdram_latency_rgtr)
		return natural_vector;

	function shuffle_vector (
		constant data : std_logic_vector;
		constant gear : natural;
		constant size : natural)
		return std_logic_vector;

	function unshuffle_vector (
		constant data : std_logic_vector;
		constant gear : natural;
		constant size : natural)
		return std_logic_vector;

end package;

package body sdram_param is

	function xxx (
		constant std : string;
		constant reg : string)
		return std_logic_vector is
		variable retval : unsigned(0 to 2**'length*width-1);
	begin
		retval := (others => '0');
		for i in 0 to 2**'length-1 loop
			:= hdo(std)**("."&reg&"."&integer'image(i));
		end loop;
	end;

	function sdram_selcwl (
		constant stdr : sdram_standards)
		return sdram_latency_rgtr is
	begin
		if stdr = ddr2 then
			return CL;
		end if;
		return CWL;
	end;

	function sdram_lattab (
		constant stdr : sdram_standards;
		constant rgtr : sdram_latency_rgtr)
		return natural_vector is
		constant query_size : natural := sdram_query_size(stdr, rgtr);
		constant query_data : cfglat_vector(0 to query_size-1) := sdram_query_data(stdr, rgtr);
		variable lattab     : natural_vector(0 to query_size-1);
	begin
		for i in lattab'range loop
			lattab(i) := query_data(i).lat;
		end loop;
		return lattab;
	end;

	function shuffle_vector (
		constant data : std_logic_vector;
		constant gear : natural;
		constant size : natural) 
		return std_logic_vector is
		variable val : std_logic_vector(data'range);
	begin	
		for i in data'length/(gear*size)-1 downto 0 loop
			for j in gear-1 downto 0 loop
				for l in size-1 downto 0 loop
					val((i*gear+j)*size+l) := data(j*(data'length/gear)+i*size+l);
				end loop;
			end loop;
		end loop;
		return val;
	end;

	function unshuffle_vector (
		constant data : std_logic_vector;
		constant gear : natural;
		constant size : natural) 
		return std_logic_vector is
		variable val : std_logic_vector(data'range);
	begin	
		for i in data'length/(gear*size)-1 downto 0 loop
			for j in gear-1 downto 0 loop
				for l in size-1 downto 0 loop
					val(j*(data'length/gear)+i*size+l) := data((i*gear+j)*size+l);
				end loop;
			end loop;
		end loop;
		return val;
	end;

end package body;
